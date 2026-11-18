// Local PostgreSQL verification. Requires the ignored build/sql-validation runtime:
// npm install --prefix build/sql-validation --no-audit --no-fund @electric-sql/pglite
// node tool/verify_schema.mjs
import { PGlite } from '../build/sql-validation/node_modules/@electric-sql/pglite/dist/index.js';
import { readFile } from 'node:fs/promises';
import assert from 'node:assert/strict';
const db=new PGlite();
const a='11111111-1111-4111-8111-111111111111',b='22222222-2222-4222-8222-222222222222';
let checks=0;
function check(value,message){assert.ok(value,message);checks++;console.log(`PASS ${message}`);}
await db.exec(`create role anon; create role authenticated; create schema auth;
create table auth.users(id uuid primary key,raw_user_meta_data jsonb);
create function auth.uid() returns uuid language sql stable as
$$ select (nullif(current_setting('request.jwt.claims',true),'')::jsonb->>'sub')::uuid $$;
`);
await db.exec('grant usage on schema auth to anon,authenticated;');
const schema=await readFile(new URL('../supabase/schema.sql',import.meta.url),'utf8');
await db.exec(schema);await db.exec(schema);
check((await db.query('select * from public.menu_items')).rows.length===8,'schema executes twice and seeds exactly 8 items');
await db.query('insert into auth.users values ($1,$2),($3,$4)',[a,JSON.stringify({name:'Student A',phone:'9876543210'}),b,JSON.stringify({name:'Student B',phone:'9876543211'})]);
check((await db.query('select name from profiles where id=$1',[a])).rows[0].name==='Student A','signup trigger copies metadata into profile');
async function asUser(uid,sql,params=[],commit=false){
 await db.exec('begin;set local role authenticated;');
 try{await db.query("select set_config('request.jwt.claims',$1,true)",[JSON.stringify({sub:uid,role:'authenticated'})]);const result=await db.query(sql,params);await db.exec(commit?'commit':'rollback');return result.rows;}
 catch(e){await db.exec('rollback');throw e;}
}
async function denied(uid,sql,params,message){await assert.rejects(()=>asUser(uid,sql,params),undefined,message);checks++;console.log(`PASS ${message}`);}
await asUser(a,"insert into cart_items(user_id,item_id,quantity) values ($1,'margherita-pizza',1)",[a],true);
await asUser(a,"insert into favorites(user_id,item_id) values ($1,'cold-coffee')",[a],true);
check((await asUser(b,'select * from cart_items where user_id=$1',[a])).length===0,'RLS hides another user cart');
check((await asUser(b,'select * from favorites where user_id=$1',[a])).length===0,'RLS hides another user favorites');
check((await asUser(b,'select * from profiles where id=$1',[a])).length===0,'RLS hides another user profile');
await denied(b,"insert into favorites(user_id,item_id) values ($1,'margherita-pizza')",[a],'RLS rejects writing another user favorite');
await denied(a,'update profiles set has_ordered=true where id=$1',[a],'column grants protect has_ordered');
await denied(a,"select coupon_result($1,'FOOD50',299)",[a],'internal coupon helper is not client callable');
await denied(a,"insert into orders(user_id,subtotal,total,address) values($1,1,1,'Campus')",[a],'client cannot forge orders');
let preview=(await asUser(a,"select preview_coupon(' food50 ') as result"))[0].result;
check(preview.valid&&preview.discount===149&&preview.subtotal===299&&preview.total===150,'first-order coupon trims, ignores case and rounds down');
preview=(await asUser(a,"select preview_coupon('WRONG') as result"))[0].result;
check(!preview.valid&&preview.discount===0,'invalid coupon rejected by SQL');
await denied(a,"select place_order('Campus','WRONG')",[],'invalid checkout coupon aborts order');
check((await asUser(a,'select * from cart_items')).length===1&&(await asUser(a,'select * from orders')).length===0,'failed checkout preserves cart and writes no order');
await denied(a,"select place_order('  ',null)",[],'blank address rejected');
const id=(await asUser(a,"select place_order(' Campus ','FOOD50') as id",[],true))[0].id;
const order=(await asUser(a,'select * from orders where id=$1',[id]))[0];
check(order.subtotal===299&&order.discount===149&&order.total===150&&order.address==='Campus','checkout persists authoritative totals and trimmed address');
check((await asUser(a,'select * from cart_items')).length===0,'checkout clears purchased cart');
check((await asUser(a,'select has_ordered from profiles'))[0].has_ordered,'checkout marks first order used');
check((await asUser(b,'select * from orders where user_id=$1',[a])).length===0,'RLS hides another user orders on direct query');
check((await asUser(b,'select * from order_items where order_id=$1',[id])).length===0,'RLS hides another user order lines');
await db.exec("update menu_items set price=999,name='Changed menu name' where id='margherita-pizza'");
const snapshot=(await asUser(a,'select * from order_items where order_id=$1',[id]))[0];
check(snapshot.price===299&&snapshot.name==='Margherita Pizza','order snapshots survive menu price/name changes');
await asUser(a,"insert into cart_items values($1,'cold-coffee',1)",[a],true);
preview=(await asUser(a,"select preview_coupon('FOOD50') as result"))[0].result;
check(!preview.valid&&preview.message==='FOOD50 is valid only on your first order','repeat first-order coupon rejected');
await denied(a,"select place_order('Campus','FOOD50')",[],'checkout enforces repeat coupon rejection');
check((await asUser(a,'select * from cart_items')).length===1,'rejected repeat coupon leaves cart intact');
await asUser(a,"select place_order('Campus',null)",[],true);
await denied(a,"select place_order('Campus',null)",[],'empty cart rejected by server');
await asUser(b,"insert into cart_items values($1,'margherita-pizza',2)",[b],true);
preview=(await asUser(b,"select preview_coupon('FOOD50') as result"))[0].result;
check(preview.discount===150,'SQL caps first-order discount at 150 rupees');
await db.exec("update menu_items set available=false where id='margherita-pizza'");
await denied(b,"select place_order('Campus',null)",[],'unavailable cart item rejected atomically');
check((await asUser(b,'select * from cart_items')).length===1,'unavailable item failure retains cart');
await db.exec('begin;set local role anon;');
try{await assert.rejects(()=>db.query("select public.preview_coupon('FOOD50')"));checks++;console.log('PASS anonymous role cannot preview coupon');}finally{await db.exec('rollback');}
await db.close();console.log(`Completed ${checks} PostgreSQL checks.`);
