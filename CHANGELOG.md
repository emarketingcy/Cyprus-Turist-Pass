# Changelog

All notable changes to the Cyprus Tourist Pass plugin will be documented in this file.

## [2.3.6] - 2026-05-25

### Fixed (Web frontend)
- **Contract tab shows form again after validation** — `loadContractStatus()` was doing `state.contract = result.contract` but `GET /rental/status` returns a flat `ContractInfo` object (no nested `contract` key); changed to `state.contract = result`
- **Discover tab redirects to contract form even after contract was validated** — `state.contract` was only populated when the Contract tab was visited; now seeded immediately at login from the `/auth/me` response and from the cached user on page reload so `claimDiscount()` works from any tab
- **Contract validation appears to "refresh" the form** — same root cause as above; form re-rendered because `state.contract` remained `undefined`; fixed by the flat-object assignment change
- **`/auth/me` contract missing `isValid`** — added `'isValid' => true` (and `agencySlug`) to the contract object returned by `GET /auth/me` so the Contract tab correctly renders "Active Contract" when initialized from the login response

## [2.3.5] - 2026-05-25

### Fixed (Web frontend)
- **QR code immediately expired on website** — `new Date(expiresAt)` parsed UTC server timestamps as local time on Cyprus-timezone browsers; added `parseUtcDate()` helper that appends `'Z'` when no timezone offset is present, matching the Flutter fix from v2.3.2
- **Login does not populate contract / merchant profile** — `handleLoginSuccess()` stored `result.user` directly from the login response which lacks `contract` and `merchantProfile`; now calls `/auth/me` immediately after login (same fix as Flutter v2.3.1) with a fallback to `result.user` if the second call fails

## [2.3.4] - 2026-05-25

### Added
- **Demo contract `GE12345`** — permanent, multi-user, never-expires demo contract for presentations and QA. Any number of users can validate it simultaneously; re-validating refreshes the end date to 10 years from now. Recognised in all code paths: registration, pre-check, validate, and WP admin. Contract input screen now shows "Demo: use GE12345 — always valid" helper text.

### Fixed
- **QR code immediately expired (client-side)** — `QrToken._parseExpiry()` now appends `'Z'` before parsing if the server returns a datetime string with no timezone offset, ensuring correct UTC interpretation on Cyprus-timezone devices even before the PHP-side `gmdate()` fix is deployed.

## [2.3.3] - 2026-05-25

### Added (Flutter v1.3.1)
- **Animated splash screen** — replaces the static loading spinner with a full animated intro: logo scales in with elastic overshoot + glow pulse, app name slides up with a fade, tagline fades in, 3-dot sequential pulse loader at the bottom. Native splash is now dismissed immediately on first Flutter frame so the animation is always visible.

## [2.3.2] - 2026-05-25

### Added (Flutter v1.3.0)
- **Admin dashboard** — full native admin panel with Dashboard (stats overview + recent transactions), Merchants (approve / suspend / reject with live status badges), and Transactions (paginated list) tabs; replaces the "Phase 6" placeholder screen

### Fixed
- **Biometric unlock does nothing** — `MainActivity` was extending `FlutterActivity`; `local_auth` requires `FlutterFragmentActivity` to attach the system biometric dialog
- **QR code immediately expired** — PHP `date()` formatted expiry in the server's local timezone without timezone info; Flutter parsed it as device-local time, creating a mismatch. Changed to `gmdate()` + `'Z'` suffix on both `create_qr` and `validate_qr` responses so `DateTime.parse` correctly treats the timestamp as UTC

## [2.3.1] - 2026-05-25

### Fixed (Flutter v1.2.1)
- `MerchantHistoryTab`: transaction rows showed empty merchant name — `Transaction` model now parses `customerName` from WP response and displays it in the merchant history view
- `SettingsTab`: `_initFromProfile()` was called inside `build()` on every frame — moved to `didChangeDependencies()` with a `setState()` so the discount-rate slider renders correctly from the first build
- `QrTab._generate()`: no `mounted` check after `await generate()` — `WakelockPlus.enable()` and `_startTimer()` could be called after the widget was disposed
- `PosTab._triggerFailFeedback()`: missing `mounted` guard after `Future.delayed` — `_flashCtrl.forward()` could fire on a disposed AnimationController
- `auth_screen.dart`: wrong demo merchant email `ocean@merchant.com` corrected to `ocean@cypruspass.com`

