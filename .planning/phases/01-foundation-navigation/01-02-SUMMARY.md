---
phase: 01-foundation-navigation
plan: 02
subsystem: navigation
tags: [go_router, navigation, material3, data-models, widget-previews]

# Dependency graph
requires:
  - phase: 01-01
    provides: Flutter project scaffold, Material 3 theme, dependencies (go_router, sqflite, google_fonts)
provides:
  - go_router navigation shell with StatefulShellRoute.indexedStack
  - 3 placeholder screens (Scanner, Generator, History) with widget previews
  - ScanRecord and GenerationRecord data models with JSON serialization
  - Navigation and model tests (9 tests)
affects: [01-03-storage, 02-camera-scan, 03-history-ui, 04-qr-generation]

# Tech tracking
tech-stack:
  added: [go_router StatefulShellRoute, widget_previews @Preview]
  patterns: [StatefulShellRoute.indexedStack, NavigationBar (M3), LayoutBuilder responsive, manual JSON serialization]

key-files:
  created:
    - qr_scanner/lib/navigation/app_router.dart
    - qr_scanner/lib/screens/scanner_screen.dart
    - qr_scanner/lib/screens/generator_screen.dart
    - qr_scanner/lib/screens/history_screen.dart
    - qr_scanner/lib/models/scan_record.dart
    - qr_scanner/lib/models/generation_record.dart
    - qr_scanner/test/screens/navigation_test.dart
    - qr_scanner/test/models/scan_record_test.dart
    - qr_scanner/test/models/generation_record_test.dart
  modified:
    - qr_scanner/lib/main.dart
    - qr_scanner/test/widget_test.dart

key-decisions:
  - "Used StatefulShellRoute.indexedStack for persistent bottom nav with state preservation"
  - "Material 3 NavigationBar (not BottomNavigationBar) per D-05 and RESEARCH pitfall 2"
  - "Manual JSON serialization (no codegen) — sufficient for Phase 1 simple models"

patterns-established:
  - "Navigation shell: StatefulShellRoute.indexedStack + ScaffoldWithNavBar pattern"
  - "Placeholder screens: LayoutBuilder + ConstrainedBox(maxWidth: 480) + centered Column"
  - "Widget previews: @Preview annotation with MaterialApp wrapper per screen"
  - "Data models: const constructor + factory fromJson + toJson with ISO 8601 DateTime"

requirements-completed: [INFRA-03, INFRA-04, UI-01, UI-05]

# Coverage metadata
coverage:
  - id: D1
    description: "go_router navigation shell with 3 branches and Material 3 NavigationBar"
    requirement: "INFRA-03"
    verification:
      - kind: widget
        ref: "test/screens/navigation_test.dart#bottom nav has 3 tabs with correct labels"
        status: pass
      - kind: widget
        ref: "test/screens/navigation_test.dart#app launches on Scanner screen"
        status: pass
      - kind: widget
        ref: "test/screens/navigation_test.dart#tapping Generator tab shows Generator screen"
        status: pass
      - kind: widget
        ref: "test/screens/navigation_test.dart#tapping History tab shows History screen"
        status: pass
      - kind: widget
        ref: "test/screens/navigation_test.dart#tapping Scanner tab returns to Scanner screen"
        status: pass
    human_judgment: false
  - id: D2
    description: "3 placeholder screens with LayoutBuilder, AppBar, centered icon+title+subtitle"
    requirement: "UI-01"
    verification:
      - kind: automated
        ref: "flutter analyze --no-pub"
        status: pass
    human_judgment: false
  - id: D3
    description: "ScanRecord and GenerationRecord data models with JSON serialization"
    requirement: "INFRA-04"
    verification:
      - kind: unit
        ref: "test/models/scan_record_test.dart#serializes to JSON and back without data loss"
        status: pass
      - kind: unit
        ref: "test/models/generation_record_test.dart#serializes to JSON and back without data loss"
        status: pass
    human_judgment: false
  - id: D4
    description: "Widget previews (@Preview) for all 3 screens"
    requirement: "UI-05"
    verification: []
    human_judgment: true
    rationale: "Widget Previewer requires Flutter 3.35+ IDE support — previews verified by annotation presence, not runtime rendering"

