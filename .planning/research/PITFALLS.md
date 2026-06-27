# Domain Pitfalls: QR Code Scanner & Generator (Flutter)

**Domain:** Mobile QR code scanner/generator Flutter app
**Researched:** 2026-06-27
**Overall confidence:** MEDIUM (findings cross-verified across official docs, GitHub issues, and production post-mortems)

## Critical Pitfalls

Mistakes that cause crashes, broken features, or require rewrites.

### Pitfall 1: Scanner Controller Lifecycle Mismanagement (Black Screen on Return)

**What goes wrong:** After navigating away from the scanner screen and back, the camera preview shows a black or frozen screen. The scanner appears dead.

**Why it happens:** The `MobileScannerController` is not properly stopped/disposed when the widget leaves the tree, and not properly re-initialized when it returns. Camera resources (hardware) remain locked by the previous instance.

**Consequences:** Users see a permanently black camera preview. Force-closing the app is the only recovery for many users. This is the #1 reported issue across all Flutter QR scanner packages.

**Prevention:**
- Call `controller.stop()` in `dispose()` or when the widget is removed from the tree.
- Re-initialize the controller in `initState()` when the screen is rebuilt.
- Wrap scanner lifecycle in `WidgetsBindingObserver.didChangeAppLifecycleState` to handle app backgrounding.
- Use `controller.start()` explicitly rather than relying on `autoStart`.

**Detection:** Test by scanning a QR code, navigating to another screen, then returning. If preview is black, lifecycle is broken.

**Phase:** Scanner implementation (early phase) — must get this right from the start.

---

### Pitfall 2: Duplicate Scan Results / Multiple Detections per QR Code

**What goes wrong:** A single QR code triggers the `onDetect` callback 5-20+ times. This causes multiple navigation pushes, duplicate database entries, or rapid-fire clipboard writes.

**Why it happens:** QR scanners detect the same code on every frame (30+ fps) while it stays in view. Most tutorials forget to gate the callback.

**Consequences:** Navigation stack corruption, duplicate entries in history, confusing UX, potential crashes from rapid state changes.

**Prevention:**
- Add a `_hasScanned` boolean flag. Set to `true` on first detection.
- Call `controller.stop()` immediately after first successful scan.
- For continuous scanning mode: debounce results with a cooldown timer (e.g., ignore same value for 2 seconds).
- Filter by `BarcodeFormat.qrCode` to avoid processing non-QR barcodes.

```dart
bool _hasScanned = false;

void _handleBarcode(BarcodeCapture capture) {
  if (_hasScanned) return;
  _hasScanned = true;
  controller.stop();
  // Process result...
}
```

**Detection:** Log the callback invocations. If count > 1 per scan, this pitfall is active.

**Phase:** Scanner implementation (early phase) — foundational bug.

---

### Pitfall 3: Camera Permission Not Handled at Runtime (iOS App Store Rejection / Android Crash)

**What goes wrong:** App crashes on first camera use, or Apple rejects the app during review because permission descriptions are missing or vague.

**Why it happens:** iOS requires `NSCameraUsageDescription` in `Info.plist` with a human-readable explanation. Android requires runtime permission requests. Many tutorials skip the `Info.plist` setup entirely.

**Consequences:** iOS: App Store rejection (guaranteed). Android: Crash on first camera open if permission not requested at runtime.

**Prevention:**
- Add `NSCameraUsageDescription` to `ios/Runner/Info.plist` with clear text like "This app needs camera access to scan QR codes."
- Add `NSPhotoLibraryAddUsageDescription` if saving QR images to gallery.
- Use `permission_handler` or `MobileScannerController`'s built-in permission handling.
- Check permission status before starting the scanner; show a fallback UI if denied.
- Never auto-request permission without explaining why first (UX best practice, Apple guideline).

**Detection:** Test on fresh install. Delete app, reinstall, verify permission dialog appears with clear text. Check App Store review guidelines.

**Phase:** Scanner setup (Phase 1) — must be configured before any scanning works.

---

### Pitfall 4: Using Deprecated `qr_code_scanner` Instead of `mobile_scanner`

**What goes wrong:** Project uses `qr_code_scanner` package, which is in maintenance mode since 2022. Underlying libraries (ZXing for Android, MTBBarcodeScanner for iOS) are unmaintained. No web/desktop support.

