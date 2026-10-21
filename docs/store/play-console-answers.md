# Google Play Console answers

Answers for the Play Console forms, matching what the app really does (release build, version 1.0.0+1). If a feature changes, update this page and the Play forms together.

## Facts the answers rest on

- Release manifest declares **no permissions** (no INTERNET); `android/app/src/main/AndroidManifest.xml`. Only debug/profile builds get INTERNET (Flutter tooling).
- No ads SDK, no analytics, no crash reporting, no sign-in. Dependencies: `shared_preferences`, `intl` (pubspec.yaml).
- Data lives in the app's private SharedPreferences. "Copy Backup" puts plain text on the clipboard only when the user taps it.
- `allowBackup` is not disabled, so Android's own device backup can include the app data if the user has it on.

## Privacy policy

Published (22 Oct 2026) as the home page of the Google Site **TrackFlow**: `https://sites.google.com/view/trackflow`. Put that link in **App content -> Privacy policy**. Play needs a working web link, not a file. The page text is `privacy-policy.html`; edit the site and this file together.

## Terms of use

Second page of the same site: `https://sites.google.com/view/trackflow/terms-of-use` (text: `terms-of-use.html`). Play does not ask for it in a form; put it in the store listing's website field.

## Data safety

| Question | Answer |
| --- | --- |
| Does your app collect or share any of the required user data types? | **No** |
| Is all of the user data collected by your app encrypted in transit? | Not applicable (nothing is transmitted) |
| Do you provide a way for users to request that their data is deleted? | Data never leaves the device; users delete habits in the app or uninstall it |

Reason (if asked): the app has no internet permission. Copying a backup is a user-initiated clipboard action, and Android's device backup is a system feature controlled by the user's settings; neither sends data to the developer.

## Other App content forms

- **Ads:** No, the app does not contain ads.
- **App access:** All functionality is available without special access (no login).
- **Target audience:** 18 and over (simplest; the app is not designed for children).
- **News app / government app / financial features / health features:** No. (It is a general habit tracker; it gives no medical advice and connects to no health service.)
- **Data deletion (account):** Not applicable, the app has no accounts.

## Content rating questionnaire

Category: **Utility, Productivity, Communication or Other**. Every content question is **No**: no violence, sexuality, profanity, controlled substances, gambling, user-generated content shared with others, user-to-user communication, location sharing or digital purchases. Expected rating: the lowest age band in every region.

## Store settings

- App or game: **App**. Category: **Productivity**. Free.
- Countries: owner's choice (all countries is fine; nothing is region-specific).

## Play App Signing

Accept Play App Signing on the first upload (default). The upload key is `trackflow-upload.jks` (see `1 - Signing key/README.txt`); Google keeps the app signing key. The app uses no Google sign-in, so no fingerprint has to be registered anywhere else.
