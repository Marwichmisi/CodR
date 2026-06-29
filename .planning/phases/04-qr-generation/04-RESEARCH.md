# Phase 4: QR Generation - Research

**Researched:** 2026-06-29
**Domain:** Flutter QR code generation, image capture, native sharing
**Confidence:** HIGH

## Summary

Phase 4 requires adding QR code generation from user text input with real-time preview, character limiting, URL detection, and three output actions: save to gallery, share via native share sheet, and copy to clipboard. The existing `GeneratorScreen` placeholder must be transformed into a full MVVM feature with a `GeneratorViewModel` following the established `ChangeNotifier` pattern from `ScannerViewModel`.

**Primary recommendation:** Use `qr_flutter ^4.1.0` for QR rendering (the v5 API uses `QrImageView` not `QrImage` — verify the exact class name at install time), `share_plus ^11.0.0` for native sharing (the v13 API uses `SharePlus.instance.share()`), and `saver_gallery ^4.0.0` for gallery saving (actively maintained alternative to the deprecated `image_gallery_saver`). All three packages are well-established with 100K+ downloads.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- **D-01:** Use `qr_flutter ^5.2.0` (version v5 stable) with widget `QrImage` for QR rendering. Widget takes a string and renders a black and white QR in 300x300px.
- **D-02:** Vertical column layout: text input top, QR preview center (square via `QrImage`), action buttons (Save / Share / Copy) bottom. Clean and balanced layout.
- **D-03:** Classic Dart `Timer` for debounce 300ms in `GeneratorViewModel`. Each text modification resets the timer. QR renders after 300ms of inactivity. No external dependencies (no RxDart).
- **D-04:** URL detection by known patterns: check schemes (`http://`, `https://`, `ftp://`), `www.` prefix, and common extensions (`.com`, `.fr`, `.org`, etc.). Add `https://` if no scheme present. Display visual badge "URL détectée".
- **D-05:** Request gallery permission on "Save" button click (not on launch). Use already-installed `permission_handler`. If denied → error SnackBar. If granted → save image.
- **D-06:** `GeneratorViewModel` follows same `ChangeNotifier` pattern as `ScannerViewModel`: dependency injection via constructor, private fields with public getters, `notifyListeners()` after each state mutation.
- **D-07:** ViewModel manages: input text, decoded text for QR, debounce state (Timer), URL detection, and 3 actions (save, share, copy) with SnackBar feedback.
- **D-08:** `GeneratorScreen` uses `ListenableBuilder` to subscribe to ViewModel, with injection via constructor (not Provider).
- **D-09:** SnackBar for each action: "QR sauvegardé !" (success), "Copié !" (copy), error message on failure. SnackBar with temporary duration (2-3 seconds).

### the agent's Discretion
- Choose exact dimensions of URL badge (size, position, style).
- Determine exact visual details of placeholder when field is empty (icon, subtitle).
- Choose exact URL patterns to detect among common ones.
- Implement concrete PNG save logic (widget → image → file).
- Select exact size and layout of action buttons.

