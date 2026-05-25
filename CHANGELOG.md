# Changelog

All notable changes to the Cyprus Tourist Pass plugin will be documented in this file.

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
