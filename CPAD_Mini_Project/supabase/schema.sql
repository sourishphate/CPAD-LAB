-- FoodHub: run this complete, repeatable script in the Supabase SQL Editor.
begin;

-- 1. Tables: money is stored in whole integer rupees.
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null default '', phone text, address text,
  has_ordered boolean not null default false,
  created_at timestamptz not null default now()
);
create table if not exists public.menu_items (
  id text primary key, name text not null, description text not null,
  price integer not null check (price > 0), rating numeric(2,1) not null,
  prep_time text not null, emoji text not null, category text not null,
  type text not null check (type in ('Veg','Non-Veg')),
  bestseller boolean not null default false, offer boolean not null default false,
  available boolean not null default true
);
create table if not exists public.favorites (
  user_id uuid references auth.users(id) on delete cascade,
  item_id text references public.menu_items(id) on delete cascade,
  created_at timestamptz not null default now(), primary key(user_id,item_id)
);
create table if not exists public.cart_items (
  user_id uuid references auth.users(id) on delete cascade,
  item_id text references public.menu_items(id) on delete cascade,
  quantity integer not null check(quantity > 0), primary key(user_id,item_id)
);
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id), subtotal integer not null,
  discount integer not null default 0, delivery_fee integer not null default 0,
  total integer not null, coupon_code text, address text not null,
  status text not null default 'Placed', created_at timestamptz not null default now()
);
-- Purchase snapshots deliberately do not reference the mutable menu item row.
create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  item_id text not null, name text not null, emoji text not null,
  price integer not null, quantity integer not null check(quantity > 0)
);
create index if not exists orders_user_created_idx on public.orders(user_id,created_at desc);
create index if not exists order_items_order_idx on public.order_items(order_id);
create index if not exists cart_items_user_idx on public.cart_items(user_id);

-- 2. Signup trigger: auth owns passwords; profiles contain display details only.
create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles(id,name,phone)
  values(new.id,coalesce(new.raw_user_meta_data->>'name',''),new.raw_user_meta_data->>'phone');
  return new;
end;
$$;
revoke execute on function public.handle_new_user() from public, anon, authenticated;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute function public.handle_new_user();
-- Allow installing the app into a project with pre-existing auth users, too.
insert into public.profiles(id,name,phone)
select id,coalesce(raw_user_meta_data->>'name',''),raw_user_meta_data->>'phone' from auth.users
on conflict(id) do nothing;

-- 3. Privileges and RLS: the JWT selects the caller; the database enforces ownership.
alter table public.profiles enable row level security;
alter table public.menu_items enable row level security;
alter table public.favorites enable row level security;
alter table public.cart_items enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
revoke all on public.profiles,public.menu_items,public.favorites,public.cart_items,public.orders,public.order_items from anon, authenticated;
grant usage on schema public to authenticated;
grant select on public.profiles,public.menu_items,public.favorites,public.cart_items,public.orders,public.order_items to authenticated;
revoke update on public.profiles from authenticated;
grant update(name,phone,address) on public.profiles to authenticated;
grant insert,delete on public.favorites to authenticated;
grant insert,update,delete on public.cart_items to authenticated;