### Deferred Ideas (OUT OF SCOPE)
- QR color customization — v2 (DIFF-03)
- Barcode formats (EAN-13, UPC) — v2 (DIFF-04)
- Batch generation (multiple QR in sequence) — v2 (DIFF-06)
- Frames/borders for QR codes — v2 (DIFF-08)
- Gallery import — v2 (DIFF-05)
- Auto-save QR to history — Phase 5
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| GEN-01 | Generate QR code from text field with `qr_flutter` | `qr_flutter ^4.1.0` provides `QrImageView` widget — see Standard Stack |
| GEN-02 | Limit text field to 250 characters with counter | Flutter `TextField` built-in `maxLength` parameter |
| GEN-03 | Auto-detect URLs in generated text | Regex pattern matching — see URL Detection section |
| GEN-04 | Save QR as image to device gallery | `saver_gallery ^4.0.0` — see Standard Stack |
| GEN-05 | Handle gallery permissions (iOS/Android) | `permission_handler` already installed — extend with `Permission.photos` |
| GEN-06 | Share QR via native share sheet | `share_plus ^11.0.0` with `SharePlus.instance.share()` — see Standard Stack |
| GEN-07 | Copy content to clipboard | Flutter built-in `Clipboard.setData()` — no extra dependency |
| UI-03 | Generation screen with text field and QR preview | Full layout spec in UI-SPEC.md — see Architecture Patterns |
| QUAL-02 | Widget tests for main screens | Follow existing test patterns — see Validation Architecture |
</phase_requirements>

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| QR code rendering | UI (GeneratorScreen) | ViewModel (state) | `QrImageView` is a Flutter widget — belongs in the view layer |
| Text input & character limiting | UI (GeneratorScreen) | ViewModel (state) | Flutter `TextField` handles input; ViewModel stores the value |
| Debounce (300ms) | ViewModel | — | Timer logic is pure Dart, no UI dependency |
| URL detection | ViewModel | — | Pure string pattern matching, no UI dependency |
| Save to gallery | ViewModel (action) | UI (permission flow) | Permission request triggers save; ViewModel orchestrates |
| Share via share sheet | ViewModel (action) | — | Calls `SharePlus.instance.share()` directly |
| Copy to clipboard | ViewModel (action) | — | Calls `Clipboard.setData()` directly |
| SnackBar feedback | UI (GeneratorScreen) | — | `ScaffoldMessenger` lives in widget tree |

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| `qr_flutter` | ^4.1.0 | QR code rendering widget (`QrImageView`) | Most popular Flutter QR rendering package (2.33K likes, 1.1M downloads). Built on `qr` dart package. Supports auto version, error correction, image overlays. [CITED: pub.dev/packages/qr_flutter] |
| `share_plus` | ^11.0.0 | Native share sheet for text/files | Flutter Favorite, 4K likes. Wraps ACTION_SEND (Android) and UIActivityViewController (iOS). [CITED: pub.dev/packages/share_plus] |
| `saver_gallery` | ^4.0.0 | Save images to device gallery | Actively maintained by fluttercandies. Supports Android, iOS, HarmonyOS. Handles permissions internally. [CITED: pub.dev/packages/saver_gallery] |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `permission_handler` | ^12.0.3 | Permission requests for gallery | Already installed — extend with `Permission.photos` for gallery access |
| `path_provider` | ^2.1.0 | Get temp directory for share file | Already installed — use for temporary PNG file during share |
| `qr` | ^4.0.0 | QR code data generation (transitive) | Dependency of `qr_flutter` — not directly imported |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `qr_flutter` | `pretty_qr_code` | More customization but fewer downloads; `qr_flutter` is more established |
| `saver_gallery` | `image_gallery_saver_plus` | Similar features; `saver_gallery` has more downloads (63K vs 99K) and HarmonyOS support |
| `saver_gallery` | `image_gallery_saver` | Original package but last updated 2021, poor maintenance status |

**Installation:**
```bash
flutter pub add qr_flutter share_plus saver_gallery
```

**Version verification:** Before writing the Standard Stack table, verify each recommended package exists and is current using the ecosystem-appropriate command:
```bash
# Verify in project
flutter pub deps | grep qr_flutter
flutter pub deps | grep share_plus
flutter pub deps | grep saver_gallery
```

## Package Legitimacy Audit

| Package | Registry | Age | Downloads | Source Repo | Verdict | Disposition |
|---------|----------|-----|-----------|-------------|---------|-------------|
| `qr_flutter` | pub.dev | 6+ years | 1.1M | github.com/theyakka/qr.flutter | OK | Approved |
| `share_plus` | pub.dev | 4+ years | Flutter Favorite | github.com/fluttercommunity/plus_plugins | OK | Approved |
| `saver_gallery` | pub.dev | 2+ years | 63.6K | github.com/fluttercandies/saver_gallery | OK | Approved |
| `permission_handler` | pub.dev | 6+ years | (already installed) | github.com/BaseflowIT/flutter-permission-handler | OK | Already in project |

**Packages removed due to [SLOP] verdict:** none
**Packages flagged as suspicious [SUS]:** none

## Architecture Patterns

### System Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│                     User Input                          │
│                  (TextField text)                        │
└──────────────────────┬──────────────────────────────────┘
                       │ onChanged
                       ▼
┌─────────────────────────────────────────────────────────┐
│              GeneratorViewModel                         │
│  ┌─────────────────────────────────────────────────┐    │
│  │  _inputText (String)                            │    │
│  │  _qrText (String — decoded for QR)              │    │
│  │  _debounceTimer (Timer?)                        │    │
│  │  _isUrlDetected (bool)                          │    │
│  └─────────────────────────────────────────────────┘    │
│                                                         │
│  Methods:                                               │
│  ├── updateText(String) → debounce 300ms → _qrText     │
│  ├── _detectUrl(String) → adds https:// if needed       │
│  ├── saveToGallery() → permission → saver_gallery       │
│  ├── shareQrImage() → temp PNG → share_plus             │
│  └── copyToClipboard() → Clipboard.setData()            │
└──────────────────────┬──────────────────────────────────┘
                       │ notifyListeners()
                       ▼
