# StockSense Frontend (Flutter)

## Setup

```bash
flutter pub get
flutter run
```

Then update `lib/config/api_config.dart` with your backend URL:
- Android emulator → `http://10.0.2.2:5000/api` (already set as default)
- iOS simulator → `http://localhost:5000/api`
- Physical device → `http://<your-machine-LAN-IP>:5000/api`
- Deployed backend → your live URL, e.g. `https://your-app.onrender.com/api`

## IMPORTANT: Android internet permission

After `flutter create` regenerates `android/`, make sure
`android/app/src/main/AndroidManifest.xml` has this inside the `<manifest>` tag:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

(Needed to call the backend from an emulator/device — without it every API call silently fails.)

## Screens included

- **Login / Signup** — JWT auth against `/api/auth`
- **Forgot Password** — 3-step OTP flow (send OTP → verify → reset)
- **Dashboard** — KPI cards (total products, low/out of stock, pending receipts/deliveries/transfers)
- **Products** — list with search + low-stock filter, create, delete
- **Operations (Stock Moves)** — tabbed by type (Receipt/Delivery/Transfer/Adjustment), create as draft, validate (applies stock change) or cancel
- **Warehouses** — list + create

## Architecture

- `services/` — raw API calls (http package), one file per resource
- `services/api_client.dart` — shared authenticated request helper (attaches JWT from SharedPreferences)
- `providers/auth_provider.dart` — app-wide login state (ChangeNotifier)
- `models/` — typed models matching the backend's Mongoose schemas
- `screens/` — one screen per feature, no nested state management library beyond `provider`

## Notes

- Token is persisted in `SharedPreferences`, restored on app launch (`AuthProvider._loadSession`).
- Stock moves are created as `draft` and only affect stock once validated — matches the ledger flow in the problem statement.
- Role field (`inventory_manager` / `warehouse_staff`) is captured at signup; UI-level role restrictions (e.g. hiding delete/create buttons for staff) aren't wired up yet — the backend already enforces manager-only writes on warehouses via `authorize()` middleware.

## Not yet built
- Product edit screen (only create/delete wired up)
- Move history / ledger detail view per product
- Push notifications for low-stock alerts
- Role-based UI hiding (backend already blocks it, UI doesn't hide buttons yet)
