# Manual test cases

Run after SETUP.md. Record actual results, screenshots, device, date, and pass/fail in your submitted report. These are expected results, not claims that a remote project was already tested.

| # | Action | Expected result |
|---|---|---|
| 1 | Sign up with valid name, email, 10-digit phone, matching passwords | Auth user and profile created; session opens Home, or confirmation message if enabled |
| 2 | Submit invalid email, short password, blank name, bad phone, mismatched confirmation | Field validation prevents submission |
| 3 | Log in with a wrong password | Friendly error; spinner stops; login can be retried |
| 4 | Log in correctly; restart app | Home opens and saved session is restored |
| 5 | Add an item, increase/decrease quantity, remove last unit | Badge, cart, and database match; zero removes row |
| 6 | Toggle a heart on Home; open Favorites; toggle it off | Shared favorite state persists; empty hint shown when none remain |
| 7 | First order, add one ₹299 pizza, apply ` food50 ` | Server returns subtotal 299, discount 149, total 150 |
| 8 | First order with subtotal ≥300, apply FOOD50 | Server discount capped at 150 |
| 9 | Apply `WRONG` | Red server message; discount 0; no coupon applied |
| 10 | Change cart after applying FOOD50 | Old quote invalidated, checkout waits, SQL preview refreshes the discount |
| 11 | Enter an address and place an order | Confirmation; one order with snapshot lines; purchased cart empty; profile flag true |
| 12 | Add food again, apply FOOD50 | `FOOD50 is valid only on your first order`; no discount |
| 13 | Attempt direct place_order RPC with invalid coupon | Rejected; cart remains intact; no order inserted |
| 14 | Empty cart or blank address | Place Order blocked; direct RPC also rejects |
| 15 | Profile → My Orders → order | Correct date, quantities, snapshots, coupon, address, subtotal, discount, total and status |
| 16 | Change menu price/name in SQL Editor after ordering | Old order retains original price and name; refresh menu shows changed catalogue |
| 17 | Edit name, phone, address; restart | Profile and greeting persist; invalid phone is rejected |
| 18 | Log out, then log in as user B | User A's cart, favorites, profile and orders never appear for B |
| 19 | Query A's orders while authenticated as B (see below) | Empty result, even when explicitly requesting A's UUID |
| 20 | Try client update of `profiles.has_ordered`, insert order, or invoke coupon_result | Permission denied |
| 21 | Resize to 320, 375, 599, 600, 800, 1024, 1400 dp | No overflow; bottom navigation below 600; rail and Home sidebar at 600+ |
| 22 | Rotate portrait → landscape on tablet | OrientationBuilder grid changes from 2 to 3 columns; badge updates; controls remain usable |
| 23 | Disconnect Internet, attempt favorite/quantity mutation | Optimistic state rolls back; readable message; retry after reconnect works |
| 24 | Request password reset, open configured web recovery email, save new password | Recovery form opens; new password logs in |
| 25 | Double tap Place Order / send two concurrent first-order RPCs | Button disables; SQL serializes checkout; no duplicate purchased cart or reused first-order coupon |
| 26 | Mark a cart item unavailable in SQL Editor, reload | Delete remains usable; SQL rejects ordering unavailable food without clearing cart |
| 27 | Press Retry after menu/cart/orders load failure | Data reloads without retaining an error indefinitely |

## Prove RLS in SQL Editor

The SQL Editor normally uses an administrator role that bypasses RLS. Create two accounts using the app, copy their real UUIDs from Authentication → Users, and substitute the UUIDs below. Run this as one transaction. `set_config` simulates B's authenticated JWT claims for this test only; the REST API verifies real JWTs and does not let clients select their identity this way.

```sql
begin;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"USER_B_UUID","role":"authenticated"}', true);
select id, user_id, total from public.orders where user_id='USER_A_UUID'::uuid;
-- Expected: zero rows, even if A has placed orders.
select * from public.favorites where user_id='USER_A_UUID'::uuid;
select * from public.cart_items where user_id='USER_A_UUID'::uuid;
-- Expected: zero rows for both queries.
rollback;
```

For a REST demonstration, use B's access token in the Authorization header and the project's public key in `apikey` when calling `/rest/v1/orders?user_id=eq.USER_A_UUID`. Expected JSON: `[]`. Keep access tokens private and out of screenshots/submitted source.
