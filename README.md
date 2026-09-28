# TrackFlow ⚡

> **Zero-Bloat, High-Density Habit & Ritual Engine**  
> *100% Offline • Zero Analytics • Zero Cloud Dependence • Built for Relentless Consistency*

---

## ✨ Philosophy & Highlights

TrackFlow is engineered for people who value speed, spatial density, and absolute privacy. Unlike mainstream habit trackers with subscription paywalls, intrusive cloud syncs, and sluggish modals, TrackFlow delivers:

- **1-Tap Direct Toggling**: Boolean habits complete in a single tap right from the card.
- **Zero-Modal Inline Stepper**: Measurable habits (glasses of water, pages read, coding minutes) adjust directly on the card with instant visual progress bars.
- **Micro 7-Day History Matrix**: Every single habit card displays the last 7 weekdays `[M][T][W][T][F][S][S]` with 1-tap retrospective logging.
- **Three Perspective Views**:
  - **🌅 Today's Flow**: Grouped into rituals (*Morning*, *Deep Work & Mastery*, *Evening Wind-Down*, *Anytime*).
  - **📊 7-Day Matrix**: High-density spreadsheet-style multi-day matrix for reviewing habit streaks across the week.
  - **🟩 365-Day Contribution Canvas**: Custom 60fps GitHub-style annual heatmap supporting habit filtering and daily intensity inspection.
- **🛡️ 100% Offline & Private**: Zero network permissions declared in `AndroidManifest.xml`. Your habits never leave your phone storage.
- **💾 Encrypted/Plain JSON Backup**: 1-tap offline export and restore directly to clipboard or file.

---

## 📱 Screenshots & Views

| Today's Flow | 7-Day Matrix | 365-Day Canvas |
|:---:|:---:|:---:|
| Grouped by Rituals with Inline Steppers | Spreadsheet-style Multi-Day Matrix | 53-Week Annual Contribution Grid |

---

## 🏗️ Architecture & Technology Stack

- **Framework**: Flutter 3.x (Dart 3.x)
- **Design Tokens**: OLED Deep Charcoal (`#080C14`), Slate Surfaces (`#0F172A`), Emerald Neon (`#10B981`)
- **State & Local Persistence**: Encrypted local storage with `SharedPreferences` + immutable entity state
- **Rendering**: Custom 60fps `CustomPainter` for the 53-week x 7-day contribution canvas

---

## 🚀 Building & Running

### Prerequisites
- Flutter SDK (>= 3.29.0)
- Android SDK (API 34+)

### Run in Debug Mode
```bash
flutter pub get
flutter run
```

### Build Split-ABI Release APK
```bash
flutter build apk --release --split-per-abi
```
The output APKs are located at `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`.

### Run Test Suite
```bash
flutter test
```

---

## 📄 License
MIT License. Built with craft.
