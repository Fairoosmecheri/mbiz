# Build Instructions — Pocket Arcade

This document covers everything needed to build, run and release the app.

---

## 1. Prerequisites

| Tool | Version |
|------|---------|
| Flutter SDK | ≥ 3.29.0 (stable channel) |
| Dart SDK | ≥ 3.7.0 (bundled with Flutter) |
| Android Studio / Android SDK | Platform 34, Build-Tools 34, minSdk 23 |
| Xcode (iOS, optional) | 15+ |
| A device or emulator/simulator | — |

Verify your environment:

```bash
flutter doctor -v
```

---

## 2. First-time setup

This repository commits the **Flutter source** (`lib/`, `pubspec.yaml`,
`test/`, `assets/`) and the **customised native files** that carry app-specific
configuration:

- `android/app/src/main/AndroidManifest.xml` — AdMob App ID, permissions
- `android/app/build.gradle`, `android/settings.gradle`, … — Gradle config
- `ios/Runner/Info.plist` — AdMob App ID, ATT prompt

It does **not** commit machine-generated native scaffolding (Gradle wrapper
JAR, launcher icon PNGs, the iOS `Runner.xcodeproj`, `.gitignore`d build dirs).
Generate those once with:

```bash
flutter create .
```

`flutter create .` is non-destructive: it fills in the missing scaffolding and
leaves the committed files above untouched (it never overwrites `lib/`).

Then fetch dependencies:

```bash
flutter pub get
```

---

## 3. Run (debug)

```bash
flutter devices            # list available targets
flutter run                # run on the default device
flutter run -d emulator-5554
```

Debug builds automatically use Google's **test** AdMob unit ids, so you can
exercise banners and rewarded ads safely.

---

## 4. Release build

### Android

```bash
# APK (sideload / testing)
flutter build apk --release

# App Bundle (Google Play)
flutter build appbundle --release
```

Output:
- `build/app/outputs/flutter-apk/app-release.apk`
- `build/app/outputs/bundle/release/app-release.aab`

#### Signing for Play Store

1. Create an upload keystore:
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks \
     -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Create `android/key.properties` (git-ignored):
   ```properties
   storePassword=********
   keyPassword=********
   keyAlias=upload
   storeFile=/Users/you/upload-keystore.jks
   ```
3. Wire it into `android/app/build.gradle` (replace the
   `signingConfig = signingConfigs.debug` line in the `release` block with a
   real `signingConfigs.release` that reads `key.properties`).

### iOS

```bash
flutter build ipa --release
```

Open `ios/Runner.xcworkspace` in Xcode to configure signing & capabilities,
then Archive and upload via Xcode/Transporter.

---

## 5. Configure AdMob (before publishing)

1. Create AdMob ad units in the AdMob console.
2. Replace the production ids in
   `lib/core/constants/ad_constants.dart`.
3. Replace the **App IDs**:
   - Android: `android/app/src/main/AndroidManifest.xml`
     (`com.google.android.gms.ads.APPLICATION_ID`)
   - iOS: `ios/Runner/Info.plist` (`GADApplicationIdentifier`)

The values currently in the repo are Google's official **sample** ids.

---

## 6. Configure In-App Purchases (Remove Ads)

1. Define a non-consumable product with id `remove_ads` in Play Console /
   App Store Connect.
2. Implement a real `PurchaseService` backed by the `in_app_purchase` plugin
   (the interface is in `lib/core/services/purchase_service.dart`).
3. Swap `MockPurchaseService` for it in `lib/core/di/providers.dart`.

---

## 7. Connect a real backend (optional)

1. Add Firebase to the project (`flutterfire configure`).
2. Implement a Firestore-backed `FirebaseService`
   (`lib/core/services/firebase_service.dart`).
3. Swap `MockFirebaseService` in `lib/core/di/providers.dart`.

No UI or domain code changes are required — everything depends on the
`FirebaseService` interface.

---

## 8. Tests & analysis

```bash
flutter analyze
flutter test
```

---

## Troubleshooting

- **`flutter.sdk not set in local.properties`** — run `flutter pub get` (or
  `flutter create .`) which generates `android/local.properties`.
- **Missing launcher icons / Gradle wrapper** — you skipped `flutter create .`
  (Step 2).
- **AdMob crash on startup** — the AdMob App ID in the manifest/plist is
  missing or malformed.
