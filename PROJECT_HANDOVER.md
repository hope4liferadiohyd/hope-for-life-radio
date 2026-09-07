# Hope For Life Radio — Project Handover

Last updated: 2026-09-07

## Project goal

Build a smooth Flutter application for Android, iOS, and web containing:

1. Live Hope For Life Christian radio
2. Daily Bible verses based on the user's selected language
3. Bible text in English, Telugu, and Hindi
4. Legally licensed audio Bible
5. Bible search, bookmarks, highlights, and last-read position
6. Font scaling, dark mode, language settings, and sleep timer
7. Prayer requests, testimonies, studio calling, and sharing
8. Privacy, account deletion, accessibility, and store-compliance features

## Working rules

- Guide the owner one small step at a time.
- Assume the owner is a complete beginner.
- Do not provide several commands simultaneously.
- Explain errors honestly without sugarcoating.
- Protect API keys and personal information.
- Never add Bible text or audio from an unlicensed source.
- Run Flutter analysis and tests after every meaningful phase.

## Current environment

- Flutter SDK: C:\Users\nsgki\develop\flutter
- Project: C:\Users\nsgki\develop\hope_for_life_radio
- Flutter: 3.47.2 stable
- Dart: 3.13.2
- Repository: https://github.com/hope4liferadiohyd/hope-for-life-radio
- Branch: main

## Completed

- Flutter dependencies installed successfully.
- flutter analyze completed with no issues.
- All three existing Flutter tests passed.
- Application opened successfully in Chrome.
- Splash, login, registration, forgot-password, guest access, and radio foundation exist.
- Git repository initialized and pushed to GitHub.
- Secret-file exclusions added to .gitignore.
- Bible Brain API-key application submitted successfully.

## Legal Bible provider

Primary provider: Bible Brain by Faith Comes By Hearing.

Rules:

- Bible content must remain free to end users.
- Required copyright and provider notices must be displayed.
- Content must be accessed according to fileset permissions.
- Offline downloads are prohibited unless specifically permitted.
- Never commit the Bible Brain API key to GitHub.
- API.Bible may be considered later as a licensed text fallback.

## Current limitation

Bible Brain is reviewing the API-key request and may take up to one week. Exact English, Telugu, and Hindi text/audio filesets cannot be confirmed until access is approved.

## Next development task

Build a smoother multilingual home interface containing:

- English, Telugu, and Hindi language selector
- Daily Verse card with legal-provider loading states
- Improved live-radio card and playback feedback
- Responsive navigation
- Accessibility-friendly controls
- No unlicensed Bible text

Do not begin full Bible or audio download functionality until provider permissions are confirmed.
