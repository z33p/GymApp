---
name: quality-gate
description: Runs quality gate checks (Design System usage, i18n string extraction, dart format, and flutter analyze) to ensure strict adherence to GymApp standards.
---

# Quality Gate Skill

This skill executes automated quality gate checks on the GymApp codebase to verify compliance with Design System standards, internationalization rules, code formatting, static analysis, and test suites.

## Execution Checklist

When triggered, run the following verification steps in order:

### 1. Code Formatting Check
Run `dart format` to check for unformatted Dart files:
```powershell
dart format --output=none --set-exit-if-changed .
```
- **PASS**: All files formatted according to Dart standards.
- **FAIL**: Report unformatted files.

### 2. Static Code Analysis
Run Flutter static analysis to catch lint issues, unused imports, or type mismatches:
```powershell
flutter analyze
```
- **PASS**: `No issues found!`.
- **FAIL**: List reported analysis issues.

### 3. Internationalization (i18n) Compliance Check
Perform search using `grep_search` across `lib/features/` and `lib/core/` (excluding `lib/l10n/`):
- Pattern: `Text\(['"][^'"]+['"]\)`
- Check for hardcoded string literals inside `Text(...)` or `InputDecoration(labelText: ...)`.
- **PASS**: Zero hardcoded strings in user-facing presentation widgets.
- **FAIL**: List file and line numbers containing hardcoded strings.

### 4. Design System (DS) Compliance Check
Perform search using `grep_search` across `lib/features/` for:
- Raw `Card(` usage (should use `DsCard`).
- Static `SizedBox(height:` or `SizedBox(width:` (should use `DsGap` or `context.dsSpacing`).
- **PASS**: All presentation widgets use DS components.
- **FAIL**: List files still using raw Material primitives.

### 5. Automated Test Suite
Run unit and widget tests:
```powershell
flutter test
```
- **PASS**: All test cases pass.
- **FAIL**: List failing tests.

---

## Output Report Format

Generate a summary report in markdown:

```markdown
# 🛡️ Quality Gate Report

| Gate Check | Status | Details |
| ---------- | ------ | ------- |
| **Dart Formatting** | ✅ PASS / ❌ FAIL | [Summary] |
| **Flutter Analyze** | ✅ PASS / ❌ FAIL | [Summary] |
| **i18n Strings** | ✅ PASS / ❌ FAIL | [Summary] |
| **Design System** | ✅ PASS / ❌ FAIL | [Summary] |
| **Unit Tests** | ✅ PASS / ❌ FAIL | [Summary] |

**Overall Result:** PASS / FAIL
```
