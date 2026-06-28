# Phase 03: Scan Results & Content Display — Research

**Researched:** 2026-06-28
**Domain:** Flutter UI / Bottom Sheet / URL Launching / Content Sharing
**Confidence:** HIGH

## Summary

Phase 03 transforms the current SnackBar-based scan result display into a rich Material 3 bottom sheet with contextual action buttons. The research confirms that `url_launcher` (v6.3.2) and `share_plus` (v13.2.0) are the standard Flutter packages for launching URLs/mail/tel schemes and native share sheets respectively. The clipboard functionality uses Flutter's built-in `Clipboard` service from `flutter/services.dart`. The bottom sheet lifecycle must be tightly coupled with the camera controller to pause/resume scanning during sheet display.

**Primary recommendation:** Implement a `ResultViewModel` extending `ChangeNotifier` with content type detection (URL/email/phone/text), inject it into `ScannerScreen`, and use `showModalBottomSheet` with `whenComplete` callback for camera lifecycle management.

## User Constraints (from CONTEXT.md)

### Locked Decisions
- **D-01:** Action buttons (Copy, Share, contextual) arranged horizontally with icon + short text
- **D-02:** Scanned content in scrollable container, max height 150dp-200dp
- **D-03:** Tablet/large screen: centered bottom sheet, max width 500dp
- **D-04:** Material 3 drag handle (`showDragHandle: true`)
- **D-05:** Strict URL detection: only absolute URLs starting with "http://" or "https://"
- **D-06:** Email validation via regex: `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`
- **D-07:** Phone validation: international format (starting with "+") or national (9-14 digits, spaces/dashes/parentheses allowed)
- **D-08:** Mixed text treated as raw text; contextual button only if content matches 100% URL/email/phone after trim
- **D-09:** Immediate `_controller.stop()` at bottom sheet open
- **D-10:** `whenComplete` callback for `_controller.start()` regardless of close mode
- **D-11:** Silent exception handling, check `_controller.isInitialized` before start/stop
- **D-12:** Short debounce (1-2s) after bottom sheet close before resuming scan

### the agent's Discretion
- None — all implementation decisions are locked

### Deferred Ideas (OUT OF SCOPE)
- SQLite scan history — Phase 5
- Full-screen result screen — bottom sheet sufficient for v1
- Custom bottom sheet theme — use existing Material 3 theme
- Non-QR barcode formats (EAN-13, UPC) — v2 feature
- Gallery/image scanning — v2 feature
- WiFi QR codes, vCards, contacts — out of scope v1

</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| SCAN-07 | Detect URLs in scanned content | `url_launcher` package with `canLaunchUrl` and `launchUrl` for http/https schemes |
| SCAN-08 | Display scanned content with actions (open URL, copy, share) | Bottom sheet with `url_launcher`, `share_plus`, and `Clipboard` service |
| QUAL-01 | Unit tests for ViewModels | `ResultViewModel` with ChangeNotifier pattern, mockable via constructor injection |
| QUAL-04 | Proper error and loading states | Bottom sheet error state with retry button, camera lifecycle error handling |
</phase_requirements>

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Bottom sheet display | UI (ScannerScreen) | ViewModel (ResultViewModel) | Screen owns presentation; ViewModel owns state |
| Content type detection | ViewModel (ResultViewModel) | — | Business logic belongs in ViewModel |
| URL/Email/Phone launching | ViewModel (ResultViewModel) | — | Action methods in ViewModel, delegate to packages |
| Camera lifecycle | UI (ScannerScreen) | — | Controller owned by screen state |
| Clipboard operations | ViewModel (ResultViewModel) | — | Action method in ViewModel |
| Share sheet | ViewModel (ResultViewModel) | — | Action method delegating to share_plus |
| Error state management | ViewModel (ResultViewModel) | UI (Bottom Sheet) | ViewModel owns error state; UI renders it |

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| url_launcher | ^6.3.2 | Open URLs, mailto:, tel: schemes | Flutter Favorite, maintained by flutter.dev team |
| share_plus | ^13.2.0 | Native share sheet for text content | Flutter Favorite, 4k+ likes, cross-platform |
| flutter/services.dart | (built-in) | Clipboard operations | Native Flutter, no external dependency needed |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| mobile_scanner | ^7.2.0 | Camera controller (existing) | Already in project — control start/stop for lifecycle |
| mocktail | ^1.0.4 | Mocking for unit tests | Already in project — mock ViewModel dependencies |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| url_launcher | launching_apps | Less maintained, fewer features |
| share_plus | Share (deprecated) | Static methods deprecated in favor of SharePlus.instance |

