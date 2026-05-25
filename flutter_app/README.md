# Tourist Pass Cyprus — Flutter App

<p align="center">
  <img src="assets/icons/app_icon.png" width="120" alt="Tourist Pass Cyprus icon" />
</p>

<p align="center">
  <strong>Tourist Pass Cyprus</strong><br/>
  Exclusive discounts at local merchants across Cyprus<br/>
  <em>by <a href="https://malaka.cy">Malaka Cyprus</a></em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter" />
  <img src="https://img.shields.io/badge/Version-1.3.2-4F46E5" />
  <img src="https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web-lightgrey" />
  <img src="https://img.shields.io/badge/Bundle%20ID-com.malaka.touristpass-4F46E5" />
  <img src="https://img.shields.io/badge/Backend-WordPress%20REST%20API-21759B?logo=wordpress" />
</p>

---

## Table of contents

1. [About the app](#about-the-app)
2. [Features](#features)
3. [Tech stack](#tech-stack)
4. [Prerequisites](#prerequisites)
5. [Installation](#installation)
6. [Configuration](#configuration)
7. [Running in development](#running-in-development)
8. [Building for production](#building-for-production)
9. [App icon & splash screen](#app-icon--splash-screen)
10. [Project structure](#project-structure)
11. [API reference](#api-reference)
12. [Roles & routing](#roles--routing)
13. [Biometric authentication](#biometric-authentication)
14. [Web platform notes](#web-platform-notes)
15. [Troubleshooting](#troubleshooting)
16. [Changelog](#changelog)

---

## About the app

Tourist Pass Cyprus is a cross-platform app (iOS, Android, Web) that connects tourists who have rented a car in Cyprus with participating local merchants offering exclusive discounts.

- **Tourists** validate their rental contract, browse merchants, and generate a one-time QR code to redeem discounts at the point of sale.
- **Merchants** use the built-in POS scanner to read the tourist's QR code, enter the bill amount, and process the discounted payment in under 2 seconds.
- **Admins** manage merchants, approve accounts, and configure platform-wide settings from the web portal.

All data flows exclusively through the **WordPress REST API** (`cyprus-tourist-pass-plugin`). No Firebase or third-party BaaS is used.

---

## Features

### Tourist (Customer)
- ✅ Validate rental contract (Hertz, Sixt, GeoDrive, demo codes)
- ✅ Discover approved merchants with live search + category filters
- ✅ Generate a 15-minute QR discount code per merchant
- ✅ Screen wakelock during QR display (max brightness)
- ✅ Transaction history with monthly grouping

### Merchant POS
- ✅ Full-screen QR scanner (`mobile_scanner`) with corner-bracket overlay — **mobile only**
- ✅ < 2 s scan → validate → calculate → process flow
- ✅ Live payment split breakdown (original / discount / platform fee / your payout)
- ✅ Haptic + visual feedback on success and failure (no blocking modals)
- ✅ Torch toggle for low-light environments
- ✅ PENDING-approval guard (scanner locked until admin approves)

### Merchant Settings
- ✅ Shop name and description editing
- ✅ Discount commission slider (5 – 50 %)
- ✅ Logo upload (gallery or camera, max 1 024 px, 85 % quality)
- ✅ Menu / brochure upload (PDF, JPG, PNG) via `multipart/form-data`
- ✅ Instant profile refresh after save

### Auth & Security
- ✅ WordPress JWT login & registration (email / password)
- ✅ Biometric login — Face ID, Touch ID, fingerprint (opt-in per device, mobile only)
- ✅ JWT stored in encrypted storage (Android EncryptedSharedPrefs, iOS Keychain)
- ✅ Automatic session restore on cold start
- ✅ 401 → auto-logout and redirect to login

---

## Tech stack

| Layer | Library | Version |
|---|---|---|
| UI framework | Flutter | 3.x |
| State management | flutter_riverpod | ^2.6.1 |
| Navigation | go_router | ^14.8.1 |
| HTTP client | dio | ^5.7.0 |
| Secure storage | flutter_secure_storage | ^9.2.2 |
| Biometrics | local_auth | ^2.3.0 |
| QR generation | qr_flutter | ^4.1.0 |
| QR scanning | mobile_scanner | ^5.2.3 |
| Image picker | image_picker | ^1.1.2 |
| File picker | file_picker | ^8.1.2 |
| Screen wakelock | wakelock_plus | ^1.2.10 |
| App icon | flutter_launcher_icons | ^0.14.3 |
| Splash screen | flutter_native_splash | ^2.4.3 |
| Date formatting | intl | ^0.19.0 |

### Android build toolchain

| Tool | Version |
|---|---|
| Android Gradle Plugin | 8.9.1 |
| Gradle wrapper | 8.11.1 |
| Kotlin | 2.1.0 |
| Min SDK | 21 (Android 5.0) |
| Compile / Target SDK | Flutter default |

---

## Prerequisites

| Tool | Minimum version | Notes |
|---|---|---|
| Flutter SDK | 3.19.0 | [flutter.dev/install](https://flutter.dev/docs/get-started/install) |
| Dart SDK | 3.3.0 | Bundled with Flutter |
| Xcode | 15+ | iOS / macOS builds only |
| Android Studio | Hedgehog+ | Android builds; also for emulators |
| CocoaPods | 1.13+ | iOS dependency management |
| A WordPress site | — | With `cyprus-tourist-pass-plugin` activated |

---

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/emarketingcy/Cyprus-Turist-Pass.git
cd Cyprus-Turist-Pass/flutter_app
```

### 2. Install Flutter dependencies

```bash
flutter pub get
```

### 3. Add your app icon

Place a **1 024 × 1 024 px PNG** at:

```
flutter_app/assets/icons/app_icon.png
```

### 4. Generate app icons and splash screen

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

### 5. iOS — install CocoaPods

```bash
cd ios && pod install && cd ..
```

---

## Configuration

The app is configured entirely via `--dart-define` flags at build / run time. **No secrets live in the source code.**

| Variable | Description | Example |
|---|---|---|
| `API_BASE_URL` | Root URL of your WordPress site's REST API | `https://yoursite.com/wp-json` |

If the variable is omitted, the app falls back to the placeholder `https://your-wp-site.com/wp-json` and API calls will fail — always supply it.

### WordPress plugin setup

1. Copy `cyprus-tourist-pass-plugin/` to `wp-content/plugins/` on your WP server.
2. Activate **Cyprus Tourist Pass** in *WP Admin → Plugins*.
3. Add to `wp-config.php`:

```php
define( 'CTP_JWT_SECRET', 'your-strong-random-secret-here' );
```

4. Confirm REST routes are accessible:

```
GET https://yoursite.com/wp-json/ctp/v1/merchants
```

---

## Running in development

### Android (emulator or device)

```bash
flutter run \
  --dart-define=API_BASE_URL=https://yoursite.com/wp-json
```

### iOS (Simulator or device)

```bash
flutter run \
  --dart-define=API_BASE_URL=https://yoursite.com/wp-json
```

### Web (Chrome)

```bash
flutter run -d chrome \
  --dart-define=API_BASE_URL=https://yoursite.com/wp-json
```

> Note: QR scanning and biometric login are **not available** in the browser. All other features work normally on web.

### Using a local WordPress (ngrok / tunnel)

```bash
ngrok http 80

flutter run \
  --dart-define=API_BASE_URL=https://xxxx.ngrok.io/wp-json
```

### Demo accounts

| Role | Email | Password |
|---|---|---|
| Tourist | `tourist@example.com` | `password123` |
| Merchant | `ocean@merchant.com` | `password123` |
| Admin | `admin@cypruspass.com` | `password123` |

> Demo accounts only work when the WP plugin's seed data has been loaded.

---

## Building for production

### Android — debug APK (for testing on a device)

```bash
flutter build apk --debug \
  --dart-define=API_BASE_URL=https://yoursite.com/wp-json
```

Output: `build/app/outputs/flutter-apk/app-debug.apk`

Install directly on a connected device:

```bash
adb install build/app/outputs/flutter-apk/app-debug.apk
```

### Android — release APK

```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=https://yoursite.com/wp-json
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

> Release builds require a signing keystore. See [Android signing](#android-signing) below.

### Android — App Bundle (Play Store)

```bash
flutter build appbundle --release \
  --dart-define=API_BASE_URL=https://yoursite.com/wp-json
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS — Archive (App Store)

```bash
flutter build ipa --release \
  --dart-define=API_BASE_URL=https://yoursite.com/wp-json
```

Then open `build/ios/archive/Runner.xcarchive` in Xcode and distribute via Organizer.

### Web

```bash
flutter build web --release \
  --dart-define=API_BASE_URL=https://yoursite.com/wp-json
```

Output: `build/web/` — deploy to any static host, CDN, or Firebase Hosting.

---

### Android signing

1. Create a keystore:

```bash
keytool -genkey -v \
  -keystore ~/upload-keystore.jks \
  -alias upload \
  -keyalg RSA -keysize 2048 -validity 10000
```

2. Create `android/key.properties`:

```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=upload
storeFile=<path-to>/upload-keystore.jks
```

3. Update `android/app/build.gradle.kts` to reference `key.properties` in the `signingConfigs` block.

---

## App icon & splash screen

The icon and splash are generated from a single source image:

- [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons) — adaptive icons for Android, standard icons for iOS, favicon + web manifest.
- [`flutter_native_splash`](https://pub.dev/packages/flutter_native_splash) — native dark (`#0F172A`) launch screen for Android 12+ and iOS.

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

Config lives in [`pubspec.yaml`](pubspec.yaml) under `flutter_launcher_icons:` and `flutter_native_splash:`.

---

## Project structure

```
flutter_app/
├── lib/
│   ├── main.dart                         # Entry point — ProviderScope, splash, orientation
│   ├── app.dart                          # MaterialApp.router + light/dark themes
│   │
│   ├── core/
│   │   ├── constants/api_constants.dart  # All WP API route strings + storage keys
│   │   ├── network/
│   │   │   ├── api_client.dart           # Dio singleton, error mapper
│   │   │   └── auth_interceptor.dart     # JWT Bearer injection + 401 auto-logout
│   │   ├── storage/secure_storage.dart   # Encrypted JWT + biometric preference
│   │   └── theme/app_theme.dart          # AppColors tokens + light/dark ThemeData
│   │
│   ├── router/app_router.dart            # go_router with role-based redirect guard
│   │
│   └── features/
│       ├── auth/
│       │   ├── models/user_model.dart    # UserModel, MerchantProfile, ContractInfo
│       │   ├── providers/auth_provider.dart  # AuthNotifier, AuthChangeNotifier
│       │   ├── screens/auth_screen.dart  # Login / Register + biometric lock screen
│       │   └── services/
│       │       ├── auth_service.dart     # login, register, getMe
│       │       └── biometric_service.dart  # local_auth wrapper (mobile only)
│       │
│       ├── customer/
│       │   ├── models/                   # Merchant, QrToken, Transaction
│       │   ├── providers/                # contract, merchant list, QR, transactions
│       │   ├── services/customer_service.dart
│       │   └── screens/
│       │       ├── customer_app.dart     # 4-tab scaffold + biometric setup sheet
│       │       └── tabs/
│       │           ├── validate_tab.dart # Contract validation
│       │           ├── discover_tab.dart # Merchant discovery + search
│       │           ├── qr_tab.dart       # QR generation + countdown + wakelock
│       │           └── history_tab.dart  # Transaction history
│       │
│       └── merchant/
│           ├── models/                   # ValidatedQr, PaymentResult, PosState
│           ├── providers/                # PosNotifier, settings, transactions
│           ├── services/merchant_service.dart
│           └── screens/
│               ├── merchant_app.dart     # Dark 3-tab scaffold
│               └── tabs/
│                   ├── pos_tab.dart      # QR scanner + state machine (mobile only)
│                   ├── merchant_history_tab.dart
│                   └── settings_tab.dart # Logo, discount %, menu upload
│
├── web/
│   ├── index.html                        # Web entry point
│   └── manifest.json                     # PWA manifest
│
├── android/
│   └── app/
│       ├── build.gradle.kts              # AGP 8.9.1, minSdk 21
│       └── src/main/AndroidManifest.xml  # CAMERA, BIOMETRIC, WAKE_LOCK permissions
│
├── ios/
│   └── Runner/Info.plist                 # com.malaka.touristpass, NSFaceIDUsageDescription
│
├── assets/
│   ├── icons/app_icon.png                # 1024×1024 source icon
│   └── images/                           # Static images (placeholder)
│
├── pubspec.yaml                          # All dependencies + icon/splash config
└── analysis_options.yaml                 # Lint rules
```

---

## API reference

All endpoints are under `{API_BASE_URL}/ctp/v1/`. Authenticated routes require `Authorization: Bearer <jwt>`.

### Authentication

| Method | Path | Auth | Description |
|---|---|---|---|
| `POST` | `/auth/login` | — | Email + password login |
| `POST` | `/auth/register` | — | Register tourist or merchant |
| `GET` | `/auth/me` | ✅ | Get current user + profile |

### Rental (Tourist)

| Method | Path | Auth | Description |
|---|---|---|---|
| `POST` | `/rental/validate` | ✅ | Validate a rental contract number |
| `GET` | `/rental/status` | ✅ | Get the current active contract |

### Merchants

| Method | Path | Auth | Description |
|---|---|---|---|
| `GET` | `/merchants` | ✅ | List approved merchants (`?search=&type=&city=`) |
| `GET` | `/merchants/{id}` | ✅ | Get a single merchant |
| `PUT` | `/merchants/profile` | ✅ | Update own merchant profile (multipart/form-data) |

### Payment

| Method | Path | Auth | Description |
|---|---|---|---|
| `POST` | `/payment/create-qr` | ✅ | Generate a 15-min QR token |
| `POST` | `/payment/validate-qr` | ✅ | Validate a customer's QR |
| `POST` | `/payment/process` | ✅ | Process payment |
| `GET` | `/payment/transactions` | ✅ | Get own transaction history |

### Admin

| Method | Path | Auth | Description |
|---|---|---|---|
| `GET` | `/admin/stats` | ✅ Admin | Platform statistics |
| `GET` | `/admin/merchants` | ✅ Admin | All merchants |
| `PUT` | `/admin/merchants/{id}/status` | ✅ Admin | Approve / reject / suspend |

### Demo contract prefixes

| Prefix | Agency |
|---|---|
| `TEST` | Demo — always valid, 7-day window |
| `HZ` | Hertz simulation |
| `SX` / `SIXT` | Sixt simulation |
| `GEO` | GeoDrive simulation |

---

## Roles & routing

```
Unauthenticated  ──────────────────────────▶  /auth  (login / register)
                                                  │
                          ┌───────────────────────┼───────────────────────┐
                          ▼                       ▼                       ▼
                       CUSTOMER               MERCHANT                  ADMIN
                      /customer              /merchant               /admin (*)
                    (Tourist App)         (Merchant POS)
```

> (*) Admin screen is scaffolded — full UI planned in a future phase.

The `go_router` redirect guard enforces role boundaries: a MERCHANT JWT can never access `/customer` and vice-versa.

---

## Biometric authentication

Biometric login is **opt-in** and **mobile only** (iOS / Android). It is automatically disabled on web.

After a successful email/password login, the app shows a one-time prompt:

```
"Enable Face ID / Fingerprint for faster sign-in?"
→ Enable  /  Not now
```

Once enabled:

1. On next cold start the app detects the stored JWT and shows the biometric prompt automatically.
2. Successful authentication → session is restored via `GET /auth/me`.
3. If the user dismisses or biometric fails → tap **"Use password instead"** (stored JWT is cleared for security).

---

## Web platform notes

The web build is fully functional except for two hardware-dependent features:

| Feature | Mobile | Web |
|---|---|---|
| QR scanning (POS) | ✅ `mobile_scanner` | ❌ Shows "not available in browser" |
| Biometric login | ✅ Face ID / Fingerprint | ❌ Silently skipped (password only) |
| QR code display | ✅ | ✅ |
| File / logo upload | ✅ | ✅ |
| All API features | ✅ | ✅ |

The web build is PWA-ready (`manifest.json` included).

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `API_BASE_URL not set` | Always pass `--dart-define=API_BASE_URL=...` when running or building |
| iOS build fails with CocoaPods error | Run `cd ios && pod install --repo-update` |
| Camera permission denied on Android | Grant `CAMERA` permission at runtime when prompted |
| Biometric prompt does not appear | Device must have biometrics enrolled in system settings |
| `MobileScanner` black screen on iOS Simulator | Simulator does not support the camera — use a physical device for QR scanning |
| App icon not updating | Run `dart run flutter_launcher_icons` then `flutter clean && flutter pub get` |
| Splash screen not updating | Run `dart run flutter_native_splash:create` then `flutter clean` |
| Multipart upload returns 400 | Confirm the WP plugin handles `$_FILES['logo']` and `$_FILES['menu']` |
| Gradle `Could not delete caches-jvm` | Run `rm -rf ~/Development/flutter/packages/flutter_tools/gradle/build` then `flutter clean` |
| `Manifest merger failed: usesCleartextTraffic` | Check `debug/AndroidManifest.xml` — should NOT set `usesCleartextTraffic` |

---

## Changelog

### v1.3.2 (2026-05-25)
- Added: Demo contract **GE12345** — always valid, never expires, any number of users can use it simultaneously; helper text shown on the contract input screen
- Fixed: QR code immediately expired — `_parseExpiry()` treats bare datetime strings as UTC (appends `'Z'`), matching server behavior on Cyprus-timezone phones

### v1.3.1 (2026-05-25)
- Added: **Animated splash screen** — logo elastic scale-in + glow, title slide-up, tagline fade, 3-dot pulse loader; native splash dismissed on first frame so the animation is always seen

### v1.3.0 (2026-05-25)
- Added: Full **Admin Panel** (Dashboard, Merchants, Transactions tabs) replacing the Phase 6 placeholder
- Fixed: **Biometric authentication** — `MainActivity` changed from `FlutterActivity` to `FlutterFragmentActivity`; system biometric dialog now attaches correctly
- Fixed: **QR code immediately expired** — server now returns expiry as explicit UTC (`Z` suffix); Flutter's `DateTime.parse` no longer misinterprets it as device-local time

### v1.2.1 (2026-05-25)
- Fixed: `MerchantHistoryTab` showed blank name — `Transaction` model now parses `customerName` from API response and displays it for merchant-side transactions
- Fixed: `SettingsTab` discount-rate slider initialized to wrong value — `_initFromProfile()` moved to `didChangeDependencies()` with `setState()` so the slider reflects the saved rate from the first frame
- Fixed: `QrTab._generate()` missing `mounted` guard after async gap — `WakelockPlus.enable()` and `_startTimer()` could run on a disposed widget
- Fixed: `PosTab._triggerFailFeedback()` missing `mounted` guard after `Future.delayed` — `_flashCtrl.forward()` could fire on a disposed `AnimationController`
- Fixed: Wrong demo merchant email in login screen (`ocean@merchant.com` → `ocean@cypruspass.com`)

### v1.2.0 (2026-05-25)
- Fixed: `ClassNotFoundException: MainActivity` on both debug and release builds — Kotlin plugin (`org.jetbrains.kotlin.android`) was missing from `app/build.gradle.kts`; ProGuard rule added to prevent R8 stripping the class in release
- Fixed: `Transaction.fromJson` crash on merchant history tab — `merchantName` is absent from merchant-side API responses; made field nullable with empty-string fallback
- Fixed: After login / register, `UserModel.contract` and `UserModel.merchantProfile` were null until next session restore; service now calls `/auth/me` immediately post-login
- Fixed: `AuthInterceptor` — `clearAll()` was unawaited on 401 response; storage now fully cleared before GoRouter redirect fires
- Added: WordPress admin Settings page now shows a **Flutter App Connection** panel with auto-generated `API_BASE_URL` and one-click copy for build/run commands — no more manual URL configuration

### v1.1.0 (2026-05-24)
- Add web platform support (`web/` directory, `manifest.json`, PWA config)
- Guard `mobile_scanner` and `local_auth` behind `kIsWeb` — graceful degradation in browser
- Bump Android Gradle Plugin 8.3.2 → 8.9.1
- Bump Gradle wrapper 8.4 → 8.11.1
- Fix `canvas.drawLine` missing `Paint` argument in `_ScanFramePainter`
- Fix `Transaction.merchantPayout` undefined — use `finalAmount` in merchant history
- Fix `_buildContractCard` untyped parameter — add `ContractInfo` type + import
- Fix `async void _triggerFailFeedback` → `Future<void>`
- Fix null-unsafe `== true` guards on `firstName`/`businessName` → `?? false`
- Add `?? 0` fallbacks on `discountRate` JSON casts
- Fix `debug/AndroidManifest.xml` manifest merger conflict on `usesCleartextTraffic`
- Create missing `assets/images/` directory

### v1.0.0 (initial)
- Phases 1–5: Auth, Tourist App, Merchant POS, Merchant Settings
- Biometric login (Face ID / Fingerprint)
- Full Android platform scaffolding (v2 embedding)

---

## Built by

**Malaka Cyprus** · [malaka.cy](https://malaka.cy)

---

*© Malaka Cyprus. All rights reserved.*
