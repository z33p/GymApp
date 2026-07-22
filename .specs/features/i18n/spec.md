# Internationalization (i18n) Specification

## Problem Statement

The GymApp currently has hardcoded English text throughout the UI. To support a global audience, we need to introduce internationalization (i18n) to support Portuguese (Brazil), English, and Spanish.

## Goals

- [ ] Support English (en), Portuguese - Brazil (pt-BR), and Spanish (es).
- [ ] Implement Flutter's standard localization approach (`flutter_localizations` and `.arb` files).
- [ ] Replace hardcoded strings in the UI with localized strings for the initial set of screens (Home, Settings, Workouts, Progress).

## Out of Scope

| Feature     | Reason         |
| ----------- | -------------- |
| Dynamic language switching without app restart (unless supported out of the box by standard Flutter localizations and our current Riverpod state management). | We will rely on system locale first, but can add a setting if requested later. For now, system locale is the primary driver. |
| Translating user-generated content or database entries. | i18n applies to static UI text only. |

---

## Assumptions & Open Questions

| Assumption / decision | Chosen default  | Rationale | Confirmed? |
| --------------------- | --------------- | --------- | ---------- |
| Approach | Standard Flutter `gen-l10n` | Built-in, widely supported, uses `.arb` files. | N/A |
| Default Language | English (`en`) | Standard fallback language if system locale is not supported. | N/A |
| Should we add a language picker in settings? | Yes, in the Settings screen. | Users often want to override the system language. | Pending |

---

## User Stories

### P1: Standard Localization Setup ⭐ MVP

**User Story**: As a user, I want the app to display text in my system's language (pt-BR, en, es) so that I can understand the UI.

**Why P1**: Core requirement of the feature.

**Acceptance Criteria**:

1. WHEN the system language is set to pt-BR THEN system SHALL display UI in Portuguese.
2. WHEN the system language is set to es THEN system SHALL display UI in Spanish.
3. WHEN the system language is unsupported THEN system SHALL fallback to English.

**Independent Test**: Change system language in the emulator/device and open the app to verify translated strings.

---

### P1: Replace Hardcoded Strings in Core Screens ⭐ MVP

**User Story**: As a user, I want the main tabs (Home, History, Progress, Settings) to be translated.

**Why P1**: i18n is useless without actually translating the text.

**Acceptance Criteria**:

1. WHEN viewing the Home screen THEN system SHALL display localized text.
2. WHEN viewing the Settings screen THEN system SHALL display localized text.

**Independent Test**: Open the Home and Settings screens and confirm no hardcoded English remains.

---

### P2: In-App Language Picker

**User Story**: As a user, I want to manually choose the app language from the Settings screen.

**Why P2**: Some users prefer a different language than their OS language.

**Acceptance Criteria**:

1. WHEN changing the language in Settings THEN system SHALL immediately update the UI language.
2. WHEN the app restarts THEN system SHALL remember the chosen language.

---

## Requirement Traceability

| Requirement ID | Story       | Phase  | Status  |
| -------------- | ----------- | ------ | ------- |
| I18N-01        | P1: Setup   | Specify | Pending |
| I18N-02        | P1: Strings | Specify | Pending |
| I18N-03        | P2: Picker  | Specify | Pending |

---

## Success Criteria

- [ ] Build succeeds with `flutter gen-l10n`.
- [ ] No hardcoded English strings in the main navigation and main screens.
- [ ] Changing the device language to Spanish displays the app in Spanish.