**Installation:**
```bash
cd qr_scanner && flutter pub add url_launcher share_plus
```

**Version verification:** Before writing the Standard Stack table, verify each recommended package exists and is current using the ecosystem-appropriate command:
```bash
npm view [package] version          # Node.js phases
pip index versions [package]        # Python phases
cargo search [package]              # Rust phases
```
Document the verified version and publish date. Training data versions may be months stale — always confirm against the correct ecosystem registry.

## Package Legitimacy Audit

> **Required** whenever this phase installs external packages. Run the Package Legitimacy Gate protocol before completing this section.

| Package | Registry | Age | Downloads | Source Repo | Verdict | Disposition |
|---------|----------|-----|-----------|-------------|---------|-------------|
| url_launcher | pub.dev | 8+ years | 4.91M | github.com/flutter/packages | [VERIFIED: pub.dev] | Approved |
| share_plus | pub.dev | 4+ years | 2.95M | github.com/fluttercommunity/plus_plugins | [VERIFIED: pub.dev] | Approved |

**Packages removed due to [SLOP] verdict:** none
**Packages flagged as suspicious [SUS]:** none

*Packages discovered via WebSearch or training data that have not been verified against an authoritative source are tagged `[ASSUMED]` and the planner must gate each install behind a `checkpoint:human-verify` task.*

## Architecture Patterns

### System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     ScannerScreen                           │
│  ┌─────────────────────────────────────────────────────────┐│
│  │  MobileScanner (camera)                                 ││
│  │  onDetect → viewModel.handleQrCodeDetected()            ││
│  │            → _showScanResult(content)                   ││
│  └─────────────────────────────────────────────────────────┘│
│                          │                                  │
│                          ▼                                  │
│  ┌─────────────────────────────────────────────────────────┐
│  │  showModalBottomSheet()                                 │
│  │  ├─ camera stop() at open                               │
│  │  ├─ whenComplete → camera start()                       │
│  │  └─ StatefulBuilder for sheet content                   │
│  └─────────────────────────────────────────────────────────┘│
│                          │                                  │
│                          ▼                                  │
│  ┌─────────────────────────────────────────────────────────┐
│  │  ResultViewModel                                         │
│  │  ├─ detectContentType(content) → ContentType enum       │
│  │  ├─ openUrl(url) → url_launcher                         │
│  │  ├─ sendEmail(email) → url_launcher (mailto:)           │
│  │  ├─ callPhone(phone) → url_launcher (tel:)              │
│  │  ├─ copyToClipboard(content) → Clipboard                │
│  │  └─ shareContent(text) → share_plus                     │
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

### Recommended Project Structure
```
lib/
├── models/
│   ├── scan_record.dart              # Existing
│   └── content_type.dart             # NEW: ContentType enum
├── viewmodels/
│   ├── scanner_viewmodel.dart        # Existing — no changes needed
│   └── result_viewmodel.dart         # NEW: Content detection + actions
├── screens/
│   ├── scanner_screen.dart           # MODIFY: Add bottom sheet, camera lifecycle
│   └── ...
├── widgets/                          # NEW directory
│   └── scan_result_bottom_sheet.dart # NEW: Bottom sheet widget
└── ...
```