**Why it happens:** Older tutorials and Stack Overflow answers reference `qr_code_scanner`. It still installs and runs, masking the problem.

**Consequences:** No new features, no bug fixes, no web/desktop support, potential incompatibility with future Flutter versions. When issues arise (and they will), there's no path forward without a full migration.

**Prevention:**
- Use `mobile_scanner` exclusively for new projects.
- `mobile_scanner` uses ML Kit (Android) + AVFoundation/Vision (iOS) — actively maintained, supports all 6 Flutter targets.
- If migrating: API surface is similar; migration takes ~1 afternoon per the maintainers.

**Detection:** Check `pubspec.yaml` — if `qr_code_scanner` is listed, it's the wrong package.

**Phase:** Stack decision (pre-Phase 1) — must choose correctly before writing code.

---

### Pitfall 5: Generated QR Code Unscannable Due to Embedded Logo / Low Contrast

**What goes wrong:** QR codes generated with an embedded logo or custom colors fail to scan on most devices.

**Why it happens:** Logos cover QR modules that encode data. Without sufficient error correction, the code becomes unreadable. Low contrast (e.g., light gray on white) defeats camera detection.

**Consequences:** Users generate QR codes that don't work. Trust is destroyed. No obvious error — the QR looks "fine" but scanners reject it.

**Prevention:**
- Use `errorCorrectionLevel: QrErrorCorrectLevel.H` (30% recovery) when embedding images.
- Keep embedded logo smaller than 30% of QR code area.
- Always use high contrast: dark foreground on light background.
- Ensure white quiet zone (padding) around the QR code.
- Test generated QR codes with at least 3 different scanner apps before shipping.

**Detection:** Generate a QR with a logo, scan with 3 devices. If any fail, pitfall is active.

**Phase:** Generator implementation (Phase 2) — affects core feature quality.

---

## Moderate Pitfalls

Issues that cause degraded UX, performance problems, or maintenance burden.

### Pitfall 6: Not Pausing Scanner When Processing Results (UI Jank)

**What goes wrong:** UI stutters or freezes when a QR code is detected, especially on Android.

**Why it happens:** The scanner continues processing frames at 30fps while the app is handling the result (showing dialog, navigating, etc.). Each frame triggers ML Kit inference on the main thread.

**Consequences:** Perceptible lag, dropped frames, poor UX. On older devices, the app may become unresponsive.

**Prevention:**
- Call `controller.stop()` or pause scanning immediately in the `onDetect` callback.
- Resume with `controller.start()` only after processing is complete (e.g., dialog dismissed).
- For continuous scanning: use `DetectionSpeed.normal` instead of `unrestricted` to throttle detection.

**Phase:** Scanner implementation (Phase 1) — performance baseline.

---

### Pitfall 7: iOS Device Heating Due to Main Thread Camera Frames

**What goes wrong:** iOS devices heat up noticeably when the scanner screen is open for 3+ minutes.

**Why it happens:** `mobile_scanner` (pre-fix versions) delivers camera frames at 30fps on Flutter's main/UI thread via `DispatchQueue.main`. This creates continuous main thread pressure plus concurrent ML Kit inference.

**Consequences:** User discomfort, battery drain, potential thermal throttling degrading scan performance.

**Prevention:**
- Update to latest `mobile_scanner` version (7.x+) which moved frame processing off the main thread.
- If on older version: limit scan duration with a timeout, or use `DetectionSpeed.normal` to reduce frame rate.
- Monitor for heating during testing; if device gets warm, investigate frame processing thread.

**Phase:** Scanner implementation (Phase 1) — affects real-world usability.

---

### Pitfall 8: Gallery Save Permission Hell (Android Scoped Storage)

**What goes wrong:** Saving generated QR codes to gallery fails on Android 10+ with `Permission denied` errors.

**Why it happens:** Android 10+ introduced Scoped Storage. `requestLegacyExternalStorage` is ignored on Android 11+. `MANAGE_EXTERNAL_STORAGE` is rejected by Google Play for image-saving use cases.

**Consequences:** Users can't save QR codes. The "Save to Gallery" button silently fails or crashes.

