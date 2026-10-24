# 14-day closed test on Google Play

New personal developer accounts must run a closed test before they can publish to production. When this was written the rule was: **at least 12 testers opted in, continuously, for the last 14 days**. Google changes this rule from time to time, so check the current text before you start: https://support.google.com/googleplay/android-developer/answer/14151465

## What is already done

- Signed release bundle `trackflow-1.0.0+1.aab` (upload key, version 1.0.0, code 1).
- Store listing text, privacy policy text, Data safety and content rating answers (`listing-en.md`, `privacy-policy.html`, `play-console-answers.md`).
- App icon 512, feature graphic 1024 x 500 and phone screenshots.

## Internal testing first (optional, 10 minutes)

Before the 14-day closed test you can upload the same bundle to **Testing -> Internal testing**. It has no Google review and is available within minutes to up to 100 testers (add your own email). Install it from the Play Store on your phone and check that it opens and your data survives. It does **not** count toward the 14 days.

## Steps in Play Console (owner)

1. **Create app**: name "TrackFlow: Habit Tracker", default language English, App, Free; accept the declarations.
2. **Privacy policy** is published at https://sites.google.com/view/trackflow-app; fill **App content** with `play-console-answers.md`.
3. **Store listing**: paste `listing-en.md`, upload the icon, feature graphic and screenshots.
4. **Testing -> Closed testing -> Create track** (or use "Alpha"). Countries: same as you plan for production.
5. **Testers**: create an email list (or a Google Group) with **at least 15 people** (a buffer above 12: anyone who opts out during the 14 days breaks the count). Each tester needs a Google account on an Android phone.
6. **Create release**: upload `trackflow-1.0.0+1.aab`, accept Play App Signing, release name `1.0.0 (1)`, release notes below. Review and **roll out** to the closed track. The first review can take a few days.
7. **Share the opt-in link** (Testers tab) with every tester. They must open it, tap "Become a tester", then install TrackFlow from the Play Store, and **keep it installed for 14 days**.
8. Day 15 or later: **Dashboard -> Apply for production**. Google asks how testers used the app and what you changed; the feedback log below is the answer.

### Release notes (en-US, max 500)

First test release of TrackFlow. Please use it daily: add 3 or more habits, check them off, try the 7-Day Matrix and the 365-Day Canvas, and tell us anything that looks wrong or confusing.

## Message to testers (copy and send)

> Hi! I'm testing my new habit tracker app, TrackFlow, on Google Play and need your help for 14 days.
> 1. Open this link on your Android phone and tap "Become a tester": <OPT-IN LINK>
> 2. Install TrackFlow from the Play Store link on that page.
> 3. Keep it installed for 14 days and use it a few times. Add 2-3 habits and check them off.
> 4. Reply to me with anything that felt wrong, slow or confusing.
> Thank you!

## What testers should try (and what to note)

- Create a yes/no habit and a measurable one (e.g. 8 glasses of water); check them off; use + and -.
- Set a habit to repeat only on some weekdays; see that rest days do not break the streak.
- Toggle a past day in the 7-day strip; open the 7-Day Matrix and the 365-Day Canvas.
- Delete a habit and press Undo.
- Copy a backup, then restore it (Settings icon -> Backup & Restore).
- Rotate the phone; use large text in phone settings.

## Feedback log (keep this for the production application)

| Date | Tester | What they reported | What changed (version) |
| --- | --- | --- | --- |
| | | | |

## Uploading a fixed build during the test

Raise the number after `+` in `pubspec.yaml` (1.0.0+2, 1.0.0+3, ...), build `flutter build appbundle --release`, upload it to the **same closed track**. Testers stay opted in; the 14 days keep counting.
