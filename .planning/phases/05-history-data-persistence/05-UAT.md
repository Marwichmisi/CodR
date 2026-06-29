---
status: complete
phase: 05-history-data-persistence
source: 05-01-SUMMARY.md, 05-02-SUMMARY.md
started: 2026-06-29T17:00:00Z
updated: 2026-06-29T17:05:00Z
---

## Current Test

[testing complete]

## Tests

### 1. RecordBase abstraction with factory fromJson returning correct subtypes
expected: RecordBase.fromJson dispatches to ScanRecord and GenerationRecord subtypes correctly
result: pass
source: automated
coverage_id: D1

### 2. StorageService.getHistory() returns merged list sorted by timestamp DESC
expected: getHistory() returns scan and generation records merged and sorted newest-first
result: pass
source: automated
coverage_id: D2

### 3. FIFO cleanup enforces 100 max records per table on insert
expected: Inserting the 101st record in a table removes the oldest record from that table
result: pass
source: automated
coverage_id: D3

### 4. ScannerViewModel and GeneratorViewModel persist records after user actions
expected: Scanning a QR code and generating a QR code both save records to SQLite
result: pass
source: automated
coverage_id: D4

### 5. HistoryScreen displays records with type icon, content preview, and relative timestamp
expected: Records show type icon, content text, and relative timestamp (<48h shows "il y a X min", older shows date)
result: pass
source: automated
coverage_id: D5

### 6. Empty/loading/error states handled correctly in HistoryScreen
expected: Empty state shows "Aucun historique" text; loading shows progress indicator; error shows message
result: pass
source: automated
coverage_id: D6

### 7. Responsive layout works on phone and tablet (LayoutBuilder + ConstrainedBox max 480)
expected: Content is constrained to max 480px width, centers on wider screens
result: pass
source: automated
coverage_id: D7

### 8. HistoryViewModel search and filter functionality with combined queries
expected: setSearchQuery updates query, filteredRecords combines type filter and search
result: pass
source: automated
coverage_id: D1 (02)

### 9. HistoryScreen search bar with hint text and real-time filtering
expected: Search bar shows "Rechercher dans l'historique..." hint, typing filters records in real-time
result: pass
source: automated
coverage_id: D2 (02)

### 10. Filter chips toggle between All/Scans/Generations
expected: Tapping filter chips shows only matching record type, "Tout" shows all
result: pass
source: automated
coverage_id: D3 (02)

### 11. Swipe-to-delete with confirmation dialog and French text
expected: Swipe shows AlertDialog with "Supprimer l'entrée" title, "Annuler"/"Supprimer" buttons
result: pass
source: automated
coverage_id: D4 (02)

### 12. Responsive layout with Wrap filter chips prevents overflow
expected: Filter chips use Wrap widget, no overflow on 360px width screens
result: pass
source: automated
coverage_id: D5 (02)

## Summary

total: 12
passed: 12
issues: 0
pending: 0
skipped: 0
blocked: 0

## Gaps

[none]
