# FoodHub — CPAD Mini Project

A Flutter food ordering app using Material 3, Provider, and Supabase Auth/PostgreSQL. Includes Home, Favorites, Cart, Profile, order history, server-side FOOD50 validation, transactional checkout, and RLS data isolation.

Start with [SETUP.md](SETUP.md). Configure the Supabase URL and public anon/publishable key in `lib/config/supabase_config.dart`, run `supabase/schema.sql` in your Supabase project, then run `flutter pub get` and `flutter run`.

The app displays a setup screen until configured. There is no fake backend or hardcoded menu in Flutter.

Project documentation:

- [Project report and viva preparation](docs/PROJECT_REPORT.md)
- [Database ER diagram](docs/ER_DIAGRAM.md)
- [Request flow and security](docs/REQUEST_FLOW.md)
- [Manual acceptance tests](docs/MANUAL_TEST_CASES.md)

Run `flutter analyze` and `flutter test` for automated Flutter checks. See `tool/verify_schema.mjs` for optional embedded PostgreSQL verification of the SQL script. These local checks supplement the two-account test against your configured Supabase project.
