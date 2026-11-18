# FoodHub setup

FoodHub uses Flutter + Provider + Supabase only. It needs a real Supabase project to log in, fetch food, and place orders. Before configuration it deliberately displays setup instructions instead of fake menu data.

## 1. Create the backend

1. Create a project at [Supabase](https://supabase.com/dashboard). Choose a region near your demo location and keep the database password private. Wait for provisioning.
2. Open **SQL Editor → New query**, paste the entire [supabase/schema.sql](supabase/schema.sql), and run it. It creates six tables, indexes, RLS policies, restricted grants, signup trigger, three business functions, and the original eight menu items. You can run the whole script again. It preserves user data; the seed updates the original menu fields.
3. For a convenient classroom demo, open **Authentication → Sign In / Providers → Email** and turn **Confirm email** off. This is a development choice; enable confirmation for a public app. Existing unconfirmed users may still require confirmation.
4. Open the project's **Connect** dialog or **Settings → API Keys** and copy the project URL and the **public anon key** (legacy JWT), or its public **publishable key**. Dashboard labels may differ. Never copy a secret key or the `service_role` key.

## 2. Configure Flutter

Edit **lib/config/supabase_config.dart**:

```dart
const supabaseUrl = 'https://YOUR_PROJECT_REF.supabase.co';
const supabaseAnonKey = 'YOUR_PUBLIC_ANON_OR_PUBLISHABLE_KEY';
```

These are the only two project values needed by the app. The public key identifies the project; the signed-in user's JWT and PostgreSQL RLS enforce access. No database password belongs in Flutter. `Supabase.initialize` uses the current SDK's `publishableKey` parameter, which accepts the public key; the requested config constant retains the name `supabaseAnonKey`.

Run from the project directory:

```powershell
flutter pub get
flutter analyze
flutter test
flutter devices
```

The lockfile records the resolved SDK-compatible packages. Do a full restart after editing the config.

## 3. Android phone or emulator

Install the Android SDK/platform tools through Android Studio, accept SDK licenses (`flutter doctor --android-licenses`), and check `flutter doctor -v`.

For a phone, enable Developer options and USB debugging, connect USB, accept the trust prompt, then run `flutter devices`. For an emulator, create and launch an Android virtual device in Device Manager (or use `flutter emulators` and `flutter emulators --launch EMULATOR_ID`).

```powershell
flutter run -d DEVICE_ID
flutter build apk --debug
```

Android's main manifest includes the Internet permission for Supabase. Both the development computer and the phone need Internet access for backend calls. No local backend server is required.

## 4. Chrome

```powershell
flutter run -d chrome --web-port 3000
```

Sign up using a real email and a password of at least six characters. If email confirmation is enabled, confirm the email and return to login. Resize the window from 320 to 1400 logical pixels, then test portrait and landscape.

## 5. Password reset and email links

In **Authentication → URL Configuration**, set the development Site URL to `http://localhost:3000` and add that URL to allowed redirects. The reset form calls `resetPasswordForEmail`. Opening the recovery email in the same configured web app creates a recovery session; FoodHub then shows a new-password form. Supabase's default email service has sending limits, so avoid repeatedly requesting emails; configure SMTP for broader use.

For native Android email links, use your deployed web recovery page as the Site URL, or configure an app link/deep link and corresponding allowlisted redirect before demonstrating native email recovery. Normal Android email/password login and ordering do not require deep links. This project uses the web recovery flow as the simplest development default; do not expect localhost email links to work on another device.

## 6. Demo checklist

Run [docs/MANUAL_TEST_CASES.md](docs/MANUAL_TEST_CASES.md) using two different accounts. Read [docs/PROJECT_REPORT.md](docs/PROJECT_REPORT.md), [docs/REQUEST_FLOW.md](docs/REQUEST_FLOW.md), and [docs/ER_DIAGRAM.md](docs/ER_DIAGRAM.md) for documentation and viva preparation. Add your name, roll number, screenshots from your configured app, test observations, and institution details before uploading to Google Classroom.

## Troubleshooting

- Setup screen: fill both constants and restart; hot reload does not initialize Supabase.
- No menu or database error: run the complete SQL script in the same project as the copied keys. Check Internet access and project availability.
- Login rejected: verify the password and email confirmation status. Passwords exist only in Supabase Auth.
- Signup succeeds but no session: confirm the email first. Supabase can hide duplicate signup for privacy; try login or reset password.
- Checkout unavailable: wait for cart requests and the server price preview to finish, then enter an address. A failed preview blocks checkout until retried.
- An unavailable item remains in the cart: remove it using the delete button. SQL rejects unavailable items rather than charging for a partial order.
- Do not test RLS as the SQL Editor's default postgres role: it bypasses RLS. Use the authenticated-role test in the manual checklist.

References: [Flutter Supabase integration](https://supabase.com/docs/guides/getting-started/tutorials/with-flutter), [RLS](https://supabase.com/docs/guides/database/postgres/row-level-security), [database functions](https://supabase.com/docs/guides/database/functions).
