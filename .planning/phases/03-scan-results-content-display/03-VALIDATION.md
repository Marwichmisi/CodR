---
phase: 03
slug: scan-results-content-display
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-06-28
---

# Phase 03 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | flutter_test |
| **Config file** | test/ (standard Flutter) |
| **Quick run command** | `flutter test test/viewmodels/result_viewmodel_test.dart` |
| **Full suite command** | `flutter test` |
| **Estimated runtime** | ~10 seconds |

---

## Sampling Rate

- **After every task commit:** Run `flutter test test/viewmodels/result_viewmodel_test.dart`
- **After every plan wave:** Run `flutter test`
- **Before `/gsd-verify-work`:** Full suite must be green
- **Max feedback latency:** 10 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 03-01-01 | 01 | 1 | SCAN-07 | T-03-01 | URL scheme filtering to http/https only | unit | `flutter test test/viewmodels/result_viewmodel_test.dart` | ❌ W0 | ⬜ pending |
| 03-01-02 | 01 | 1 | SCAN-08 | T-03-02 | Bottom sheet displays content with action buttons | widget | `flutter test test/screens/scan_result_bottom_sheet_test.dart` | ❌ W0 | ⬜ pending |
| 03-01-03 | 01 | 1 | SCAN-08 | — | Copy to clipboard with confirmation SnackBar | widget | `flutter test test/screens/scan_result_bottom_sheet_test.dart` | ❌ W0 | ⬜ pending |
| 03-01-04 | 01 | 1 | SCAN-08 | — | Share content via native share sheet | widget | `flutter test test/screens/scan_result_bottom_sheet_test.dart` | ❌ W0 | ⬜ pending |
| 03-02-01 | 02 | 2 | QUAL-01 | — | ResultViewModel unit tests (≥90% coverage) | unit | `flutter test test/viewmodels/result_viewmodel_test.dart` | ❌ W0 | ⬜ pending |
| 03-02-02 | 02 | 2 | QUAL-04 | — | Error state displays with retry/close buttons | widget | `flutter test test/screens/scan_result_bottom_sheet_test.dart` | ❌ W0 | ⬜ pending |
| 03-02-03 | 02 | 2 | SCAN-08 | — | Camera lifecycle pause/resume with bottom sheet | unit | `flutter test test/screens/scanner_lifecycle_test.dart` | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `test/viewmodels/result_viewmodel_test.dart` — stubs for SCAN-07, QUAL-01
- [ ] `test/screens/scan_result_bottom_sheet_test.dart` — stubs for SCAN-08, QUAL-04
- [ ] Framework install: None needed — flutter_test already configured

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| URL opens in system browser | SCAN-07 | Requires real device with browser | Scan QR with URL, tap "Ouvrir le lien", verify browser opens |
| Email opens mail client | SCAN-08 | Requires real device with mail app | Scan QR with email, tap "Envoyer", verify mail app opens |
| Phone opens dialer | SCAN-08 | Requires real device with dialer | Scan QR with phone number, tap "Appeler", verify dialer opens with number |
| Share sheet appears | SCAN-08 | Requires native share sheet | Scan QR, tap "Partager", verify share sheet appears |
| Camera pauses when sheet open | SCAN-08 | Requires visual verification | Scan QR, verify camera preview freezes, close sheet, verify camera resumes |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 10s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