**Prevention:**
- Use `image_gallery_saver` or `gal` package which handle Scoped Storage correctly.
- On Android 10+: Use MediaStore API (handled by these packages internally).
- On iOS: Add `NSPhotoLibraryAddUsageDescription` to `Info.plist`.
- Request permission only when user taps "Save", not on app startup.
- Handle the case where permission is denied gracefully (show share sheet instead).

**Phase:** Gallery feature (Phase 2-3) — platform-specific complexity.

---

### Pitfall 9: QR Code Data Exceeding Practical Scan Limits

**What goes wrong:** Generated QR codes with long text (200+ characters) produce dense, tiny modules that fail to scan on low-quality cameras.

**Why it happens:** QR versions scale up to 177x177 modules (Version 40) for maximum data. But at small physical sizes, individual modules become invisible to cameras.

**Consequences:** QR codes look correct but can't be scanned. Users blame the scanner, not the generator.

**Prevention:**
- Enforce the 250-character limit from PROJECT.md — this is already a good constraint.
- Use error correction level M (15% recovery) as default — balances density and reliability.
- Warn users when approaching the limit (e.g., "QR code may be difficult to scan at this length").
- For URLs: consider suggesting URL shorteners for very long links.
- Test at realistic physical sizes (5cm x 5cm on screen, printed at 3cm x 3cm).

**Phase:** Generator validation (Phase 2) — user-facing quality gate.

---

### Pitfall 10: `qr_flutter` Version Conflict with `printing`/`barcode` Packages

**What goes wrong:** Adding `qr_flutter` alongside `printing` or `barcode` packages causes pub dependency resolution failures.

**Why it happens:** `qr_flutter` depends on `qr ^2.0.0`, while newer `barcode` packages depend on `qr ^3.0.0`. These are incompatible.

**Consequences:** Build fails before any code is written. Developers waste hours debugging dependency trees.

**Prevention:**
- Use `qr_flutter ^5.x` which updated its `qr` dependency.
- If conflict persists: use `qr_widget` (maintained fork) or `barcode` package directly for generation.
- Avoid adding both `qr_flutter` and `printing` in the same project unless verified compatible.

**Phase:** Stack setup (pre-Phase 1) — dependency hell prevents any progress.

---

## Minor Pitfalls

Issues that cause annoyance, edge-case bugs, or tech debt.

### Pitfall 11: Not Filtering Barcode Formats (Scanning Non-QR Barcodes)

**What goes wrong:** Scanner picks up EAN-13, Code 128, or other barcodes when only QR codes are intended.

**Why it happens:** `mobile_scanner` supports all barcode formats by default. Tutorials don't filter.

**Consequences:** Confusing results — user expects QR content but gets a product barcode number.

**Prevention:**
- Configure `formats: [BarcodeFormat.qrCode]` in `MobileScannerController`.
- This reduces processing load and prevents false positives.

**Phase:** Scanner configuration (Phase 1) — simple fix, often overlooked.

---

### Pitfall 12: Transparent Background on Saved QR Image (Shows Black When Shared)

**What goes wrong:** Shared QR code image has black background instead of white, making it unscannable.

**Why it happens:** `QrPainter.toImageData()` renders with transparent background by default. When shared via apps that composite on dark backgrounds, the transparent areas become black.

**Consequences:** QR codes appear broken when shared via messaging apps or social media.

**Prevention:**
- Wrap `QrImageView` in a `Container` with `color: Colors.white`.
- Use `RepaintBoundary` approach instead of `QrPainter.toImageData()` for sharing.
- Set `backgroundColor: Colors.white` explicitly on the QR widget.

**Phase:** Generator/sharing (Phase 2) — affects share quality.

---

### Pitfall 13: Not Handling App Lifecycle Changes (Scanner Doesn't Resume After Background)

**What goes wrong:** After putting app in background and returning, scanner doesn't resume automatically.

**Why it happens:** `didChangeAppLifecycleState` is not implemented or incorrectly implemented. Permission dialogs also trigger lifecycle changes, creating race conditions.

**Consequences:** Users must navigate away and back to restart scanning. Poor UX.

**Prevention:**
- Implement `WidgetsBindingObserver` with `didChangeAppLifecycleState`.
- On `resumed`: check permission state, then `controller.start()`.
- On `paused`: `controller.stop()`.
- Guard against re-requesting permission during lifecycle transitions.