### Pattern 1: ResultViewModel with ChangeNotifier
**What:** ViewModel extending ChangeNotifier for scan result state management
**When to use:** For any new feature requiring UI state and business logic separation
**Example:**
```dart
// Source: flutter-apply-architecture-best-practices SKILL.md
enum ContentType { url, email, phone, text, empty }

class ResultViewModel extends ChangeNotifier {
  ContentType _contentType = ContentType.text;
  ContentType get contentType => _contentType;

  bool _hasError = false;
  bool get hasError => _hasError;

  void detectContentType(String content) {
    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      _contentType = ContentType.empty;
      _hasError = true;
    } else if (RegExp(r'^https?://').hasMatch(trimmed) && Uri.tryParse(trimmed)?.isAbsolute == true) {
      _contentType = ContentType.url;
    } else if (RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(trimmed)) {
      _contentType = ContentType.email;
    } else if (RegExp(r'^\+?\d[\d\s\-\(\)]{8,13}\d$').hasMatch(trimmed)) {
      _contentType = ContentType.phone;
    } else {
      _contentType = ContentType.text;
    }
    notifyListeners();
  }

  Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> sendEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> callPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> copyToClipboard(String content) async {
    await Clipboard.setData(ClipboardData(text: content));
  }

  Future<void> shareContent(String content) async {
    await SharePlus.instance.share(ShareParams(text: content));
  }
}
```

### Pattern 2: Bottom Sheet with Camera Lifecycle
**What:** showModalBottomSheet with whenComplete for synchronized camera control
**When to use:** Any feature requiring overlay UI that temporarily suspends camera
**Example:**
```dart
// Source: Flutter documentation
void _showScanResult(String content) {
  _controller.stop(); // Pause camera immediately

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.3,
            maxChildSize: 0.8,
            expand: false,
            builder: (context, scrollController) {
              return ScanResultBottomSheet(
                content: content,
                viewModel: _resultViewModel,
              );
            },
          );
        },
      );
    },
  ).whenComplete(() {
    // Resume camera regardless of how sheet was closed
    if (_controller.isInitialized) {
      _controller.start();
    }
  });
}
```

### Anti-Patterns to Avoid
- **Don't use SnackBar for scan results:** Snackbars auto-dismiss and can't contain interactive buttons; bottom sheet is the correct Material 3 pattern for persistent content display
- **Don't skip canLaunchUrl:** Always check before launching to avoid crashes on unsupported schemes
- **Don't use canLaunchUrl to decide UI visibility:** canLaunchUrl can return false even when launchUrl works; prefer showing buttons and handling failure gracefully
- **Don't forget sharePositionOrigin on iPad:** share_plus requires this parameter on iPad or it will crash

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| URL detection regex | Custom regex patterns | `Uri.tryParse(content)?.isAbsolute` + scheme check | Dart's Uri class handles edge cases and encoding |
| Email validation | Custom regex | Standard email regex from D-06 | Complex edge cases, RFC compliance |
| Phone number validation | Custom parsing | Regex pattern from D-07 | International format variations are complex |
| Share sheet | Custom share dialog | `share_plus` | Platform-specific native implementations |
| Clipboard | Custom clipboard service | `Clipboard` from flutter/services.dart | Built-in, no dependencies |

**Key insight:** Flutter's `Clipboard` service is built into `flutter/services.dart` — no external package needed. The `url_launcher` and `share_plus` packages are maintained by the Flutter team and community respectively, with proven cross-platform support.

## Common Pitfalls

### Pitfall 1: Forgetting canLaunchUrl on iOS/Android
**What goes wrong:** App crashes or silently fails when launching unsupported URL schemes
**Why it happens:** Platform-specific URL scheme requirements not configured
**How to avoid:** Always check `canLaunchUrl(uri)` before `launchUrl(uri)`; configure `LSApplicationQueriesSchemes` on iOS and `<queries>` on Android
**Warning signs:** Crash on specific devices, button does nothing

### Pitfall 2: Missing sharePositionOrigin on iPad
**What goes wrong:** share_plus crashes or leaves UI unresponsive on iPad
**Why it happens:** iPad requires the origin point for the share sheet popover
**How to avoid:** Always pass `sharePositionOrigin` using `context.findRenderObject()` as RenderBox
**Warning signs:** iPad-specific crash reports

### Pitfall 3: Camera not resuming after bottom sheet close
**What goes wrong:** Camera remains frozen after bottom sheet dismissal
**Why it happens:** whenComplete callback not properly wired or controller disposed
**How to avoid:** Use `whenComplete` on `showModalBottomSheet()` and check `_controller.isInitialized` before calling `start()`
**Warning signs:** Black screen after scanning, need to switch tabs to resume

