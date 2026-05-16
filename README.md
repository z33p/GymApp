# GymApp

GymApp is a Flutter mobile MVP focused on automatically importing workouts that were recorded elsewhere, especially workouts written into Apple Health by Apple Watch.

## Vertical slice included
- Local mock user bootstrap
- Riverpod + go_router app shell with bottom navigation
- Local SQLite persistence for workouts, sync state, check-ins, and app user
- Devices screen with Apple Health connect/sync flow and preview fallback
- Manual sync plus startup/resume sync orchestration
- Activity feed, history list, workout detail, progress dashboard, and settings
- Native iOS MethodChannel HealthKit integration scaffold

## Notes
- iOS reads from Apple Health through `com.gymapp.health/apple_health`.
- Unsupported platforms and iOS simulator fall back to preview workout data.
- Android is structured for future Health Connect and Garmin integrations.
