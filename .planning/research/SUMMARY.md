# Project Research Summary

**Project:** QR Code Scanner & Generator Flutter App
**Domain:** Mobile utility app — camera-based QR scanning and QR code generation
**Researched:** 2026-06-27
**Confidence:** HIGH

## Executive Summary

This is a personal/learning Flutter app with two core functions: scanning QR codes via camera and generating QR codes from text/URLs. Experts build these apps with a straightforward two-screen architecture (Scanner + Generator) using `mobile_scanner` for camera-based QR detection (ML Kit on Android, AVFoundation on iOS) and `qr_flutter` for rendering QR codes as widgets. The stack is lightweight by design — no backend, no authentication, 100% offline — which keeps complexity manageable and aligns with the project's scope as a learning exercise.

The recommended approach is to build incrementally in 4 phases: first the scanner (the hardest technical challenge due to camera lifecycle management), then the generator, then history storage, and finally polish/differentiators. `setState` is sufficient for state management given the app's simplicity (2-3 screens, no complex state flows). SQLite via `sqflite` handles history storage with a simple 4-column schema. Material 3 provides the design system out of the box.

The primary risk is the scanner camera lifecycle — the #1 reported issue across all Flutter QR scanner packages is a black screen when returning to the scanner after navigating away. This must be handled correctly from day one by implementing `WidgetsBindingObserver` and explicit `controller.stop()`/`controller.start()` calls. The second risk is duplicate scan detections (a single QR triggers 5-20+ callbacks per second), which requires a debounce gate. Both pitfalls are well-documented with clear prevention patterns.

## Key Findings

### Recommended Stack

The stack is chosen for maturity, download volume, and fit with the offline constraint. All core packages have 1M+ downloads and active maintenance (2026).

**Core technologies:**
- **mobile_scanner ^7.2.0**: Camera-based QR/barcode scanning — 1M+ downloads, ML Kit/AVFoundation backend, torch control, auto-zoom, lifecycle management
- **qr_flutter ^4.1.0**: QR code rendering as Flutter widget — 1.4M downloads, pure Dart, configurable error correction, image export
- **sqflite ^2.4.1**: SQLite database for scan history — battle-tested, relational, no codegen overhead
- **permission_handler ^11.3.1**: Runtime permission requests — standard Flutter community package for camera/gallery permissions
- **image_gallery_saver ^2.0.3**: Save QR images to device gallery — handles Android Scoped Storage correctly
- **share_plus ^9.0.0**: Native share sheet integration — official Flutter community package
- **setState (built-in)**: State management — sufficient for this project size; no need for Riverpod/Bloc overhead

### Expected Features

**Must have (table stakes):**
- QR scanning via camera with real-time detection feedback — core purpose of the app
- Flash/torch toggle — essential for low-light scanning environments
- Display scanned content with URL detection and contextual actions (open, copy, share)
- QR generation from text/URL input with character counter (max 250)
- Save generated QR to gallery and share via native share sheet
- Copy scanned content to clipboard
- Scan history with local SQLite storage (max ~500 entries)
- Material 3 UI design
- 100% offline operation

**Should have (competitive):**
- Dark mode support — better UX in low-light scanning
- QR type presets (URL, WiFi, contact, email) — quick access templates
- Custom QR colors (foreground/background)
- Sound/vibration feedback on scan
- Barcode format support (EAN-13, UPC) — mobile_scanner already supports it

**Defer (v2+):**
- Scan from gallery/screenshots — out of scope per PROJECT.md
- Batch scanning — nice-to-have, low priority
- QR frames/borders — cosmetic, not essential
- CSV export — power user feature
- WiFi QR generation — out of scope

### Architecture Approach

