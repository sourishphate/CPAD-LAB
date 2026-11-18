# FoodHub entity relationship diagram

```mermaid
erDiagram
  AUTH_USERS ||--|| PROFILES : has
  AUTH_USERS ||--o{ FAVORITES : saves
  AUTH_USERS ||--o{ CART_ITEMS : owns
  AUTH_USERS ||--o{ ORDERS : places
  MENU_ITEMS ||--o{ FAVORITES : saved_item
  MENU_ITEMS ||--o{ CART_ITEMS : cart_item
  ORDERS ||--|{ ORDER_ITEMS : contains
  AUTH_USERS {
    uuid id PK
  }
  PROFILES {
    uuid id PK,FK
    text name
    text phone
    text address
    boolean has_ordered
    timestamptz created_at
  }
  MENU_ITEMS {
    text id PK
    text name
    text description
    integer price
    numeric rating
    text prep_time
    text emoji
    text category
    text type
    boolean bestseller
    boolean offer
    boolean available
  }
  FAVORITES {
    uuid user_id PK,FK
    text item_id PK,FK
    timestamptz created_at
  }
  CART_ITEMS {
    uuid user_id PK,FK
    text item_id PK,FK
    integer quantity
  }
  ORDERS {
    uuid id PK
    uuid user_id FK
    integer subtotal
    integer discount
    integer delivery_fee
    integer total
    text coupon_code
    text address
    text status
    timestamptz created_at
  }
  ORDER_ITEMS {
    uuid id PK
    uuid order_id FK
    text item_id
    text name
    text emoji
    integer price
    integer quantity
  }
```

**auth.users** is managed by Supabase Auth. It owns account identity and password handling. Only its id is shown here; FoodHub never stores passwords in its own tables.

**profiles** extends each Auth user with a name, phone, delivery address, and first-order eligibility flag. The signup trigger creates it. Clients may update only name, phone, and address; checkout owns `has_ordered`.

**menu_items** holds the shared catalogue, whole-rupee price, display metadata, dietary type, and availability. Authenticated clients can read it; menu administration is through the database, with no client write grants.

**favorites** is a many-to-many join between users and menu items. Its composite primary key prevents duplicate favorites. Ownership RLS protects each user's saved list.

**cart_items** joins a user to a menu item with a strictly positive quantity. Its composite primary key supports upsert. Reaching zero deletes the row. RLS isolates each cart.

**orders** records a completed checkout's totals, coupon, delivery address, timestamp, and initial `Placed` status. Only the SQL function creates orders. The user can read their own history.

**order_items** stores purchase-time name, emoji, unit price, quantity, and the source item id. `item_id` deliberately has no menu foreign key: removing or editing a catalogue item cannot rewrite a past purchase. Each line belongs to an order; RLS checks that order's owner.

Indexes support order history by user/date, line lookup by order, and cart lookup by user. Composite primary keys also index favorites and carts.
