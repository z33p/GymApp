# Spec: Dark Theme Support for Home & Bottom Navigation Shell

## ID: FEAT-DARK-THEME-HOME-NAV

### 1. Requirements

- **REQ-01 (AppShell Navigation Bar Dark Theme)**:
  - The bottom `BottomAppBar` must consume background color dynamically from `context.dsColors.surface` instead of hardcoded white.
  - Navigation icons and labels must use `context.dsColors.primary` when active and `context.dsColors.textMuted` when inactive.
  - Floating Action Button must use `context.dsColors.primary` as background and `context.dsColors.onPrimary` as foreground.

- **REQ-02 (HomeScreen Dark Theme)**:
  - `HomeScreen` scaffold background must use `context.dsColors.background`.
  - Headers, text labels, and subtitles must use `context.dsColors.onBackground`, `context.dsColors.onSurface`, and `context.dsColors.textMuted` respectively.
  - Group Selector and Card containers must use `context.dsColors.surface` and `context.dsColors.border`.
  - Dropdown menu items must adapt to `context.dsColors.surface` background and `context.dsColors.onSurface` text color.
  - Ranking tab container must use `context.dsColors.background` with selected tab using `context.dsColors.surface` and `context.dsColors.primary` text.
  - User ranking item highlight must use theme-aware colors (`context.dsColors.primary.withOpacity(...)`).
  - Feed items and metrics must use surface, border, and text tokens from `context.dsColors`.

### 2. Acceptance Criteria
- **AC-01**: When theme is changed to Dark (`ThemeMode.dark`), `AppShell` bottom bar displays dark background (`#1E293B`) without white flash or white background.
- **AC-02**: When theme is changed to Dark (`ThemeMode.dark`), `HomeScreen` displays dark background (`#0F172A`), dark cards (`#1E293B`), dark borders (`#334155`), and high-contrast text (`#F8FAFC`).
- **AC-03**: All existing unit & widget tests pass cleanly with `flutter test` and zero lint issues from `flutter analyze`.