**Phase:** Scanner UX (Phase 1) — polish-level but expected behavior.

---

### Pitfall 14: R8/ProGuard Stripping ML Kit Classes in Release Builds

**What goes wrong:** App works in debug but crashes in release mode on Android with `ClassNotFoundException` for ML Kit classes.

**Why it happens:** R8 minification strips ML Kit classes it doesn't see referenced directly from Dart code.

**Consequences:** Release builds crash immediately when scanner opens.

**Prevention:**
- Add ProGuard rules: `-keep class com.google.mlkit.** { *; }`
- Add ML Kit dependencies explicitly in `android/app/build.gradle`:
  ```
  implementation "com.google.mlkit:barcode-scanning:17.2.0"
  ```
- Test release builds before shipping (not just debug).

**Phase:** Build configuration (Phase 1) — release-blocking if missed.

---

### Pitfall 15: Low Camera FPS Due to Default Preset (iOS)

**What goes wrong:** Camera preview runs at ~30fps or lower, making scan feel sluggish compared to native QR scanner apps.

**Why it happens:** `mobile_scanner` defaults to `AVCaptureSession.Preset.photo` on iOS, which limits frame rate. CameraX on Android also defaults to lower FPS.

**Consequences:** Slower detection, especially in motion or low-light conditions.

**Prevention:**
- For iOS: The latest `mobile_scanner` versions allow FPS configuration.
- For Android: Use `ResolutionPreset.medium` — good detection without excessive resource use.
- Test on low-end devices to establish minimum acceptable scan speed.

**Phase:** Scanner optimization (Phase 2) — performance tuning.

---

## Phase-Specific Warnings

| Phase | Likely Pitfall | Mitigation |
|-------|---------------|------------|
| **Scanner Setup** | Permission handling (#3), Controller lifecycle (#1) | Follow `mobile_scanner` README exactly; test permission flow on fresh install |
| **Scanner Core** | Duplicate detections (#2), Black screen (#1) | Implement debounce + stop-after-detect pattern from day 1 |
| **Scanner Polish** | Lifecycle resume (#13), Camera FPS (#15) | Implement `WidgetsBindingObserver`; test on real devices, not emulators |
| **Generator Setup** | Logo/unscannable QR (#5), Data limits (#9) | Test every generated QR with 3 scanner apps; enforce 250-char limit |
| **Generator Polish** | Transparent background (#12), Dependency conflicts (#10) | Use white container wrapper; verify pub dependencies before adding packages |
| **Gallery/Share** | Android Scoped Storage (#8), Permission denial | Use `image_gallery_saver` or `gal`; request permission on tap, not startup |
| **Build/Release** | ProGuard stripping (#14), Release crashes | Test release builds; add ML Kit keep rules |
| **Package Choice** | Using deprecated `qr_code_scanner` (#4) | Use `mobile_scanner` exclusively |

## Sources

- LeanCode: "QR Scanning in Flutter: Examples, Best Practices, Common Mistakes" — comprehensive pitfalls guide (leancode.co)
- ASOasis: "Build a Flutter QR Code Scanner and Generator" (2026-04-28) — production testing checklist
- ASOasis: "Flutter barcode scanning with the camera plugin" (2026-03-24) — performance patterns
- mobile_scanner GitHub Issues: #1694 (iOS heating), #1452 (slow scanning), #1298 (Android jank), #1365 (UI lag), #1541 (permission state), #847 (permission refresh), #509 (permission loop)
- qr_code_scanner GitHub: Issue #491 (maintenance mode announcement)
- FlutterTrends: mobile_scanner vs qr_code_scanner comparison (28K vs 7K daily downloads)
- DENSO WAVE: QR Code capacity official specification (qrcode.com)
- QRCodeFYI: Encoding modes and capacity guide
- FreeQR: "QR Code Data Limits" (2026-03-24) — practical capacity limits
- image_gallery_saver GitHub: Issue #214 (permission denied), Issue #163 (Scoped Storage)
- FWC Tecnologia: "QR Codes in Mobile Apps 2026: Engineering Guide" — security pitfalls

---

*This file feeds into roadmap planning. Phase-specific warnings above should be used to allocate research flags and testing requirements per phase.*