## [2.3.0] - 2026-05-25

### Added
- **WordPress admin: Flutter App Connection panel** — visible on Dashboard, Settings, and Help pages. Automatically derives the `API_BASE_URL` from the live WordPress REST URL and provides one-click copy buttons for the `flutter run` and `flutter build apk/ipa` commands. No manual URL hunting required.

### Security
- `process_payment`: added merchant-QR ownership check — any authenticated merchant could previously process a QR token issued for a different merchant (403 now returned on mismatch)
- `process_payment`: added QR expiry check — tokens past `expires_at` were accepted without validation
- All `/admin/*` REST routes: replaced `is_authenticated` permission callback with a dedicated `is_admin` callback; WordPress now rejects non-admin JWTs at the routing layer rather than inside each handler

### Fixed
- `process_payment`: race condition — concurrent requests could double-spend the same QR token; replaced read-then-write pattern with atomic `UPDATE … WHERE used=0`
- `register_user`: merchant business-name validation ran after the user row was inserted, leaving an orphaned row that permanently blocked re-registration with that email
- `update_merchant_profile`: file-upload (multipart/form-data) profile saves always returned 400 "no fields to update" because `get_json_params()` returns null for non-JSON content types; added `get_params()` fallback
- `admin_customers`: non-aggregated LEFT JOIN on `ctp_rental_contracts` produced duplicate rows for customers with multiple valid contracts; replaced with correlated subquery
- `detect_agency_from_contract`: added static request-level cache — function was executing a full `SELECT *` on every call (up to 3× per request)
- Flutter `Transaction.fromJson`: hard crash on merchant history tab — `merchantName` cast as non-nullable String but absent from merchant-side transaction responses
- Flutter `AuthService`: login and register now call `/auth/me` immediately so `UserModel.contract` and `UserModel.merchantProfile` are populated from the first frame
- Flutter `AuthInterceptor`: `clearAll()` was fire-and-forget in `void onError`; changed override to async and awaited before GoRouter redirect fires
- Android: `ClassNotFoundException: com.malaka.touristpass.MainActivity` in release builds — added `-keep class com.malaka.touristpass.**` to ProGuard rules
- Android: `ClassNotFoundException: com.malaka.touristpass.MainActivity` in debug builds — Kotlin Gradle plugin was declared with `apply false` in `settings.gradle.kts` but never applied to the app module in `app/build.gradle.kts`

## [2.0.0] - 2026-03-16

### Added
- **RentalAgency model**: Proper registry for car rental companies (Sixt, GeoDrive, Hertz) with per-agency API config and mock/real toggle
- **AuditLog model**: Tracks admin actions (merchant approvals, fee changes, refunds) for accountability
- **User fields**: `phone`, `isActive` (soft-disable), `lastLoginAt`
- **MerchantProfile fields**: `websiteUrl`, `phoneNumber`, `postalCode`, `operatingHours` (JSON), `stripeOnboardingComplete`, new business types (SHOP, BAR)
- **QrToken fields**: `amount` (pre-fill bill), `usedAt` timestamp, direct Transaction relation
- **Transaction fields**: `currency`, `stripeTransferId`, `paymentMethod`, `refundedAt`, `refundReason`
- **RentalContract fields**: `pickupLocation`, `returnLocation`, RentalAgency foreign key relation
- **PlatformSettings**: `description` field for admin UI context
- `ARCHITECTURE.md` — Full monorepo structure and implementation roadmap
- `CHANGELOG.md` — Version tracking (this file)

### Changed
- Upgraded Prisma schema from flat agency string to relational RentalAgency model
- Expanded Transaction status options: added PROCESSING state
- Merchant discount rate cap raised from 25% to 50% for flexibility

## [1.2.0] - Previous

### Features
- JWT authentication with 3 roles (Customer, Merchant, Admin)
- 20 REST API endpoints
- Vanilla JS SPA frontend
- WordPress admin dashboard
- QR-based discount tokens
- Transaction tracking with financial split
- 6 demo merchants with seed data
- Database reset tool in admin
