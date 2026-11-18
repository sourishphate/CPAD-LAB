# FoodHub — CPAD mini project

**Student:** [fill name and roll number]  
**Institution / course / faculty:** [fill details]  
**Submission date:** [fill date]

## Abstract and problem

FoodHub is a responsive food ordering application built with Flutter and Material 3. It upgrades an existing home-page prototype into an authenticated application with persistent food catalogue, favorites, cart, profile, and order history. Supabase provides Auth, a PostgreSQL database, an auto-generated REST API, Row Level Security, and transactional server-side checkout. This meets the requirement for one CPAD framework and an integrated backend/database.

## Objectives and scope

Users can register, sign in, search and filter food, save favorites, maintain a cart, preview a first-order coupon, place an order, edit their profile, and inspect historical orders. The initial catalogue contains the eight items from the original lab. Orders are recorded with status `Placed`; live delivery tracking, payment gateway integration, restaurant administration, tax calculations, stock counts, and automatic status transitions are outside this mini project's scope. Checkout is a demonstrable order-recording flow with free delivery.

## Technology and architecture

Flutter is the only app framework. Dart models parse database records; services alone use `supabase_flutter`; ChangeNotifier providers manage state; screens compose reusable widgets. Provider was chosen because this project's screens share a relatively small amount of state, making it straightforward to explain and test. `intl` formats order dates. PostgreSQL stores whole-rupee money values, avoiding floating-point monetary arithmetic.

The request path is **Flutter → service/supabase_flutter + user's JWT → Supabase REST API → PostgreSQL RLS and SQL functions → response → Provider → UI**. See [REQUEST_FLOW.md](REQUEST_FLOW.md) for checkout details and [ER_DIAGRAM.md](ER_DIAGRAM.md) for the database design.

## Modules

| Module | Responsibility |
|---|---|
| Authentication | Validated signup/login, visibility toggle, recovery email, session restoration, logout |
| Home | Database-backed catalogue, search, categories, Veg/Non-Veg/Bestseller/Offers filters |
| Favorites | Persistent user-owned saved food; shared cart controls |
| Cart | Positive quantities, deletion, server price/coupon preview, required address, checkout |
| Profile | Name, email, phone, address and profile editing |
| Orders | Nested order/line query, chronological history and purchase snapshots |
| Database | RLS, grants, signup trigger, validation, coupon and atomic order creation |

## Adaptive and responsive design — Lab 3

The orange theme, white rounded cards, emoji boxes, Veg/Non-Veg dot, Best badge, gradient FOOD50 offer banner, and cart badge are retained. LayoutBuilder selects mobile vs tablet at 600 dp. Home uses a scrolling Column and list cards on mobile, and a flex-2 sidebar with a flex-4 grid area on tablet/web. The shell changes bottom navigation to NavigationRail at the same breakpoint. OrientationBuilder surrounds a two-column portrait / three-column landscape grid; MediaQuery reads the device orientation so a narrow right panel cannot misclassify it. Wrap chips flow across available space. Text columns use Expanded, and compact or scrollable card content avoids overflow. Cart uses a stacked mobile layout with pinned checkout bar and a 3:2 two-panel layout on tablet. Profile/order content is centered within 600 dp; desktop authentication forms within 420 dp.

## Security and business rules

Passwords are handled only by Supabase Auth. The public project key belongs in the app; secret/service-role keys never do. Each user's JWT identifies them to PostgreSQL. RLS and column/table grants isolate private records and stop client changes to order data or first-order eligibility. The metadata signup trigger creates profiles. `coupon_result` is an internal-only function, while authenticated clients may call `preview_coupon` and `place_order`.

FOOD50 accepts trimmed case-insensitive input on the first order only, with 50% off capped at ₹150. SQL is the source of truth for coupon validity, discount, subtotal, and final payable total. Preview improves the UI, but checkout recalculates against the database and validates again. Transactional checkout inserts the order and purchase snapshot, clears purchased cart rows and updates the profile together; failure rolls back all changes. Profile locking serializes concurrent checkout. Order-line snapshots protect past orders from future menu edits.

## State, reliability, and limitations

Load/refresh operations expose loading, error, retry and empty states. Quantity and favorite updates are optimistic with rollback and readable errors. Cart requests are serialized in the UI; quote state is invalidated and refreshed after changes. A keyed session creates fresh providers for each user, and generation tokens/disposal guards prevent late requests from leaking prior-session data. No realtime subscriptions are needed for the lab. Different devices can refresh to synchronize; multi-device cart editing is last-write-wins. If connectivity is lost after an order commits but before its response arrives, check order history before retrying; this schema does not add a client idempotency-key table.

## Testing and results

See [MANUAL_TEST_CASES.md](MANUAL_TEST_CASES.md) for complete acceptance scenarios, including two-user isolation, direct-query RLS, first/repeat coupon use, rotation, resizing and failures. Automated tests exercise layouts with service fakes, provider rollback and quote handling, and model snapshots. Run `flutter analyze` and `flutter test`; record actual device and connected Supabase results here after setup. Do not present fake-service tests as proof of a live backend connection.

## Screenshots to add before submission

Capture login/signup, mobile Home, tablet Home/landscape, Favorites, Cart with FOOD50, confirmation, profile editing, history and details. Include Supabase table records and the zero-row RLS test. Avoid exposing access tokens, passwords, database passwords or secret keys.

## Viva preparation

1. **Why use a backend?** Persistent shared menu and per-user data with server-enforced rules; UI state alone cannot protect purchases.
2. **Why RLS and grants?** RLS protects rows; grants restrict operations and columns, including `has_ordered`.
3. **Why SQL checkout?** Modified clients cannot forge prices or coupons, and a transaction prevents partial checkout.
4. **Why copy line prices?** Order history must reflect the actual purchase even after catalogue changes.
5. **Why Provider?** Shared state updates all tabs while services isolate networking and permit focused tests.
6. **Adaptive vs responsive?** Adaptive switches layout/navigation at 600 dp; responsive flex, wraps and Expanded fit content within that layout.
7. **How is a user identified?** Supabase verifies the Auth JWT; PostgreSQL obtains the UUID via `auth.uid()`.
8. **What happens on logout?** Auth ends the session, removes the session subtree and disposes user-specific providers.

## Future work

Possible extensions include online payment verification, an administrator interface, delivery status updates, quantities backed by stock, multi-device synchronization, and checkout idempotency tokens. They are separate from the present lab requirements.
