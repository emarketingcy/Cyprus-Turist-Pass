# App Icon & Splash

Place a **1024×1024 px PNG** named `app_icon.png` in this directory.

## Design spec
- Background: `#0F172A` (slate-900) — matches splash colour
- Foreground: Your Malaka Cyprus / Tourist Pass Cyprus logo mark in white + indigo-500 (#6366F1)
- Safe zone: logo within central 640×640 px circle (adaptive icon inset)

## Source art
Import the existing Malaka Cyprus logo from the React app or www.malaka.cy.
Convert to a square, composited on the dark background.

## Generate icons & splash after adding the PNG
```bash
cd flutter_app
flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```