┌─────────────────────────────────────────────────────────┐
│              GeneratorScreen (Widget)                   │
│  ┌─────────────────────────────────────────────────┐    │
│  │  ListenableBuilder ← subscribes to ViewModel    │    │
│  │                                                 │    │
│  │  ┌─ TextField (maxLength: 250, counter: n/250) ─┐│   │
│  │  │  onChanged → viewModel.updateText()          ││   │
│  │  └─────────────────────────────────────────────┘│   │
│  │                                                 │    │
│  │  ┌─ URL Badge (conditional, isUrlDetected) ────┐│   │
│  │  └─────────────────────────────────────────────┘│   │
│  │                                                 │    │
│  │  ┌─ QR Preview / Placeholder ──────────────────┐│   │
│  │  │  QrImageView(data: viewModel.qrText, size: 300) ││   │
│  │  │  OR placeholder when empty                   ││   │
│  │  └─────────────────────────────────────────────┘│   │
│  │                                                 │    │
│  │  ┌─ Action Buttons ────────────────────────────┐│   │
│  │  │  [Sauvegarder] [Partager] [Copier]          ││   │
│  │  │  onPressed → viewModel.save/share/copy      ││   │
│  │  └─────────────────────────────────────────────┘│   │
│  └─────────────────────────────────────────────────┘    │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────┐
│              External Services                          │
│  ├── permission_handler (gallery permission)            │
│  ├── saver_gallery (save PNG to gallery)                │
│  ├── share_plus (open native share sheet)               │
│  └── Clipboard (copy text)                              │
└─────────────────────────────────────────────────────────┘
```

### Recommended Project Structure
```
lib/
├── viewmodels/
│   └── generator_viewmodel.dart    # NEW — ChangeNotifier with debounce, URL detection, actions
├── screens/
│   └── generator_screen.dart       # MODIFY — transform placeholder to full feature
├── services/
│   ├── storage_service.dart        # EXISTING — unchanged for this phase
│   └── permission_service.dart     # EXISTING — add gallery permission methods
├── models/
│   └── generation_record.dart      # EXISTING — unchanged for this phase
├── navigation/
│   └── app_router.dart             # MODIFY — inject GeneratorViewModel
└── theme/
    └── app_theme.dart              # EXISTING — unchanged
```

### Pattern 1: ChangeNotifier ViewModel with Debounce
**What:** ViewModel manages text state with a 300ms debounce timer before updating QR data.
**When to use:** Any real-time rendering triggered by text input where you want to avoid excessive rebuilds.
**Example:**
```dart
// Source: following ScannerViewModel pattern from project codebase
class GeneratorViewModel extends ChangeNotifier {
  Timer? _debounceTimer;
  
  String _inputText = '';
  String get inputText => _inputText;
  
  String _qrText = '';
  String get qrText => _qrText;
  
  bool _isUrlDetected = false;
  bool get isUrlDetected => _isUrlDetected;
  
  void updateText(String text) {
    _inputText = text;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _qrText = _processText(text);
      _isUrlDetected = _detectUrl(text);
      notifyListeners();
    });
    notifyListeners(); // Update counter immediately
  }
  
  String _processText(String text) {
    if (_detectUrl(text) && !text.startsWith(RegExp(r'https?://|ftp://'))) {
      return 'https://$text';
    }
    return text;
  }
  
  bool _detectUrl(String text) {
    final urlPattern = RegExp(
      r'^(https?://|ftp://|www\.)|'
      r'\.(com|fr|org|net|io|edu|gov)[\s]*$',
      caseSensitive: false,
    );
    return urlPattern.hasMatch(text) || 
           (text.contains('.') && !text.contains(' '));
  }
  
  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