### Pitfall 4: URL scheme filtering bypass
**What goes wrong:** javascript: or data: URLs could be launched
**Why it happens:** Only checking `isAbsolute` without scheme validation
**How to avoid:** Explicitly filter to http/https schemes only per D-05
**Warning signs:** Security audit findings

### Pitfall 5: Content detection priority conflicts
**What goes wrong:** Text containing both URL and email shows both buttons
**Why it happens:** Multiple type detectors triggered simultaneously
**How to avoid:** Implement strict priority: URL > email > phone > text (only one contextual button)
**Warning signs:** UI showing multiple action buttons

## Code Examples

Verified patterns from official sources:

### Opening URLs with url_launcher
```dart
// Source: pub.dev/packages/url_launcher documentation
import 'package:url_launcher/url_launcher.dart';

Future<void> _launchUrl(Uri url) async {
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}

// For email with subject/body
final Uri emailLaunchUri = Uri(
  scheme: 'mailto',
  path: 'smith@example.com',
  query: encodeQueryParameters(<String, String>{
    'subject': 'Example Subject',
  }),
);
await launchUrl(emailLaunchUri);
```

### Sharing content with share_plus
```dart
// Source: pub.dev/packages/share_plus documentation
import 'package:share_plus/share_plus.dart';

final result = await SharePlus.instance.share(
  ShareParams(text: 'check out my website https://example.com')
);

if (result.status == ShareResultStatus.success) {
  print('Thank you for sharing!');
}
```

### Clipboard operations
```dart
// Source: Flutter documentation (flutter/services.dart)
import 'package:flutter/services.dart';

// Copy to clipboard
await Clipboard.setData(ClipboardData(text: content));

// Read from clipboard
final data = await Clipboard.getData(Clipboard.kTextPlain);
```

