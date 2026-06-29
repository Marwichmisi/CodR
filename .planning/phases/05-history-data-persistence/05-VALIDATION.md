---
phase: 5
slug: history-data-persistence
status: complete
nyquist_compliant: true
wave_0_complete: true
created: 2026-06-29
completed: 2026-06-29
---

# Phase 5 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | flutter_test + mocktail |
| **Config file** | pubspec.yaml (dev_dependencies) |
| **Quick run command** | `cd qr_scanner && flutter test test/viewmodels/history_viewmodel_test.dart` |
| **Full suite command** | `cd qr_scanner && flutter test` |
| **Estimated runtime** | ~15 seconds |

---

## Sampling Rate

- **After every task commit:** Run `cd qr_scanner && flutter test test/viewmodels/history_viewmodel_test.dart`
- **After every plan wave:** Run `cd qr_scanner && flutter test`
- **Before `/gsd-verify-work`:** Full suite must be green
- **Max feedback latency:** 15 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 05-01-01 | 01 | 1 | HIST-01 | T-5-01 / — | Validation du contenu avant insertion BDD | unit | `cd qr_scanner && flutter test test/viewmodels/scanner_viewmodel_test.dart` | ✅ (modify) | ✅ green |
| 05-01-02 | 01 | 1 | HIST-01 | T-5-02 / — | Validation du contenu avant insertion BDD | unit | `cd qr_scanner && flutter test test/viewmodels/generator_viewmodel_test.dart` | ✅ (modify) | ✅ green |
| 05-01-03 | 01 | 1 | HIST-02 | T-5-03 / — | FIFO auto-cleanup à 100 enregistrements | unit | `cd qr_scanner && flutter test test/viewmodels/history_viewmodel_test.dart` | ✅ | ✅ green |
| 05-02-01 | 02 | 2 | HIST-03 | — | Recherche temps réel | unit | `cd qr_scanner && flutter test test/viewmodels/history_viewmodel_test.dart` | ✅ | ✅ green |
| 05-02-02 | 02 | 2 | HIST-04 | T-5-04 / — | Suppression avec confirmation | widget | `cd qr_scanner && flutter test test/screens/history_screen_test.dart` | ✅ | ✅ green |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [x] `test/viewmodels/history_viewmodel_test.dart` — stubs for HIST-01, HIST-02, HIST-03, HIST-04
- [x] `test/screens/history_screen_test.dart` — stubs for UI-04
- [x] `test/models/record_base_test.dart` — vérifie l'implémentation RecordBase

*Existing infrastructure covers most phase requirements. Wave 0 creates new test files for HistoryViewModel and HistoryScreen.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Swipe-to-delete gesture | UI-04 | Gesture testing complexe en widget test | Swipe left sur une entrée, vérifier que le fond rouge apparaît |
| Timestamp relatif affichage | HIST-02 | Vérification visuelle du format | Vérifier que "il y a X min" s'affiche correctement |
| Responsive layout tablette | QUAL-03 | Test sur écran large | Lancer sur un écran >600dp, vérifier max 480dp |

*If none: "All phase behaviors have automated verification."*

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all MISSING references
- [x] No watch-mode flags
- [x] Feedback latency < 15s
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** ✅ approved — 142 tests passing, flutter analyze clean
