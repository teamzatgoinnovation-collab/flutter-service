# Field Service — Flutter client

Technician shell against the shared ERPNext / `crm_plus` backend (or a future `field_service` split).

**Status:** Runnable scaffold (mock ticket / signature flows + ERPNext password login)  
**Backend:** `crm_plus` / service module (not deployed yet — connection ping ready)  
**SDK:** [`SharedSDK/dart_sdk`](../../SharedSDK/dart_sdk/)

Field jobs: day’s tickets, status workflow, notes, and customer signature capture stubs.

## Requirements

- Flutter 3.24+
- Optional running site (default `http://127.0.0.1:8082`)
- Sign in with ERPNext email/password (or Continue offline)

## Run

```bash
cd Clients/flutter/service
flutter pub get
flutter run
```

With site credentials:

```bash
flutter run \
  --dart-define=FRAPPE_BASE_URL=http://127.0.0.1:8082 \
  --dart-define=FRAPPE_API_KEY=your_key \
  --dart-define=FRAPPE_API_SECRET=your_secret
```

## App map

| Tab | Role |
|-----|------|
| Today | Day summary, next job, quick links |
| Tickets | Filterable ticket list + detail workflow |
| Schedule | Time-ordered jobs for the day |
| Sign-off | Awaiting / completed customer signatures |
| API | Site URL context; `ping` + probe `crm_plus.api.v1.tickets.list` |

Business pages use a local mock repository until `CustomApps/CrmPlus` exposes ticket / signature endpoints (see [API_STRATEGY](../../Docs/Foundation/API_STRATEGY.md)).

## Dependency

```yaml
dependencies:
  zatgo_dart_sdk:
    path: ../../SharedSDK/dart_sdk
```

See [PRODUCT_CATALOG](../../Docs/Foundation/PRODUCT_CATALOG.md) and [APP_RELATIONSHIP](../../Docs/Foundation/APP_RELATIONSHIP.md).