A simplified MVVM pattern (Flutter team's recommended architecture) without a domain layer — appropriate for ~10 features, offline-only, no backend. Two-screen app: Scanner Screen (camera view + scan results) and Generator Screen (text input + QR preview). ViewModels handle state, Repositories abstract data access, and services handle platform-specific operations (sharing, clipboard, storage). Dependency injection via constructor or provider package keeps code testable.

**Major components:**
1. **ScannerScreen + ScannerViewModel** — Camera preview, scan detection, result display, action buttons
2. **GeneratorScreen + GeneratorViewModel** — Text input, QR rendering, save/share operations
3. **HistoryRepository + StorageService** — SQLite persistence for scan/generation history
4. **ShareService + ClipboardService** — Platform-specific sharing and clipboard operations
5. **App Shell (Navigation)** — Ties screens together with bottom navigation or tabs

### Critical Pitfalls

1. **Scanner Controller Lifecycle (Black Screen)** — After navigating away and back, camera preview shows black/frozen screen. Prevention: Call `controller.stop()` in `dispose()`, re-initialize in `initState()`, implement `WidgetsBindingObserver.didChangeAppLifecycleState`.

2. **Duplicate Scan Results** — Single QR triggers `onDetect` 5-20+ times per second. Prevention: Add `_hasScanned` boolean gate, call `controller.stop()` after first detection, use `DetectionSpeed.noDuplicates`.

3. **Camera Permission Rejection** — iOS App Store rejection or Android crash if permissions not configured. Prevention: Add `NSCameraUsageDescription` to Info.plist, request permission at runtime before scanning, show fallback UI if denied.

4. **Generated QR Unscannable** — QR codes with embedded logos or low contrast fail to scan. Prevention: Use error correction level H (30%), keep logos <30% area, test with 3 different scanner apps.

5. **R8/ProGuard Stripping ML Kit** — Release builds crash with `ClassNotFoundException`. Prevention: Add `-keep class com.google.mlkit.** { *; }` ProGuard rules, test release builds early.

## Implications for Roadmap

Based on research, suggested phase structure:

### Phase 1: Core Scanner
**Rationale:** The scanner is the hardest technical challenge (camera lifecycle, permission handling, duplicate detection). Building it first validates the riskiest integration and provides immediate user value. All critical pitfalls (#1, #2, #3, #11, #13, #14) must be addressed here.
**Delivers:** Working QR scanner with camera preview, real-time detection, torch toggle, URL detection, and basic action buttons (open/copy/share)
**Addresses:** QR scanning, real-time feedback, flash control, URL detection, clipboard copy, Material 3 UI
**Avoids:** Black screen lifecycle (#1), duplicate detections (#2), permission crashes (#3), non-QR barcode filtering (#11), app lifecycle resume (#13), release build crashes (#14)

### Phase 2: Core Generator
**Rationale:** QR generation is simpler (no camera, no hardware integration). Depends on nothing from Phase 1 except shared navigation. Can be built in parallel by a second developer if needed.
**Delivers:** QR generation from text/URL input, character counter, save to gallery, share via native sheet
**Uses:** qr_flutter for rendering, image_gallery_saver for gallery, share_plus for sharing, path_provider for temp files
**Implements:** GeneratorScreen, GeneratorViewModel, ShareService
**Avoids:** Unscannable QR (#5), data limits (#9), transparent background (#12), dependency conflicts (#10)

### Phase 3: History & Persistence
**Rationale:** History depends on both scanner and generator being complete (it stores records from both). SQLite schema is simple but needs careful design for query patterns. Depends on StorageService foundation.
**Delivers:** Scan/generation history with SQLite storage, history view with search/filter, history entry management
**Uses:** sqflite for database, StorageService, HistoryRepository
**Implements:** HistoryScreen, HistoryRepository, StorageService, data models (ScanRecord, GenerationRecord)
**Avoids:** None of the critical pitfalls — this phase is architecturally safe

### Phase 4: Polish & Differentiators
**Rationale:** These features add delight but aren't essential for core functionality. Depends on all previous phases being stable. Can be prioritized based on user feedback.
**Delivers:** Dark mode, QR type presets, custom colors, barcode format support, sound/vibration feedback, scan region overlay
**Addresses:** Differentiators from FEATURES.md
**Avoids:** Scoped storage permission hell (#8) — handled correctly in Phase 2

### Phase Ordering Rationale

- Scanner first because it has the most critical pitfalls and validates the riskiest integration (camera hardware)
- Generator second because it's independent and simpler, providing the second core function
- History third because it depends on both scanner and generator being complete
- Polish last because it adds value but isn't essential for the app to work

### Research Flags

Phases likely needing deeper research during planning:
- **Phase 1:** mobile_scanner version compatibility with current Flutter, platform-specific camera behavior differences, ProGuard configuration for release builds

Phases with standard patterns (skip research-phase):
- **Phase 2:** qr_flutter usage is well-documented with clear examples
- **Phase 3:** SQLite/sqflite patterns are well-established
- **Phase 4:** Flutter Material 3 theming has extensive documentation

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | All packages have 1M+ downloads, active maintenance (2026), clear documentation. pub.dev official docs verified. |
| Features | HIGH | Cross-verified against production QR scanner apps (Gamma Play, Air Apps, Uniqode). MVP phases align with user expectations. |
| Architecture | HIGH | Follows Flutter team's official architecture guide (MVVM). Patterns are well-documented with code examples. |
| Pitfalls | HIGH | Cross-verified across official docs, GitHub issues (#1694, #1452, #1298, #1365), and production post-mortems. Prevention patterns are concrete and testable. |

**Overall confidence:** HIGH

### Gaps to Address

- **image_gallery_saver maintenance:** Package works but is less maintained than others. May need fork for latest Flutter versions — test during Phase 2 setup.
- **mobile_scanner version 7.x migration:** Previous major version migrations existed. Pin version and test thoroughly on both platforms.
- **iOS device heating:** mobile_scanner 7.x claims to fix main-thread frame processing, but needs real-device validation during Phase 1.
- **ProGuard rules:** Specific ML Kit keep rules need verification against current mobile_scanner documentation — test release build early.

## Sources

### Primary (HIGH confidence)
- pub.dev/packages/mobile_scanner — official docs, 1M+ downloads, active maintenance
- pub.dev/packages/qr_flutter — official docs, 1.4M downloads
- pub.dev/packages/sqflite — official docs, industry standard
- pub.dev/packages/permission_handler — official Flutter community package
- pub.dev/packages/share_plus — official Flutter community package
- Flutter Official Architecture Guide — MVVM pattern, code examples

### Secondary (MEDIUM confidence)
- LeanCode: "QR Scanning in Flutter: Examples, Best Practices, Common Mistakes" — comprehensive pitfalls guide
- ASOasis: "Build a Flutter QR Code Scanner and Generator" (2026) — production testing checklist
- mobile_scanner GitHub Issues — real-world bug reports and solutions
- "The Flutter Local Database Landscape in 2026" — Luci Studio comparison

### Tertiary (LOW confidence)
- QRCodeFYI: Encoding modes and capacity guide — data limit specifications
- DENSO WAVE: QR Code capacity official specification — theoretical limits

---
*Research completed: 2026-06-27*
*Ready for roadmap: yes*
