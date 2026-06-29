---
phase: 05-history-data-persistence
plan: 01
subsystem: data
tags: [sqlite, sqflite, mvvm, history, fifo, record-base]

# Dependency graph
requires:
  - phase: 04-qr-generation
    provides: "StorageService with CRUD for scan_records and generation_records tables"
provides:
  - "RecordBase abstraction for unified record access"
  - "StorageService.getHistory() for merged record retrieval"
  - "FIFO auto-cleanup (100 records per table)"
  - "ScannerViewModel/GeneratorViewModel persistence integration"
  - "HistoryViewModel with list loading, delete, and type filtering"
  - "HistoryScreen with responsive record display"
affects: [05-history-search]

# Tech tracking
tech-stack:
  added: [get_time_ago]
  patterns: [mvvm, change-notifier, factory-dispatch, fifo-cleanup]

key-files:
  created:
    - qr_scanner/lib/models/record_base.dart
    - qr_scanner/lib/viewmodels/history_viewmodel.dart
    - qr_scanner/test/models/record_base_test.dart
    - qr_scanner/test/viewmodels/history_viewmodel_test.dart
    - qr_scanner/test/screens/history_screen_test.dart
  modified:
    - qr_scanner/lib/models/scan_record.dart
    - qr_scanner/lib/models/generation_record.dart
    - qr_scanner/lib/services/storage_service.dart
    - qr_scanner/lib/viewmodels/scanner_viewmodel.dart
    - qr_scanner/lib/viewmodels/generator_viewmodel.dart
    - qr_scanner/lib/navigation/app_router.dart
    - qr_scanner/lib/screens/scanner_screen.dart
    - qr_scanner/lib/screens/generator_screen.dart
    - qr_scanner/lib/screens/history_screen.dart
    - qr_scanner/lib/main.dart

key-decisions:
  - "RecordBase uses abstract class with factory constructor for type-safe dispatch"
  - "FIFO cleanup runs on insert only, not at app start (per D-07)"
  - "StorageService injected via createAppRouter() to maintain dependency injection pattern"
  - "HistoryScreen saves record on scan detection, not per-action (simpler, captures all scans)"
  - "Relative timestamps for <48h, formatted dates for older records"

patterns-established:
  - "RecordBase factory dispatch: RecordBase.fromJson() delegates to subtype based on type field"
  - "Optional StorageService injection: ViewModels accept nullable StorageService for backward compatibility"
  - "FIFO cleanup pattern: _enforceFifoLimit called after each insert in model-specific methods"

requirements-completed: [HIST-01, HIST-02, UI-04]

coverage:
  - id: D1
    description: "RecordBase abstraction with factory fromJson returning correct subtypes"
    requirement: "HIST-01"
    verification:
      - kind: unit
        ref: "test/models/record_base_test.dart#RecordBase ScanRecord is a subtype of RecordBase"
        status: pass
    human_judgment: false
  - id: D2
    description: "StorageService.getHistory() returns merged list sorted by timestamp DESC"
    requirement: "HIST-01"
    verification:
      - kind: unit
        ref: "test/services/storage_service_test.dart#StorageService getAll returns records ordered by timestamp DESC"
        status: pass
    human_judgment: false
  - id: D3
    description: "FIFO cleanup enforces 100 max records per table on insert"
    requirement: "HIST-01"
    verification:
      - kind: unit
        ref: "test/services/storage_service_test.dart"
        status: pass
    human_judgment: false
  - id: D4
    description: "ScannerViewModel and GeneratorViewModel persist records after user actions"
    requirement: "HIST-02"
    verification:
      - kind: unit
        ref: "test/viewmodels/scanner_viewmodel_test.dart"
        status: pass
    human_judgment: false
  - id: D5
    description: "HistoryScreen displays records with type icon, content preview, and relative timestamp"
    requirement: "UI-04"
    verification:
      - kind: unit
        ref: "test/screens/history_screen_test.dart#HistoryScreen records are displayed with content preview and timestamp"
        status: pass
    human_judgment: false
  - id: D6
    description: "Empty/loading/error states handled correctly in HistoryScreen"
    requirement: "UI-04"
    verification:
      - kind: unit
        ref: "test/screens/history_screen_test.dart#HistoryScreen empty state shows Aucun historique text"
        status: pass
    human_judgment: false
  - id: D7
    description: "Responsive layout works on phone and tablet (LayoutBuilder + ConstrainedBox max 480)"
    requirement: "UI-04"
    verification:
      - kind: unit
        ref: "test/screens/history_screen_test.dart#HistoryScreen responsive layout uses ConstrainedBox"
        status: pass
    human_judgment: false