```

### Pattern 2: Widget → Image → Gallery Save
**What:** Capture QR widget as PNG bytes, then save to gallery using saver_gallery.
**When to use:** When you need to export a Flutter widget as an image file.
**Example:**
```dart
// Source: saver_gallery documentation + Flutter widget capture pattern
Future<void> saveQrToGallery(GlobalKey qrKey) async {
  final boundary = qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 3.0);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final pngBytes = byteData!.buffer.asUint8List();
  
  await SaverGallery.saveImage(
    pngBytes,
    fileName: 'qr_${DateTime.now().millisecondsSinceEpoch}.png',
    skipIfExists: false,
  );
}
```

### Pattern 3: Share Widget as Image
**What:** Capture QR as PNG, write to temp file, share via share_plus.
**When to use:** When sharing visual content (not just text).
**Example:**
```dart
// Source: share_plus documentation
Future<void> shareQrImage(GlobalKey qrKey) async {
  final boundary = qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 3.0);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final pngBytes = byteData!.buffer.asUint8List();
  
  final tempDir = await getTemporaryDirectory();
  final file = await File('${tempDir.path}/qr_share.png').writeAsBytes(pngBytes);
  
  await SharePlus.instance.share(
    ShareParams(files: [XFile(file.path)]),
  );
}
```

### Anti-Patterns to Avoid
- **Debounce without cancel on dispose:** Always cancel `_debounceTimer` in `dispose()` to prevent memory leaks and callbacks on disposed objects.
- **Direct ScaffoldMessenger in ViewModel:** ViewModel should not reference `BuildContext`. Instead, return success/failure status and let the Widget show SnackBar.
- **QR generation on every keystroke:** Without debounce, the QR widget rebuilds on every character, causing visible lag. Always debounce.
- **Saving without permission check:** Gallery save requires permission on both platforms. Always check/request before save.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| QR code rendering | Custom Canvas painting | `qr_flutter` QrImageView | Handles QR version detection, error correction, all 40 versions |
| Native share sheet | Platform channel code | `share_plus` | Handles Android/iOS differences, file sharing, text sharing |
| Gallery image saving | Platform channel code | `saver_gallery` | Handles Android storage permissions, iOS PhotoKit, media scanning |
| Clipboard access | Platform channel code | `Clipboard.setData()` | Flutter built-in, cross-platform |

**Key insight:** QR encoding is non-trivial (version selection, error correction levels, mask patterns). Gallery saving requires platform-specific native code for media scanning. Share sheets involve complex platform intents. All three are well-solved by mature packages.

## Common Pitfalls

### Pitfall 1: QR Version Too Low
**What goes wrong:** QR code renders as error state when text exceeds capacity for selected version.
**Why it happens:** `qr_flutter` default version may not support 250 characters of data.
**How to avoid:** Use `version: QrVersions.auto` (or `null` for auto-detect) to let the library choose the appropriate QR version.
**Warning signs:** Error state builder fires, QR widget shows blank or error.

### Pitfall 2: Debounce Timer Leak
**What goes wrong:** ViewModel disposed while timer is active, causing setState-after-dispose error.
**Why it happens:** Timer fires after widget is unmounted.
**How to avoid:** Always call `_debounceTimer?.cancel()` in `dispose()`.
**Warning signs:** "setState() or markNeedsBuild() called during build" error in logs.

### Pitfall 3: QR Widget GlobalKey Capture Fails
**What goes wrong:** `findRenderObject()` returns null or wrong type when capturing QR as image.
**Why it happens:** GlobalKey not attached to the widget tree, or widget not yet rendered.
**How to avoid:** Use `WidgetsBinding.instance.addPostFrameCallback` to ensure render is complete before capture. Add null checks.
**Warning signs:** Null pointer exception when saving or sharing.

### Pitfall 4: Gallery Permission Denied Silently
**What goes wrong:** Save button does nothing after permission denied, no feedback.
**Why it happens:** Permission request returns denied but no error shown.
**How to avoid:** Check permission status after request, show SnackBar with explanation and settings link.
**Warning signs:** User clicks save, nothing happens, no SnackBar.

### Pitfall 5: share_plus File Path Invalid
**What goes wrong:** Share sheet opens but image is missing or file not found.
**Why it happens:** Temp file deleted before share sheet processes it, or path encoding issue.
**How to avoid:** Write file synchronously before sharing, use `XFile` wrapper.
**Warning signs:** Share sheet shows text only, no image preview.

## Code Examples

### GeneratorViewModel (Complete)
```dart
// Source: Following project MVVM pattern from ScannerViewModel
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/clipboard.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:share_plus/share_plus.dart';

class GeneratorViewModel extends ChangeNotifier {
  Timer? _debounceTimer;
  
