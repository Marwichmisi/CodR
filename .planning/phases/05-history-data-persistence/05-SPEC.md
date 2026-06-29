# Phase 5: History & Data Persistence — Specification

**Created:** 2026-06-29
**Ambiguity score:** 0.11 (gate: ≤ 0.20)
**Requirements:** 5 locked

## Goal

All scans and generations performed by the user are persisted in SQLite via `StorageService`, displayed in a searchable/filterable list on the History screen, and deletable with confirmation — capped at 100 entries with FIFO auto-cleanup.

## Background

Phase 1 created `StorageService` (with `insertScanRecord`, `insertGenerationRecord`, `getAllScanRecords`, `getAllGenerationRecords`, `delete`) and data models (`ScanRecord`, `GenerationRecord`) — all fully implemented with passing tests. However, **nothing in the app calls StorageService**: `ScannerScreen` and `GeneratorScreen` do not persist events. `HistoryScreen` is a static placeholder (icon + title, no ViewModel, no list). The gap is wiring: connect existing persistence layer to existing screens, build `HistoryViewModel`, rebuild `HistoryScreen` with list/search/filter/delete.

## Requirements

1. **Scan persistence**: Each user-initiated scan action (copy, share, open URL) saves a `ScanRecord` to SQLite.
   - Current: `ScannerScreen.onDetect` triggers `ScannerViewModel.handleQrCodeDetected()` which only debounces — no database call
   - Target: After the user taps copy/share/open in `ScanResultBottomSheet`, a `ScanRecord` is inserted via `StorageService.insertScanRecord()`
   - Acceptance: Perform a scan, tap "Copy" in bottom sheet, then navigate to History — the scan appears in the list with correct content and timestamp

2. **Generation persistence**: Each user-initiated generation action (save to gallery, share, copy) saves a `GenerationRecord` to SQLite.
   - Current: `GeneratorScreen` offers save/share/copy but never calls `StorageService`
   - Target: After the user taps save/share/copy, a `GenerationRecord` is inserted via `StorageService.insertGenerationRecord()`
   - Acceptance: Generate a QR, tap "Save" in gallery, navigate to History — the generation appears with correct content and timestamp

3. **History list display**: `HistoryScreen` shows all persisted records in a scrollable list, most recent first, with timestamp and content preview.
   - Current: `HistoryScreen` is a `StatelessWidget` showing only an icon and title text
   - Target: `HistoryScreen` is a `StatefulWidget` with `HistoryViewModel`, displaying a `ListView` of records (content preview + formatted timestamp + type icon), capped at 100 entries with FIFO auto-cleanup on insert
   - Acceptance: With 5 saved records, History screen shows all 5 in reverse-chronological order; with 101 records, the oldest is automatically removed

4. **Search and type filter**: History list can be searched by text content and filtered by record type (scan vs generation).
   - Current: No search or filter UI exists
   - Target: A `TextField` search bar at the top filters the list by substring match on content; a segmented control or chip row toggles between "All", "Scans", "Generations"
   - Acceptance: Type "example" in search — only records containing "example" are shown; tap "Scans" filter — only scan records are shown; combine search + filter — both apply simultaneously

5. **Delete with confirmation**: User can delete a history entry via swipe gesture, with a confirmation dialog that prevents accidental deletion.
   - Current: `StorageService.delete()` exists but no UI or ViewModel exposes it
   - Target: Swiping left on a list item reveals a delete action; tapping it shows a confirmation `AlertDialog`; confirming deletes the record and refreshes the list; canceling leaves the record unchanged
   - Acceptance: Swipe an entry, confirm deletion — entry disappears from list; swipe another, cancel — entry remains; verify in database that the record was or was not removed accordingly

## Boundaries

**In scope:**
- Wiring `StorageService` into `ScannerViewModel` and `GeneratorViewModel` (insert on user action)
- Creating `HistoryViewModel` with list loading, search, filter, and delete methods
- Rebuilding `HistoryScreen` as `StatefulWidget` with list, search bar, type filter, swipe-to-delete
- FIFO auto-cleanup when inserting the 101st record
- Injection of `StorageService` through `createAppRouter()` to all ViewModels

**Out of scope:**
- Push notifications for new history entries — not requested for v1
- Export history to CSV/file — listed as DIFF-07 in v2 backlog
- Pagination/infinite scroll — 100 entries max fits in a single scrollable list
- Batch delete (select multiple then delete) — single swipe delete only
- History detail screen (tap to view full content) — content is short enough for preview

