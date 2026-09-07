# Hope For Life Radio

This is the corrected Flutter foundation for the Hope For Life Radio Android app.

## Step 1 includes

- branded splash screen
- email sign in
- listener registration with email verification support
- forgot-password email flow
- guest access
- authentication guard between login and home
- sign out
- Android back-button close confirmation
- safer live-radio state handling
- call-studio dialer without direct-call permission
- focused authentication tests

Email authentication uses Supabase. Configuration is supplied at build time, so
no backend secret is committed to this project. Guest access remains available
when Supabase is not configured.

Follow `STEP_1_SETUP.md` before running the app.

## Not included yet

Background audio, lock-screen controls, the offline Bible, donations, settings,
notifications, admin tools, production app identity, store signing, branded app
icons, and release builds belong to later verified stages.
