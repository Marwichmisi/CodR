---
phase: 4
slug: qr-generation
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-06-29
---

# Phase 4 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Flutter test (flutter_test) |
| **Config file** | none — built into Flutter |
| **Quick run command** | `flutter test` |
| **Full suite command** | `flutter test` |
| **Estimated runtime** | ~10 seconds |

---

## Sampling Rate

- **After every task commit:** Run `flutter test`
- **After every plan wave:** Run `flutter test`
- **Before `/gsd-verify-work`:** Full suite must be green
- **Max feedback latency:** 10 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 04-01-01 | 04-01 | 1 | GEN-01 | — | N/A | unit | `flutter test` | ✅ | ⬜ pending |
| 04-01-02 | 04-01 | 1 | GEN-02 | — | N/A | unit | `flutter test` | ✅ | ⬜ pending |
| 04-01-03 | 04-01 | 1 | GEN-03 | — | N/A | unit | `flutter test` | ✅ | ⬜ pending |
| 04-02-01 | 04-02 | 2 | GEN-04 | — | N/A | widget | `flutter test` | ✅ | ⬜ pending |
| 04-02-02 | 04-02 | 2 | GEN-05 | — | N/A | widget | `flutter test` | ✅ | ⬜ pending |
| 04-02-03 | 04-02 | 2 | GEN-06 | — | N/A | widget | `flutter test` | ✅ | ⬜ pending |
| 04-03-01 | 04-03 | 3 | GEN-07 | — | N/A | widget | `flutter test` | ✅ | ⬜ pending |
| 04-03-02 | 04-03 | 3 | UI-03 | — | N/A | widget | `flutter test` | ✅ | ⬜ pending |
| 04-03-03 | 04-03 | 3 | QUAL-02 | — | N/A | widget | `flutter test` | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `qr_flutter` package added to pubspec.yaml
- [ ] `saver_gallery` package added to pubspec.yaml
- [ ] `share_plus` package added to pubspec.yaml
- [ ] `path_provider` package added to pubspec.yaml

*If none: "Existing infrastructure covers all phase requirements."*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Save to gallery | GEN-04 | Requires device gallery access | Tap "Sauvegarder", verify image in gallery |
| Share via share sheet | GEN-06 | Requires native share sheet | Tap "Partager", verify share sheet opens |
| Permission denied feedback | GEN-05 | Requires permission denial simulation | Deny gallery permission, verify SnackBar |

*If none: "All phase behaviors have automated verification."*

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 10s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