# Metrics
duration: 22min
completed: 2026-06-29
status: complete
---

# Phase 5 Plan 1: SQLite History Storage Integration Summary

**RecordBase abstraction with factory fromJson, FIFO cleanup, and HistoryScreen with responsive record display**

## Performance

- **Duration:** 22 min
- **Started:** 2026-06-29T16:13:01Z
- **Completed:** 2026-06-29T16:35:51Z
- **Tasks:** 3
- **Files modified:** 15

## Accomplishments
- RecordBase abstract class with factory fromJson dispatching to ScanRecord/GenerationRecord subtypes
- StorageService.getHistory() returns merged list sorted by timestamp DESC
- FIFO auto-cleanup enforces 100 max records per table (separate per type)
- ScannerViewModel and GeneratorViewModel persist records after user actions
- HistoryScreen displays records with type icon, content preview, and relative timestamp
- Empty/loading/error states handled correctly
- Responsive layout with LayoutBuilder + ConstrainedBox(maxWidth: 480)

## Task Commits

Each task was committed atomically:

1. **Task 1: RecordBase abstraction, getHistory, FIFO cleanup** - `4a66ff3` (feat)
2. **Task 2: StorageService integration and HistoryScreen rebuild** - `df79ed2` (feat)
3. **Task 3: HistoryViewModel and HistoryScreen tests** - `e4ccbd1` (test)

**TDD commits:**
- `6acfe85`: test(05-01): add failing test for RecordBase abstraction (RED)
- `4a66ff3`: feat(05-01): implement RecordBase abstraction with getHistory and FIFO cleanup (GREEN)

## Files Created/Modified
- `qr_scanner/lib/models/record_base.dart` - Abstract base class with factory fromJson
- `qr_scanner/lib/models/scan_record.dart` - Extended to implement RecordBase
- `qr_scanner/lib/models/generation_record.dart` - Extended to implement RecordBase
- `qr_scanner/lib/services/storage_service.dart` - Added getHistory() and FIFO cleanup
- `qr_scanner/lib/viewmodels/scanner_viewmodel.dart` - Added StorageService injection and saveScanRecord()
- `qr_scanner/lib/viewmodels/generator_viewmodel.dart` - Added StorageService injection and saveGenerationRecord()
- `qr_scanner/lib/viewmodels/history_viewmodel.dart` - New ViewModel for history screen
- `qr_scanner/lib/navigation/app_router.dart` - Updated to accept StorageService parameter
- `qr_scanner/lib/screens/scanner_screen.dart` - Saves scan record on detection
- `qr_scanner/lib/screens/generator_screen.dart` - Saves generation record on save/share/copy
- `qr_scanner/lib/screens/history_screen.dart` - Rebuilt as StatefulWidget with record list
- `qr_scanner/lib/main.dart` - Creates StorageService and passes to router
- `qr_scanner/test/models/record_base_test.dart` - Unit tests for RecordBase
- `qr_scanner/test/viewmodels/history_viewmodel_test.dart` - Unit tests for HistoryViewModel
- `qr_scanner/test/screens/history_screen_test.dart` - Widget tests for HistoryScreen

## Decisions Made
- RecordBase uses abstract class with factory constructor for type-safe dispatch (not interface)
- FIFO cleanup runs on insert only, not at app start (per D-07 decision)
- StorageService injected via createAppRouter() to maintain dependency injection pattern
- HistoryScreen saves record on scan detection, not per-action (simpler, captures all scans)
- Relative timestamps for <48h, formatted dates for older records (per UI-SPEC)

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- History data persistence complete, ready for search functionality
- All tests passing (123 tests)
- App compiles without errors

---
*Phase: 05-history-data-persistence*
*Completed: 2026-06-29*