-- A user can read only their own profile.
drop policy if exists profiles_select on public.profiles;
create policy profiles_select on public.profiles for select to authenticated using(id=auth.uid());
-- A user can update their profile; column grants protect has_ordered.
drop policy if exists profiles_update on public.profiles;
create policy profiles_update on public.profiles for update to authenticated using(id=auth.uid()) with check(id=auth.uid());
-- Signed-in users can browse the menu, without changing it.
drop policy if exists menu_select on public.menu_items;
create policy menu_select on public.menu_items for select to authenticated using(true);
-- A user can read only their own favorites.
drop policy if exists favorites_select on public.favorites;
create policy favorites_select on public.favorites for select to authenticated using(user_id=auth.uid());
-- A user can add favorites only for themselves.
drop policy if exists favorites_insert on public.favorites;
create policy favorites_insert on public.favorites for insert to authenticated with check(user_id=auth.uid());
-- A user can remove only their own favorites.
drop policy if exists favorites_delete on public.favorites;
create policy favorites_delete on public.favorites for delete to authenticated using(user_id=auth.uid());
-- A user can read only their own cart.
drop policy if exists cart_select on public.cart_items;
create policy cart_select on public.cart_items for select to authenticated using(user_id=auth.uid());
-- A user can insert cart rows only for themselves.
drop policy if exists cart_insert on public.cart_items;
create policy cart_insert on public.cart_items for insert to authenticated with check(user_id=auth.uid());
-- A user can change only their own cart and cannot transfer its ownership.
drop policy if exists cart_update on public.cart_items;
create policy cart_update on public.cart_items for update to authenticated using(user_id=auth.uid()) with check(user_id=auth.uid());
-- A user can remove only their own cart rows.
drop policy if exists cart_delete on public.cart_items;
create policy cart_delete on public.cart_items for delete to authenticated using(user_id=auth.uid());
-- A user can read only their own orders; only the order function writes them.
drop policy if exists orders_select on public.orders;
create policy orders_select on public.orders for select to authenticated using(user_id=auth.uid());
-- An order's lines are visible only to the owner of that order.
drop policy if exists order_items_select on public.order_items;
create policy order_items_select on public.order_items for select to authenticated using(
  exists(select 1 from public.orders o where o.id=order_items.order_id and o.user_id=auth.uid())
);

-- 4. Coupon rules: internal helper, never callable directly from a client.
create or replace function public.coupon_result(p_uid uuid,p_code text,p_subtotal integer)
returns jsonb language plpgsql security definer set search_path=public as $$
declare v_discount integer;
begin
  if coalesce(trim(p_code),'')='' then
    return jsonb_build_object('valid',false,'discount',0,'message','No coupon entered');
  end if;
  if upper(trim(p_code))<>'FOOD50' then
    return jsonb_build_object('valid',false,'discount',0,'message','Invalid coupon code');
  end if;
  if (select has_ordered from public.profiles where id=p_uid) then
    return jsonb_build_object('valid',false,'discount',0,'message','FOOD50 is valid only on your first order');
  end if;
  v_discount:=least(floor(p_subtotal::numeric*0.5),150)::integer;
  return jsonb_build_object('valid',true,'discount',v_discount,'message','FOOD50 applied');
end;
$$;
revoke execute on function public.coupon_result(uuid,text,integer) from public,anon,authenticated;

-- 5. Server preview: also returns authoritative total, including without a coupon.
create or replace function public.preview_coupon(p_code text) returns jsonb
language plpgsql security definer set search_path=public as $$
declare v_subtotal integer; v_result jsonb;
begin
  if auth.uid() is null then raise exception 'Please sign in again'; end if;
  select coalesce(sum(m.price*c.quantity),0)::integer into v_subtotal
  from public.cart_items c join public.menu_items m on m.id=c.item_id
  where c.user_id=auth.uid() and m.available;
  v_result:=public.coupon_result(auth.uid(),p_code,v_subtotal);
  return v_result || jsonb_build_object('subtotal',v_subtotal,'delivery_fee',0,
    'total',v_subtotal-(v_result->>'discount')::integer);
end;
$$;
revoke execute on function public.preview_coupon(text) from public,anon,authenticated;
grant execute on function public.preview_coupon(text) to authenticated;

-- 6. Checkout: atomic SQL function; a failure rolls back the order AND cart deletion.
-- Lock the profile to serialize two checkout calls and protect first-order eligibility.
create or replace function public.place_order(p_address text,p_coupon text default null)
returns uuid language plpgsql security definer set search_path=public as $$
declare v_uid uuid:=auth.uid(); v_subtotal integer; v_discount integer:=0; v_item_ids text[];
  v_result jsonb; v_order uuid; v_coupon text:=nullif(upper(trim(p_coupon)),'');