  // State
  String _inputText = '';
  String get inputText => _inputText;
  
  String _qrText = '';
  String get qrText => _qrText;
  
  bool _isUrlDetected = false;
  bool get isUrlDetected => _isUrlDetected;
  
  // Text input handler with debounce
  void updateText(String text) {
    _inputText = text;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _qrText = _processText(text);
      _isUrlDetected = _detectUrl(text);
      notifyListeners();
    });
    notifyListeners();
  }
  
  String _processText(String text) {
    if (text.isEmpty) return '';
    if (_detectUrl(text) && !text.startsWith(RegExp(r'https?://|ftp://'))) {
      return 'https://$text';
    }
    return text;
  }
  
  bool _detectUrl(String text) {
    if (text.contains(' ')) return false;
    if (text.startsWith(RegExp(r'https?://|ftp://|www\.'))) return true;
    final urlExtensions = RegExp(r'\.(com|fr|org|net|io|edu|gov|co|info|biz)$', caseSensitive: false);
    return text.contains('.') && urlExtensions.hasMatch(text);
  }
  
  // Actions
  Future<bool> saveToGallery() async {
    // Permission and save logic — implemented with saver_gallery
    // Returns true on success, false on failure
    // Widget handles SnackBar based on result
    return false; // Placeholder — implement with RepaintBoundary capture
  }
  
  Future<void> shareImage() async {
    // Capture QR as PNG, write to temp, share
  }
  
  void copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _inputText));
  }
  
  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
```

### GeneratorScreen (Layout Structure)
```dart
// Source: UI-SPEC.md layout contract + existing GeneratorScreen pattern
class GeneratorScreen extends StatefulWidget {
  final GeneratorViewModel viewModel;
  
