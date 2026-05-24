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

## License

Proprietary — © Malaka Cyprus. All rights reserved.