## Constraints

- Reuse existing `StorageService` — no new database service or schema changes (tables already defined)
- Reuse existing `ScanRecord` / `GenerationRecord` models — no new models needed
- `HistoryViewModel` must follow MVVM pattern with `ChangeNotifier`, consistent with `ScannerViewModel` / `GeneratorViewModel`
- Layout must adapt responsively (phone vs tablet) per QUAL-03 — use Flutter skill `flutter-build-responsive-layout`
- Widget tests for `HistoryScreen` per QUAL-02 — use Flutter skill `flutter-add-widget-test`

## Acceptance Criteria

- [ ] `ScannerViewModel` or `ScannerScreen` calls `StorageService.insertScanRecord()` after user action (copy/share/open) from bottom sheet
- [ ] `GeneratorViewModel` or `GeneratorScreen` calls `StorageService.insertGenerationRecord()` after user action (save/share/copy)
- [ ] `HistoryScreen` displays records in reverse-chronological order with content preview and formatted timestamp
- [ ] `HistoryScreen` shows type icon (scan vs generation) for each record
- [ ] Search bar filters records by substring match on content in real-time
- [ ] Type filter toggles between All / Scans / Generations and combines with search
- [ ] Swipe-left on a record reveals delete action; tapping shows confirmation dialog
- [ ] Confirming deletion removes the record from the list and database
- [ ] Canceling deletion leaves the record unchanged
- [ ] When 101st record is inserted, the oldest record is automatically deleted (FIFO)
- [ ] `StorageService` is injected through `createAppRouter()` and available to all ViewModels
- [ ] Widget tests pass for `HistoryScreen` (list rendering, search, filter, delete confirmation)
- [ ] Responsive layout works on phone and tablet form factors

## Edge Coverage

**Coverage:** 0/0 applicable edges resolved · 0 unresolved

*(Edge probe not applicable — all requirements are CRUD operations on an existing database service with well-defined insertion/deletion semantics. No complex data transformations, interval merging, or ambiguous input parsing.)*

## Prohibitions (must-NOT)

**Coverage:** 0/0 applicable prohibitions resolved · 0 unresolved

*(Prohibition probe not applicable — this phase wires existing persistence to existing UI. No user-facing data manipulation, no external API calls, no authentication flows. Standard MVVM wiring with no safety/ethics surface.)*

## Ambiguity Report

| Dimension          | Score | Min  | Status | Notes                                           |
|--------------------|-------|------|--------|-------------------------------------------------|
| Goal Clarity       | 0.90  | 0.75 | ✓      | 4 features + 100 max + FIFO clearly defined     |
| Boundary Clarity   | 0.90  | 0.70 | ✓      | Explicit in/out scope with reasoning             |
| Constraint Clarity | 0.80  | 0.65 | ✓      | Existing services reused, MVVM pattern enforced  |
| Acceptance Criteria| 0.85  | 0.70 | ✓      | 13 pass/fail checkboxes                          |
| **Ambiguity**      | **0.11** | ≤0.20 | ✓   |                                                  |

## Interview Log

| Round | Perspective     | Question summary                              | Decision locked                                      |
|-------|-----------------|-----------------------------------------------|------------------------------------------------------|
| 1     | Researcher      | When to save scan to database?                | After user action (copy/share/open), not on detection|
| 1     | Researcher      | When to save generation to database?          | After user action (save/share/copy), not on preview  |
| 2     | Simplifier      | Include search/filter/delete or just display? | All 4 features included in this phase                |
| 2     | Simplifier      | Max history entries?                          | 100 entries max with FIFO auto-cleanup               |
| 3     | Boundary Keeper | Filter axis?                                  | Filter by type (scan vs generation)                  |
| 3     | Boundary Keeper | Delete interaction?                           | Swipe left + confirmation dialog                     |
| 4     | Failure Analyst | Cancel after confirm?                         | Cancel = nothing changes, record remains             |
| 4     | Failure Analyst | 100 entries reached, new arrives?             | FIFO: oldest auto-deleted                            |

---

*Phase: 05-history-data-persistence*
*Spec created: 2026-06-29*
*Next step: /gsd-discuss-phase 5 — implementation decisions (how to wire StorageService, HistoryViewModel design, swipe gesture implementation)*
