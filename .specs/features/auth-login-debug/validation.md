# Auth Login & Debug Mode Validation

**Date:** 2026-07-21  
**Spec:** `.specs/features/auth-login-debug/spec.md`  
**Diff range:** `f845d0f..3ae8d57`  
**Verifier:** independent verifier (author != verifier)  
**Verdict:** PASS static; Flutter runtime gate pending environment

## Acceptance criteria

| AC | Evidence | Result |
| --- | --- | --- |
| No local user shows Login before Habitat | `auth_gate.dart`; `auth_login_test.dart` null-session case | PASS |
| Debug entry creates/reuses local profile and opens Habitat | `login_screen.dart`, `local_auth_repository.dart`, debug-to-Habitat test | PASS |
| Google, Microsoft and Apple remain on Login with clear not-configured status | typed provider contract, adapter and parameterized provider test | PASS |
| Existing local session opens the app without Login | `AuthGate` non-null branch and existing-session test | PASS |
| Sessionless bootstrap does not create a user or sync | `bootstrapProvider` early return and `syncCalls == 0` assertion | PASS |

## Explicit debug mode

The development entry is guarded by `kDebugMode` and is labeled as a local debug profile. External buttons do not create fake accounts or claim OAuth success.

## Discrimination sensor

Injected `signInDebug()` into the bootstrap in scratch state. The detector and the bootstrap test distinguish the mutant: the original keeps the user null and `syncCalls == 0`; the mutant violates both expectations. Result: 1/1 mutant killed.

## Gates

- Static imports, contracts and diff checks: PASS.
- `flutter analyze`: not executed because Flutter is not on this shell PATH.
- `flutter test`: not executed for the same environment limitation.

Run the project setup script and then `flutter analyze; flutter test` on the development machine to close the runtime gate.
