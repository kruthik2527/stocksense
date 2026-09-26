# StockSense Backend

Node.js + Express + MongoDB backend for the StockSense Inventory Management System.

## Setup

```bash
npm install
cp .env.example .env   # fill in MONGO_URI, JWT_SECRET, SMTP credentials
npm run dev             # or: npm start
```

## Modules built

- **Auth**: signup, login (JWT), forgot-password OTP (emailed via nodemailer), verify OTP, reset password
- **Products**: CRUD, SKU uniqueness, per-warehouse stock, `totalStock` virtual, low-stock filter
- **Warehouses**: CRUD (manager-only writes)
- **Stock Moves** (the core ledger): receipt / delivery / transfer / adjustment
  - Create as `draft` → `validate` applies the actual stock change → `done`
  - `cancel` before validation, no stock impact
- **Dashboard**: KPIs (total products, low/out of stock, pending receipts/deliveries/transfers)

## API quick reference

| Method | Endpoint | Auth | Notes |
|---|---|---|---|
| POST | /api/auth/signup | - | name, email, password, role |
| POST | /api/auth/login | - | returns JWT |
| POST | /api/auth/forgot-password | - | sends OTP email |
| POST | /api/auth/verify-otp | - | email, otp |
| POST | /api/auth/reset-password | - | email, otp, newPassword |
| POST | /api/products | JWT | name, sku, category, unitOfMeasure, reorderLevel, initialStock, warehouse |
| GET | /api/products?search=&category=&lowStock=true | JWT | |
| GET/PUT/DELETE | /api/products/:id | JWT | |
| POST | /api/warehouses | JWT (manager) | name, location |
| GET | /api/warehouses | JWT | |
| POST | /api/stock-moves | JWT | type: receipt/delivery/transfer/adjustment |
| PATCH | /api/stock-moves/:id/validate | JWT | applies stock change |
| PATCH | /api/stock-moves/:id/cancel | JWT | |
| GET | /api/stock-moves?type=&status=&warehouse=&product= | JWT | |
| GET | /api/dashboard | JWT | KPIs |

## Stock move payload examples

**Receipt** (stock increases at `toWarehouse`):
```json
{ "type": "receipt", "product": "<productId>", "quantity": 50, "toWarehouse": "<warehouseId>", "reference": "Vendor ABC" }
```

**Delivery** (stock decreases at `fromWarehouse`):
```json
{ "type": "delivery", "product": "<productId>", "quantity": 10, "fromWarehouse": "<warehouseId>", "reference": "SO-1023" }
```

**Transfer** (moves between two warehouses):
```json
{ "type": "transfer", "product": "<productId>", "quantity": 20, "fromWarehouse": "<warehouseIdA>", "toWarehouse": "<warehouseIdB>" }
```

**Adjustment** (`quantity` is the delta: positive to add, negative to subtract):
```json
{ "type": "adjustment", "product": "<productId>", "quantity": -3, "fromWarehouse": "<warehouseId>", "notes": "3kg damaged" }
```

Every move is created as `draft`, then hit `PATCH /:id/validate` to actually apply it to stock — this mirrors the ledger flow from the problem statement (nothing changes stock except a validated move).

## Next steps (not yet built)
- Flutter mobile app (auth screens, dashboard, product list, move validation UI)
- Reordering rules automation (auto-create receipt drafts when stock hits reorderLevel)
- Role-based UI restrictions matching the `authorize()` middleware
