# Tourist Pass Cyprus

> Exclusive discounts for tourists at local Cypriot merchants — built by [Malaka Cyprus](https://malaka.cy).

**Tourist Pass Cyprus** is a full-stack discount platform that lets tourists with valid car-rental contracts unlock percentage discounts at participating restaurants, hotels, activities, spas and tours across Cyprus. Merchants scan a customer's QR code at the point of sale; the platform splits the payment automatically.

---

## Repository layout

```
Cyprus-Turist-Pass/
├── flutter_app/                  # Cross-platform mobile app (iOS · Android · Web)
│   └── README.md                 # ← Flutter setup & usage guide
├── src/                          # React SPA (legacy frontend reference)
├── server.ts                     # Express dev server
├── prisma/                       # Schema & seed (SQLite dev DB)
└── cyprus-tourist-pass-plugin/   # WordPress REST API plugin (production backend)
```

---

## Products

| Product | Stack | Status |
|---|---|---|
| **Flutter App** | Flutter 3 · Riverpod 2 · go_router | ✅ Active |
| React SPA | React 19 · Vite · Tailwind | Reference / legacy |
| WP REST API | PHP · WordPress · JWT | ✅ Production backend |

---

## Flutter App — quick start

See **[flutter_app/README.md](flutter_app/README.md)** for the full installation, configuration and build guide.

```bash
cd flutter_app
flutter pub get
flutter run --dart-define=API_BASE_URL=https://your-wp-site.com/wp-json
```

---

## React SPA — quick start (dev only)

```bash
npm install
cp .env.example .env.local   # set GEMINI_API_KEY if needed
npm run dev
```

---

## WordPress Plugin

The `cyprus-tourist-pass-plugin/` directory contains the production backend. Install it in any WordPress site:

1. Upload or symlink the folder to `wp-content/plugins/`.
2. Activate **Cyprus Tourist Pass** in *WP Admin → Plugins*.
3. Set the `CTP_JWT_SECRET` constant in `wp-config.php`.

All REST routes are served under `/wp-json/ctp/v1/`.

---

## Changelog

### [2.3.0] - 2026-05-25
- Added: WordPress admin **Flutter App Connection** panel (Dashboard, Settings, Help pages) — auto-generates `API_BASE_URL` from the live site URL with one-click copy buttons for the build and run commands
- Fixed: `process_payment` — any authenticated merchant could process a QR token issued for a different merchant (missing ownership check)
- Fixed: `process_payment` — expired QR tokens were accepted (expiry check existed in `validate_qr` but not here)
- Fixed: `process_payment` — race condition: concurrent requests could double-spend the same token; replaced read-then-write with an atomic `UPDATE WHERE used=0`
- Fixed: `register_user` — merchant validation ran after the user row was inserted, leaving an orphaned row on 400 responses
- Fixed: `update_merchant_profile` — file-upload profile saves always returned 400 "no fields" because `get_json_params()` returns `null` for multipart requests
- Fixed: `admin_customers` — non-aggregated LEFT JOIN returned duplicate rows per customer with multiple contracts
- Fixed: `detect_agency_from_contract` — added static request-level cache to eliminate repeated full-table scans
- Fixed: All `/admin/*` REST routes now use a dedicated `is_admin` permission callback instead of `is_authenticated`
- Fixed (Flutter): `Transaction.fromJson` — hard crash on merchant history tab when `merchantName` is absent
- Fixed (Flutter): `AuthService.login` / `register` — post-login `UserModel` lacked `contract` and `merchantProfile`; now calls `/auth/me` immediately
- Fixed (Flutter): `AuthInterceptor.onError` — `clearAll()` was fire-and-forget; now awaited before GoRouter redirect
- Fixed (Android): `ClassNotFoundException: MainActivity` in release builds — added `-keep class com.malaka.touristpass.**` to ProGuard rules
- Fixed (Android): `ClassNotFoundException: MainActivity` in debug builds — `org.jetbrains.kotlin.android` plugin was declared in `settings.gradle.kts` with `apply false` but never applied to the app module

### [2.2.0] - 2026-05-25
- Added: CORS headers (`Access-Control-Allow-*`) for Flutter web support — OPTIONS preflight handled automatically
- Fixed: `POST /payment/create-qr` now returns `qrToken` (renamed from `token`) and `merchantId`
- Fixed: `POST /payment/validate-qr` now accepts `qrToken` request field (was `token`); response now includes `qrToken` string and `merchantName`
- Fixed: `POST /payment/process` now accepts `qrToken` string (was `qrTokenId` integer); response now includes `status: "COMPLETED"`
- Fixed: `GET /rental/status` returns 404 when no active contract (was 200 with nulls); returns flat `ContractInfo` fields at top level (was nested under `contract` key)
- Fixed: `POST /rental/validate` returns flat `ContractInfo` fields at top level (was nested under `contract` key)
- Fixed: `GET /auth/me` now includes `contract` object for CUSTOMER role users

---

## License

Proprietary — © Malaka Cyprus. All rights reserved.
