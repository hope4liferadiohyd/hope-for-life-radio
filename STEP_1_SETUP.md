# Step 1 setup — Windows

Do these commands inside the project folder. Complete one numbered item before
moving to the next.

## 1. Install project packages

```powershell
flutter pub get
```

This updates `pubspec.lock` to include the authentication package.

## 2. Check the source

```powershell
flutter analyze
```

Do not continue if this reports an error.

## 3. Run the automated tests

```powershell
flutter test
```

## 4. Preview guest mode

```powershell
flutter run
```

Email buttons deliberately show a configuration message in this mode. The
"Continue as guest" button opens the radio home screen.

## 5. Create a separate Supabase project

Create a new project specifically for Hope For Life Radio. Do not reuse the HR
Platform database.

In Supabase, enable Email authentication and keep email confirmation enabled.
Copy only these two client values:

- Project URL
- Publishable key

Never use or paste a `secret` or `service_role` key in a Flutter application.

## 6. Run with real email authentication

Replace the two example values locally and run this as one PowerShell command:

```powershell
flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
```

The same two `--dart-define` values must be supplied later when building the
release APK or App Bundle.

## Expected flow

1. App opens on the branded splash screen.
2. A user can sign in, register, reset a password, or continue as guest.
3. An authenticated session is restored automatically by Supabase.
4. The home screen identifies guest versus signed-in users.
5. Sign out returns to login.
6. Android back displays a close confirmation and stops playback before exit.