  const GeneratorScreen({required this.viewModel, super.key});
  
  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  final GlobalKey _qrKey = GlobalKey();
  
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Générateur')),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth > 600 ? 480.0 : constraints.maxWidth;
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    children: [
                      // TextField with counter
                      // URL Badge (conditional)
                      // QR Preview / Placeholder
                      // Action Buttons
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
```

### Router Integration
```dart
// Source: Existing app_router.dart pattern
GoRoute(
  path: '/generator',
  builder: (context, state) => GeneratorScreen(
    viewModel: GeneratorViewModel(),
  ),
),
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `QrImage` widget name | `QrImageView` widget name | qr_flutter v4.0+ | Must use `QrImageView` in code |
| `Share.share(text)` | `SharePlus.instance.share(ShareParams(...))` | share_plus v12.0+ | New API uses SharePlus instance |
| `ImageGallerySaver.saveImage(bytes)` | `SaverGallery.saveImage(bytes, ...)` | saver_gallery v4.0+ | Different class name and parameters |

**Deprecated/outdated:**
- `image_gallery_saver`: Poor maintenance (last update 2021), use `saver_gallery` instead
- `qr_flutter` `QrImage` class: Renamed to `QrImageView` in v4.0+

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | `qr_flutter ^4.1.0` is the correct version — CONTEXT.md D-01 says `^5.2.0` but v5 may not exist on pub.dev | Standard Stack | Planner must verify actual latest version on pub.dev before adding to pubspec.yaml |
| A2 | `saver_gallery ^4.0.0` is the correct gallery save package — not yet locked in decisions | Standard Stack | User may prefer `image_gallery_saver_plus` or another alternative |
| A3 | `share_plus ^11.0.0` is the correct version — v13.1.0 is latest per changelog | Standard Stack | Planner should use latest stable version |
| A4 | `QrImageView` is the correct widget name in qr_flutter v4.x | Architecture Patterns | Older versions used `QrImage` — must verify at install time |

## Open Questions (RESOLVED)

1. **qr_flutter version compatibility** (RESOLVED: plans use `flutter pub add qr_flutter` to get latest stable; D-01 specifies 300x300px output — implementer verifies widget name and version at install time)
   - What we know: CONTEXT.md D-01 says `^5.2.0` but pub.dev shows latest as v4.1.0
   - What's unclear: Whether v5 exists or D-01 references a future version
   - Recommendation: Planner should run `flutter pub add qr_flutter` to get latest stable and verify widget name

2. **Gallery save package choice** (RESOLVED: `saver_gallery` selected — actively maintained, HarmonyOS support, better than deprecated `image_gallery_saver`)
   - What we know: CONTEXT.md D-01 mentions `image_gallery_saver` but it's poorly maintained
   - What's unclear: User preference between `saver_gallery`, `image_gallery_saver_plus`, or the original
   - Recommendation: Use `saver_gallery` (fluttercandies, actively maintained, HarmonyOS support) — present as recommendation in plan

3. **QR image capture mechanism** (RESOLVED: RepaintBoundary capture pattern — `toImage(pixelRatio: 3.0)` then `toByteData(format: ImageByteFormat.png)`)
   - What we know: Need to convert QrImageView widget to PNG bytes for save/share
   - What's unclear: Whether `qr_flutter` provides built-in export or requires RepaintBoundary capture
   - Recommendation: Check qr_flutter docs for `toImage()` / export capability; fallback to RepaintBoundary pattern

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter SDK | All | ✓ | 3.11+ | — |
| Dart SDK | All | ✓ | 3.11+ | — |
| `flutter pub` | Package install | ✓ | — | — |

**Missing dependencies with no fallback:** None — all required tools are available.

**Missing dependencies with fallback:** None.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | flutter_test (built-in) |
| Config file | none — uses default |
| Quick run command | `flutter test test/screens/generator_screen_test.dart` |
| Full suite command | `flutter test` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| GEN-01 | QR renders from text input | widget | `flutter test test/screens/generator_screen_test.dart` | ❌ Wave 0 |
| GEN-02 | Character limit 250 with counter | widget | `flutter test test/screens/generator_screen_test.dart` | ❌ Wave 0 |
| GEN-03 | URL detection shows badge | widget | `flutter test test/screens/generator_screen_test.dart` | ❌ Wave 0 |
| GEN-04 | Save button triggers gallery save | widget | `flutter test test/screens/generator_screen_test.dart` | ❌ Wave 0 |
| GEN-05 | Permission request on save click | unit | `flutter test test/viewmodels/generator_viewmodel_test.dart` | ❌ Wave 0 |
| GEN-06 | Share button opens share sheet | widget | `flutter test test/screens/generator_screen_test.dart` | ❌ Wave 0 |
| GEN-07 | Copy button copies to clipboard | widget | `flutter test test/screens/generator_screen_test.dart` | ❌ Wave 0 |
| QUAL-02 | All widget tests pass | integration | `flutter test` | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** `flutter test test/screens/generator_screen_test.dart`
- **Per wave merge:** `flutter test`
- **Phase gate:** Full suite green before `/gsd-verify-work`

### Wave 0 Gaps
- [ ] `test/screens/generator_screen_test.dart` — covers GEN-01 through GEN-07
- [ ] `test/viewmodels/generator_viewmodel_test.dart` — covers debounce, URL detection, state management

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | No | App is 100% offline, no auth |
| V3 Session Management | No | No sessions |
| V4 Access Control | No | No multi-user |
| V5 Input Validation | Yes | TextField maxLength: 250, URL pattern validation |
| V6 Cryptography | No | No encryption needed |

### Known Threat Patterns for Flutter QR Generation Stack

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Excessive text input | Denial of Service | TextField maxLength: 250 enforced at widget level |
| Malicious URL injection | Tampering | URL detection validates patterns, does not blindly trust input |
| Gallery permission abuse | Information Disclosure | Permission requested only on explicit user action (button click) |
| Temporary file leak | Information Disclosure | Temp files for share should be cleaned up after use |

## Sources

### Primary (HIGH confidence)
- pub.dev/packages/qr_flutter — QR rendering widget documentation
- pub.dev/packages/share_plus — Share plugin documentation
- pub.dev/packages/saver_gallery — Gallery save plugin documentation
- Existing codebase: `scanner_viewmodel.dart`, `generator_screen.dart`, `app_router.dart`

### Secondary (MEDIUM confidence)
- Flutter documentation on RepaintBoundary and widget capture
- share_plus GitHub README for SharePlus.instance API

### Tertiary (LOW confidence)
- qr_flutter version number from CONTEXT.md D-01 (^5.2.0) — may not match actual pub.dev latest

## Metadata

**Confidence breakdown:**
- Standard Stack: HIGH — all packages verified on pub.dev with documentation
- Architecture: HIGH — follows established project patterns (MVVM, ChangeNotifier, ListenableBuilder)
- Pitfalls: HIGH — common Flutter issues well-documented

**Research date:** 2026-06-29
**Valid until:** 2026-07-29 (30 days — stable packages, infrequent breaking changes)
