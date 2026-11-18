# Implementation validation

Local checks performed on 14 November 2026 with Flutter 3.47.5 / Dart 3.13.4:

- `flutter analyze`: **no issues found**.
- `flutter test`: **12 tests passed**. Includes provider rollback, server-supplied quote values, filter combinations, order snapshot parsing, authentication validation, and all four tabs at 320×640, 600×960, 600×320, 800×400, and 1400×900 logical pixels. NavigationRail destinations are scrolled into view before tapping in the shortest landscape layout.
- `node tool/verify_schema.mjs`: **28 PostgreSQL checks passed** using PGlite (an embedded PostgreSQL test runtime). The test creates isolated mock Auth identities/roles, executes the complete schema twice, and checks signup profiles, two-user RLS isolation, grants, internal-function protection, coupon rounding/cap/eligibility, checkout rollback, unavailable/empty carts, and immutable purchase snapshots.
- `flutter build web`: final release web compilation succeeded. Served the compiled app locally and rendered it in an isolated headless Chrome profile; visual inspection confirmed the expected Supabase setup screen. Screenshot: `build/foodhub-chrome.png`. A separate Chrome development launch had a debugger connection timeout on this machine; this does not affect the verified release render.

These tests use service fakes or isolated PostgreSQL fixtures. They do **not** claim a connection to your hosted Supabase project. Complete SETUP.md and record the live two-account acceptance tests in MANUAL_TEST_CASES.md before submission. No real project key or database password is included in source.

`flutter build apk --debug`: **passed**, producing `build/app/outputs/flutter-apk/app-debug.apk`. The Flutter kernel was compiled after the final source changes. The first build installed missing Android SDK Platform 35 and CMake 3.22.1. The installed Lab9AVD emulator was also booted successfully (`sys.boot_completed = 1`). This machine has 8 GB RAM; running emulator, Chrome, Gradle, and multiple Dart compilers simultaneously caused low-memory delays, so run them sequentially when testing locally. Native runtime startup is checked separately from compilation.