begin
  if v_uid is null then raise exception 'Please sign in again'; end if;
  if coalesce(trim(p_address),'')='' then raise exception 'Delivery address is required'; end if;
  perform 1 from public.profiles where id=v_uid for update;
  if not found then raise exception 'Please complete your profile first'; end if;
  -- Lock existing cart and menu rows so snapshots match the charged price and quantity.
  select array_agg(locked.item_id) into v_item_ids from (
    select c.item_id from public.cart_items c join public.menu_items m on m.id=c.item_id
    where c.user_id=v_uid order by c.item_id for update of c for share of m
  ) locked;
  if exists(select 1 from public.cart_items c join public.menu_items m on m.id=c.item_id
    where c.user_id=v_uid and c.item_id=any(v_item_ids) and not m.available) then
    raise exception 'Some items are unavailable. Remove them before ordering';
  end if;
  select coalesce(sum(m.price*c.quantity),0)::integer into v_subtotal
    from public.cart_items c join public.menu_items m on m.id=c.item_id
    where c.user_id=v_uid and c.item_id=any(v_item_ids) and m.available;
  if v_subtotal=0 then raise exception 'Your cart is empty'; end if;
  if v_coupon is not null then
    v_result:=public.coupon_result(v_uid,v_coupon,v_subtotal);
    if not (v_result->>'valid')::boolean then raise exception '%',v_result->>'message'; end if;
    v_discount:=(v_result->>'discount')::integer;
  end if;
  insert into public.orders(user_id,subtotal,discount,delivery_fee,total,coupon_code,address)
    values(v_uid,v_subtotal,v_discount,0,v_subtotal-v_discount,v_coupon,trim(p_address)) returning id into v_order;
  insert into public.order_items(order_id,item_id,name,emoji,price,quantity)
    select v_order,m.id,m.name,m.emoji,m.price,c.quantity
    from public.cart_items c join public.menu_items m on m.id=c.item_id
    where c.user_id=v_uid and c.item_id=any(v_item_ids);
  -- Delete exactly the purchased snapshot (a concurrent new cart row is preserved).
  delete from public.cart_items c using public.order_items oi
    where oi.order_id=v_order and c.user_id=v_uid and c.item_id=oi.item_id;
  update public.profiles set has_ordered=true,address=trim(p_address) where id=v_uid;
  return v_order;
end;
$$;
revoke execute on function public.place_order(text,text) from public,anon,authenticated;
grant execute on function public.place_order(text,text) to authenticated;

-- 7. Original FoodHub menu: no menu data is hardcoded in Flutter.
insert into public.menu_items(id,name,description,price,rating,prep_time,emoji,category,type,bestseller,offer)
values
('margherita-pizza','Margherita Pizza','Classic cheese & fresh basil',299,4.8,'20 min','🍕','Pizza','Veg',true,true),
('cheese-burger','Cheese Burger','Juicy patty with cheddar',199,4.7,'15 min','🍔','Burger','Non-Veg',true,false),
('chicken-biryani','Chicken Biryani','Aromatic basmati rice',249,4.9,'25 min','🍛','Chicken','Non-Veg',true,true),
('hakka-noodles','Hakka Noodles','Stir-fried with veggies',229,4.6,'18 min','🍜','Noodles','Veg',false,false),
('caesar-salad','Caesar Salad','Crisp romaine lettuce',179,4.5,'12 min','🥗','Healthy','Veg',false,false),
('cold-coffee','Cold Coffee','Chilled & frothy blend',149,4.8,'10 min','☕','Coffee','Veg',false,true),
('chocolate-brownie','Chocolate Brownie','Rich molten chocolate',169,4.9,'8 min','🍰','Dessert','Veg',true,false),
('french-fries','French Fries','Crispy & perfectly salted',129,4.7,'10 min','🍟','Snacks','Veg',false,false)
on conflict(id) do update set name=excluded.name,description=excluded.description,price=excluded.price,
rating=excluded.rating,prep_time=excluded.prep_time,emoji=excluded.emoji,category=excluded.category,
type=excluded.type,bestseller=excluded.bestseller,offer=excluded.offer;
commit;

-- Refresh the REST API's schema cache after installing tables and functions.
notify pgrst, 'reload schema';