# Metrics
duration: 5min
completed: 2026-06-27
status: complete
---

# Phase 1 Plan 2: Navigation & Data Models Summary

**go_router StatefulShellRoute navigation shell with 3 placeholder screens, ScanRecord/GenerationRecord data models, and 14 passing tests**

## Performance

- **Duration:** 5 min
- **Started:** 2026-06-27T10:22:19Z
- **Completed:** 2026-06-27T10:27:35Z
- **Tasks:** 3 (+ 1 fix)
- **Files modified:** 10

## Accomplishments
- Implemented go_router `StatefulShellRoute.indexedStack` with 3 navigation branches
- Created Material 3 `NavigationBar` with French labels (Scanner, Générateur, Historique) and correct icons
- Built 3 responsive placeholder screens with `LayoutBuilder`, centered 64px icon + title + subtitle
- Added `@Preview` widget previews for all 3 screens
- Created `ScanRecord` and `GenerationRecord` data models with manual JSON serialization
- Updated `main.dart` to use `MaterialApp.router` with `routerConfig`
- Wrote 9 new tests (5 navigation + 4 model) — all passing
- Full test suite: 14 tests passing, `flutter analyze` clean

## Task Commits

Each task was committed atomically:

1. **Task 1: Implement go_router navigation shell with 3 placeholder screens** - `70a479b` (feat)
2. **Task 2: Create ScanRecord and GenerationRecord data models** - `04851c3` (feat)
3. **Task 3: Write navigation and model tests** - `904c2fa` (test)
4. **Fix: Update widget test to match router-based app structure** - `0685031` (fix)

**Plan metadata:** pending (docs: complete plan)

## Files Created/Modified
- `qr_scanner/lib/navigation/app_router.dart` - GoRouter config with StatefulShellRoute.indexedStack and ScaffoldWithNavBar
- `qr_scanner/lib/screens/scanner_screen.dart` - Placeholder screen with @Preview
- `qr_scanner/lib/screens/generator_screen.dart` - Placeholder screen with @Preview
- `qr_scanner/lib/screens/history_screen.dart` - Placeholder screen with @Preview
- `qr_scanner/lib/models/scan_record.dart` - ScanRecord data model with JSON serialization
- `qr_scanner/lib/models/generation_record.dart` - GenerationRecord data model with JSON serialization
- `qr_scanner/lib/main.dart` - Updated to MaterialApp.router with routerConfig
- `qr_scanner/test/screens/navigation_test.dart` - 5 navigation widget tests
- `qr_scanner/test/models/scan_record_test.dart` - 2 ScanRecord unit tests
- `qr_scanner/test/models/generation_record_test.dart` - 2 GenerationRecord unit tests
- `qr_scanner/test/widget_test.dart` - Fixed to match router structure

## Decisions Made
- Used `StatefulShellRoute.indexedStack` for persistent bottom nav with state preservation (D-05)
- Material 3 `NavigationBar` (not deprecated `BottomNavigationBar`) per RESEARCH pitfall 2
- Manual JSON serialization without codegen — sufficient for Phase 1 simple models

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] widget_test.dart expected 2 'QR Scanner' texts but router renders only 1**
- **Found during:** Overall verification (flutter test)
- **Issue:** Pre-existing test from Plan 01-01 expected `findsNWidgets(2)` for "QR Scanner" but router-based app only shows AppBar title
- **Fix:** Changed `findsNWidgets(2)` to `findsOneWidget`
- **Files modified:** qr_scanner/test/widget_test.dart
- **Verification:** All 14 tests pass
- **Committed in:** 0685031

---

**Total deviations:** 1 auto-fixed (1 bug)
**Impact on plan:** Minor test fix for pre-existing test适应router change. No scope creep.

## Issues Encountered
None — plan executed cleanly.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Navigation shell complete with 3 tabs and state preservation
- Data models defined and tested, ready for SQLite storage in Plan 01-03
- All screens have widget previews for IDE previewer
- Responsive layout foundation in place (LayoutBuilder per screen)

## Self-Check: PASSED

All key files exist on disk. All task commits verified in git log. All 14 tests pass. `flutter analyze` clean.

---
*Phase: 01-foundation-navigation*
*Completed: 2026-06-27*
