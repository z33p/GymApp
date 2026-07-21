# Auth Login & Debug Mode Tasks

## Test coverage matrix

| Layer | Coverage | Gate |
| --- | --- | --- |
| Auth contract/repository | Debug user creation, existing user reuse, external not-configured error | `flutter test` |
| Login presentation | Provider buttons, debug CTA, semantics and error message | `flutter test` |
| Auth gate/bootstrap | No-session login; existing-session app content | `flutter test` + `flutter analyze` |

## Execution

1. Domain contract and local repository adapter — commit `feat(auth): add pluggable auth contract`.
2. Login screen and AuthGate — commit `feat(auth): add visual login and debug mode`.
3. Bootstrap integration, specs and full gates — commit `docs(auth): validate login debug flow`.

**Status:** Complete — static validation PASS; Flutter runtime gate pending because Flutter is not on this shell PATH.
