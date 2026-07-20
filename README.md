# Field Service — Flutter client

Technician shell against `zatgo_core` field-service hub APIs (thin list/get until domain workflows deepen).

**Status:** Runnable scaffold (mock ticket / signature flows + ERPNext password login)  
**Backend:** `zatgo_core.api.v1.service.*`  
**SDK:** [`SharedSDK/dart_sdk`](../../../SharedSDK/dart_sdk/)

Field jobs: day’s tickets, status workflow, notes, and customer signature capture stubs.

## Requirements

- Flutter 3.24+
- Optional running site (default `https://demo.zatgo.online`)
- Sign in with ERPNext email/password (or Continue offline)

## Run

```bash
cd Clients/flutter/service
flutter pub get
flutter run --dart-define=FRAPPE_BASE_URL=https://demo.zatgo.online
```

## App map

| Tab | Role |
|-----|------|
| Today | Day summary, next job, quick links |
| Tickets | Filterable ticket list + detail workflow |
| Schedule | Time-ordered jobs for the day |
| Sign-off | Awaiting / completed customer signatures |
| API | Site URL context; `service.health.ping` + `service.tickets.list` |

Business pages may keep local mocks for UI flows not yet on the hub; session/`callMethod` is the only ERPNext path (no API keys).

## Dependency

```yaml
dependencies:
  zatgo_dart_sdk:
    path: ../../../SharedSDK/dart_sdk
```

See [PRODUCT_CATALOG](../../../Docs/Foundation/PRODUCT_CATALOG.md) and [APP_RELATIONSHIP](../../../Docs/Foundation/APP_RELATIONSHIP.md).