### Widget test for ViewModel
```dart
// Source: flutter-add-widget-test SKILL.md
testWidgets('Bottom sheet displays scan content', (tester) async {
  final viewModel = ResultViewModel();
  viewModel.detectContentType('https://flutter.dev');

  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => _showScanResult(context, viewModel),
          child: const Text('Show Result'),
        ),
      ),
    ),
  ));

  await tester.tap(find.text('Show Result'));
  await tester.pumpAndSettle();

  expect(find.text('https://flutter.dev'), findsOneWidget);
  expect(find.text('Ouvrir le lien'), findsOneWidget);
});
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| SnackBar for scan results | Bottom sheet with actions | Phase 3 | Better UX, persistent content display |
| Manual URL regex | `Uri.tryParse` + scheme check | Phase 3 | More reliable, handles edge cases |
| share_plus `Share.share()` | `SharePlus.instance.share(ShareParams)` | share_plus 13.x | New API, parameter object pattern |

**Deprecated/outdated:**
- `Share.share()`: Deprecated in favor of `SharePlus.instance.share(ShareParams)` — use new API
- `Clipboard.kTextPlain`: Consider using `Clipboard.getData(Clipboard.kTextPlain)` for reading

## Assumptions Log

> List all claims tagged `[ASSUMED]` in this research. The planner and discuss-phase use this
> section to identify decisions that need user confirmation before execution.

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | MobileScannerController.stop() and .start() are the correct methods for camera lifecycle | Architecture Patterns | Wrong method names would cause compilation errors |
| A2 | showModalBottomSheet's whenComplete callback fires for both swipe-down and Navigator.pop | Common Pitfalls | Camera wouldn't resume on swipe-close |
| A3 | SharePlus.instance.share() is the current API (not deprecated Share.share()) | Standard Stack | Would use deprecated API |

**If this table is empty:** All claims in this research were verified or cited — no user confirmation needed.

## Open Questions

1. **MobileScannerController API verification**
   - What we know: The existing code uses `_controller.start()` and `_controller.stop()` (scanner_screen.dart lines 69, 72, 93, 97)
   - What's unclear: Exact behavior of these methods when called multiple times rapidly
   - Recommendation: Test camera lifecycle thoroughly during implementation; add debouncing if needed per D-12

2. **Bottom sheet height on different devices**
   - What we know: D-02 specifies 150dp-200dp max height for content, D-03 specifies 500dp max width for tablets
   - What's unclear: How DraggableScrollableSheet interacts with these constraints
   - Recommendation: Use `ConstrainedBox` with `BoxConstraints(maxHeight: 200)` for content area, wrap in `Center` with `ConstrainedBox(maxWidth: 500)` for tablet

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter SDK | All | ✓ | 3.x | — |
| Dart SDK | All | ✓ | ^3.11.0 | — |
| url_launcher | URL/Email/Phone actions | ✗ | — | Must install: `flutter pub add url_launcher` |
| share_plus | Share functionality | ✗ | — | Must install: `flutter pub add share_plus` |

**Missing dependencies with no fallback:**
- url_launcher — required for URL/email/phone launching; must be installed
- share_plus — required for native share sheet; must be installed

**Missing dependencies with fallback:**
- None — these packages are essential for the phase requirements

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | flutter_test |
| Config file | test/ directory (standard Flutter) |
| Quick run command | `flutter test test/viewmodels/result_viewmodel_test.dart` |
| Full suite command | `flutter test` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| SCAN-07 | URL detection in scanned content | unit | `flutter test test/viewmodels/result_viewmodel_test.dart` | ❌ Wave 0 |
| SCAN-08 | Bottom sheet displays content with actions | widget | `flutter test test/screens/scan_result_bottom_sheet_test.dart` | ❌ Wave 0 |
| QUAL-01 | ResultViewModel unit tests | unit | `flutter test test/viewmodels/result_viewmodel_test.dart` | ❌ Wave 0 |
| QUAL-04 | Error states display correctly | widget | `flutter test test/screens/scan_result_bottom_sheet_test.dart` | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** `flutter test test/viewmodels/result_viewmodel_test.dart`
- **Per wave merge:** `flutter test`
- **Phase gate:** Full suite green before `/gsd-verify-work`

### Wave 0 Gaps
- [ ] `test/viewmodels/result_viewmodel_test.dart` — covers SCAN-07, QUAL-01
- [ ] `test/screens/scan_result_bottom_sheet_test.dart` — covers SCAN-08, QUAL-04
- [ ] Framework install: None needed — flutter_test already configured

*(If no gaps: "None — existing test infrastructure covers all phase requirements")*

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no | — |
| V3 Session Management | no | — |
| V4 Access Control | no | — |
| V5 Input Validation | yes | URL scheme filtering, content type detection |
| V6 Cryptography | no | — |

### Known Threat Patterns for Flutter

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| URL scheme injection | Tampering | Filter to http/https only per D-05 |
| Unvalidated URL launch | Elevation | Check canLaunchUrl before launching |
| Clipboard data exposure | Information Disclosure | No sensitive data in QR codes for v1 |
| Share sheet data leakage | Information Disclosure | Only share explicit user-selected content |

## Sources

### Primary (HIGH confidence)
- pub.dev/packages/url_launcher — Official package documentation, v6.3.2
- pub.dev/packages/share_plus — Official package documentation, v13.2.0
- flutter-apply-architecture-best-practices SKILL.md — MVVM pattern, ViewModel structure
- flutter-add-widget-test SKILL.md — Widget testing workflow
- flutter-add-widget-preview SKILL.md — Widget preview system
- flutter-build-responsive-layout SKILL.md — Responsive layout patterns
- flutter-fix-layout-issues SKILL.md — Layout error resolution

### Secondary (MEDIUM confidence)
- Flutter documentation on showModalBottomSheet — Bottom sheet lifecycle management
- mobile_scanner package documentation — Camera controller API

### Tertiary (LOW confidence)
- None — all claims verified against official sources

## Metadata

**Confidence breakdown:**
- Standard Stack: HIGH — All packages verified on pub.dev with official documentation
- Architecture: HIGH — Follows established MVVM pattern from project skills
- Pitfalls: HIGH — Common Flutter issues documented in official resources

**Research date:** 2026-06-28
**Valid until:** 2026-07-28 (30 days — stable packages)

---

*Phase: 03-scan-results-content-display*
*Research completed: 2026-06-28*
