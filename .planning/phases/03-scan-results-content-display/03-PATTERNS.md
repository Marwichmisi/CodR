# Phase 3: Scan Results & Content Display - Pattern Map

**Mapped:** 2026-06-28
**Files analyzed:** 7 (4 new, 3 modified)
**Analogs found:** 6 / 7

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `qr_scanner/lib/models/content_type.dart` | model | transform | `qr_scanner/lib/models/scan_record.dart` | role-match |
| `qr_scanner/lib/viewmodels/result_viewmodel.dart` | viewmodel | event-driven | `qr_scanner/lib/viewmodels/scanner_viewmodel.dart` | exact |
| `qr_scanner/lib/widgets/scan_result_bottom_sheet.dart` | component | request-response | `qr_scanner/lib/screens/generator_screen.dart` | partial (responsive LayoutBuilder) |
| `qr_scanner/lib/screens/scanner_screen.dart` | screen | request-response | (existing file — MODIFY) | exact (self) |
| `qr_scanner/pubspec.yaml` | config | batch | (existing file — MODIFY) | exact (self) |
| `qr_scanner/test/viewmodels/result_viewmodel_test.dart` | test | unit | `qr_scanner/test/viewmodels/scanner_viewmodel_test.dart` | exact |
| `qr_scanner/test/screens/scan_result_bottom_sheet_test.dart` | test | widget | `qr_scanner/test/screens/scanner_screen_test.dart` | exact |

## Pattern Assignments

### `qr_scanner/lib/models/content_type.dart` (model, transform)

**Analog:** `qr_scanner/lib/models/scan_record.dart`

**Imports pattern** (lines 1-3):
```dart
// scan_record.dart — no imports needed for pure Dart model
// content_type.dart should follow the same pattern: no Flutter imports, pure Dart enum
```

**Model pattern** (lines 1-31):
```dart
// scan_record.dart is a simple data class with factory constructors
// content_type.dart should be an equally simple enum:

enum ContentType { url, email, phone, text, empty }

// Extension for display name (optional but follows scan_record.dart's clean style):
// This is a pure Dart file — no Flutter SDK dependency
```

---

### `qr_scanner/lib/viewmodels/result_viewmodel.dart` (viewmodel, event-driven)

**Analog:** `qr_scanner/lib/viewmodels/scanner_viewmodel.dart`

**Imports pattern** (lines 1-2):
```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../models/content_type.dart';
```

**ViewModel core pattern** (lines 1-61 of scanner_viewmodel.dart):
```dart
// CRITICAL PATTERN: ChangeNotifier with private state + public getters + notifyListeners()
// scanner_viewmodel.dart lines 4-61:

class ResultViewModel extends ChangeNotifier {
  // Private state fields with public getters (same pattern as ScannerViewModel lines 10-17)
  ContentType _contentType = ContentType.text;
  ContentType get contentType => _contentType;

  bool _hasError = false;
  bool get hasError => _hasError;

  String _scannedContent = '';
  String get scannedContent => _scannedContent;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Content type detection (business logic — same role as handleQrCodeDetected at line 46)
  void detectContentType(String content) {
    final trimmed = content.trim();
    _scannedContent = content;

    if (trimmed.isEmpty) {
      _contentType = ContentType.empty;
      _hasError = true;
    } else if (RegExp(r'^https?://').hasMatch(trimmed) &&
        Uri.tryParse(trimmed)?.isAbsolute == true) {
      _contentType = ContentType.url;
    } else if (RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(trimmed)) {
      _contentType = ContentType.email;
    } else if (RegExp(r'^\+?\d[\d\s\-\(\)]{8,13}\d$').hasMatch(trimmed)) {
      _contentType = ContentType.phone;
    } else {
      _contentType = ContentType.text;
    }

    _hasError = false;
    notifyListeners(); // Same pattern as ScannerViewModel lines 21, 26, 37, 57
  }

  // Action methods — Future-based like ScannerViewModel.checkPermission()
  Future<void> openUrl(String url) async { ... }
  Future<void> sendEmail(String email) async { ... }
  Future<void> callPhone(String phone) async { ... }
  Future<void> copyToClipboard(String content) async { ... }
  Future<void> shareContent(String content) async { ... }
}
```

**Error handling pattern** (lines 19-28 of scanner_viewmodel.dart):
```dart
// ScannerViewModel uses try/finally for state management (lines 19-28)
// ResultViewModel should use the same try/catch/finally for async action methods:

Future<void> openUrl(String url) async {
  try {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  } catch (e) {
    // Silent handling — UI will not crash
  }
}
```

---

### `qr_scanner/lib/widgets/scan_result_bottom_sheet.dart` (component, request-response)

**Analog:** `qr_scanner/lib/screens/generator_screen.dart` (for responsive pattern)

**Imports pattern** (lines 1-4 of generator_screen.dart):
```dart
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../theme/app_theme.dart';
import '../models/content_type.dart';
import '../viewmodels/result_viewmodel.dart';
```

**Responsive LayoutBuilder pattern** (lines 7-18 of generator_screen.dart):
```dart
// generator_screen.dart uses LayoutBuilder for responsive width (lines 7-18):
// Bottom sheet should use the same pattern for tablet/mobile:
LayoutBuilder(
  builder: (context, constraints) {
    final maxWidth = constraints.maxWidth > 600 ? 500.0 : constraints.maxWidth;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: ... // Bottom sheet content
      ),
    );
  },
)
```

**Bottom sheet display pattern** (from RESEARCH.md Pattern 2):
```dart
// Show as bottom sheet from scanner_screen.dart (replacing _showScanResult at line 250):
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  showDragHandle: true, // D-04
  builder: (context) {
    return ScanResultBottomSheet(
      content: content,
      viewModel: _resultViewModel,
    );
  },
).whenComplete(() {
  if (_controller.isInitialized) {
    _controller.start(); // D-10: camera resume
  }
});
```

**Preview pattern** (lines 48-54 of generator_screen.dart):
```dart
@Preview(name: 'Scan Result Bottom Sheet', group: 'Widgets')
Widget scanResultBottomSheetPreview() {
  final viewModel = ResultViewModel();
  viewModel.detectContentType('https://flutter.dev');
  return MaterialApp(
    theme: buildLightTheme(),
    home: Scaffold(
      body: ScanResultBottomSheet(
        content: 'https://flutter.dev',
        viewModel: viewModel,
      ),
    ),
  );
}
```

---

### `qr_scanner/lib/screens/scanner_screen.dart` (screen, request-response — MODIFY)

**Analog:** Self (existing file)

**Current `_showScanResult` to replace** (lines 250-269):
```dart
// CURRENT (to be replaced):
void _showScanResult(String content) {
  ScaffoldMessenger.of(context).clearSnackBars();
  final isUrl = Uri.tryParse(content)?.isAbsolute ?? false;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Code QR scanné : $content'),
      action: SnackBarAction(
        label: isUrl ? 'Ouvrir le lien' : 'Fermer',
        onPressed: () { ... },
      ),
      duration: const Duration(seconds: 4),
    ),
  );
}
```

**Replacement pattern — bottom sheet with camera lifecycle:**
```dart
// NEW _showScanResult:
void _showScanResult(String content) {
  // D-09: Immediate stop
  if (_controller.isInitialized) {
    _controller.stop();
  }

  // Update ResultViewModel
  _resultViewModel.detectContentType(content);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      return ScanResultBottomSheet(
        content: content,
        viewModel: _resultViewModel,
      );
    },
  ).whenComplete(() {
    // D-10: Resume camera regardless of close mode
    if (_controller.isInitialized) {
      _controller.start();
    }
    // D-12: Debounce — short delay before accepting new scans
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _controller.isInitialized) {
        // Ready for next scan
      }
    });
  });
}
```

**Constructor modification** (lines 11-19):
```dart
// Add ResultViewModel to constructor:
class ScannerScreen extends StatefulWidget {
  final ScannerViewModel viewModel;
  final ResultViewModel resultViewModel; // NEW
  final MobileScannerController? mockController;

  const ScannerScreen({
    required this.viewModel,
    required this.resultViewModel, // NEW
    this.mockController,
    super.key,
  });
```

**Router modification** (`qr_scanner/lib/navigation/app_router.dart` lines 24-29):
```dart
// Add ResultViewModel to route builder:
builder: (context, state) => ScannerScreen(
  viewModel: ScannerViewModel(
    permissionService: permissionService ?? SystemPermissionService(),
  ),
  resultViewModel: ResultViewModel(), // NEW
  mockController: mockController,
),
```

---

### `qr_scanner/test/viewmodels/result_viewmodel_test.dart` (test, unit)

**Analog:** `qr_scanner/test/viewmodels/scanner_viewmodel_test.dart`

**Imports pattern** (lines 1-5 of scanner_viewmodel_test.dart):
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qr_scanner/models/content_type.dart';
import 'package:qr_scanner/viewmodels/result_viewmodel.dart';
```

**Test structure pattern** (lines 8-15 of scanner_viewmodel_test.dart):
```dart
void main() {
  late ResultViewModel viewModel;

  setUp(() {
    viewModel = ResultViewModel();
  });

  group('ResultViewModel Content Detection', () {
    test('detectContentType identifies URLs', () {
      viewModel.detectContentType('https://flutter.dev');
      expect(viewModel.contentType, ContentType.url);
      expect(viewModel.hasError, false);
    });

    test('detectContentType identifies emails', () {
      viewModel.detectContentType('user@example.com');
      expect(viewModel.contentType, ContentType.email);
    });

    test('detectContentType identifies phones', () {
      viewModel.detectContentType('+33612345678');
      expect(viewModel.contentType, ContentType.phone);
    });

    test('detectContentType handles empty content as error', () {
      viewModel.detectContentType('');
      expect(viewModel.contentType, ContentType.empty);
      expect(viewModel.hasError, true);
    });

    test('detectContentType treats whitespace-only as invalid (D-15)', () {
      viewModel.detectContentType('   ');
      expect(viewModel.contentType, ContentType.empty);
      expect(viewModel.hasError, true);
    });

    test('detectContentType uses strict priority URL > email > phone (D-08)', () {
      // Pure URL gets url type
      viewModel.detectContentType('https://example.com');
      expect(viewModel.contentType, ContentType.url);

      // Mixed text gets text type (not URL)
      viewModel.detectContentType('Mon site: https://flutter.dev');
      expect(viewModel.contentType, ContentType.text);
    });
  });
}
```

**Mock setup pattern** (lines 6-15 of scanner_viewmodel_test.dart):
```dart
// For action methods that call url_launcher/share_plus, use mocktail:
class MockUrlLauncher extends Mock {
  Future<bool> canLaunchUrl(Uri url) async => true;
  Future<bool> launchUrl(Uri url) async => true;
}
```

---

### `qr_scanner/test/screens/scan_result_bottom_sheet_test.dart` (test, widget)

**Analog:** `qr_scanner/test/screens/scanner_screen_test.dart`

**Imports pattern** (lines 1-8 of scanner_screen_test.dart):
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qr_scanner/models/content_type.dart';
import 'package:qr_scanner/viewmodels/result_viewmodel.dart';
import 'package:qr_scanner/widgets/scan_result_bottom_sheet.dart';
import 'package:qr_scanner/theme/app_theme.dart';
```

**Widget test setup pattern** (lines 53-60 of scanner_screen_test.dart):
```dart
Widget buildApp({String content = 'Hello World'}) {
  final viewModel = ResultViewModel();
  viewModel.detectContentType(content);
  return MaterialApp(
    theme: buildLightTheme(),
    home: Scaffold(
      body: ScanResultBottomSheet(
        content: content,
        viewModel: viewModel,
      ),
    ),
  );
}
```

**Test case patterns** (from scanner_screen_test.dart lines 110-151):
```dart
testWidgets('Bottom sheet displays scanned content', (tester) async {
  await tester.pumpWidget(buildApp(content: 'Hello World'));
  await tester.pumpAndSettle();

  expect(find.text('Hello World'), findsOneWidget);
  expect(find.text('Copier'), findsOneWidget);
  expect(find.text('Partager'), findsOneWidget);
});

testWidgets('Bottom sheet shows Open URL button for URL content', (tester) async {
  await tester.pumpWidget(buildApp(content: 'https://flutter.dev'));
  await tester.pumpAndSettle();

  expect(find.text('Ouvrir le lien'), findsOneWidget);
  expect(find.byIcon(Icons.open_in_browser), findsOneWidget);
});

testWidgets('Bottom sheet shows error state for empty content (D-13)', (tester) async {
  final viewModel = ResultViewModel();
  viewModel.detectContentType('');

  await tester.pumpWidget(MaterialApp(
    theme: buildLightTheme(),
    home: Scaffold(
      body: ScanResultBottomSheet(
        content: '',
        viewModel: viewModel,
      ),
    ),
  ));
  await tester.pumpAndSettle();

  expect(find.text('Code QR vide ou invalide'), findsOneWidget);
  expect(find.text('Réessayer'), findsOneWidget);
  expect(find.text('Fermer'), findsOneWidget);
  expect(find.byIcon(Icons.warning), findsOneWidget);
});
```

---

### `qr_scanner/pubspec.yaml` (config, batch — MODIFY)

**Analog:** Self (existing file)

**Current dependencies** (lines 30-43):
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  go_router: ^17.3.0
  sqflite: ^2.3.0
  google_fonts: ^8.1.0
  path_provider: ^2.1.0
  path: ^1.8.0
  mobile_scanner: ^7.2.0
  permission_handler: ^12.0.3
```

**Additions to make** (after line 43, before dev_dependencies):
```yaml
  url_launcher: ^6.3.2
  share_plus: ^13.2.0
```

---

## Shared Patterns

### Authentication / Permission
**Source:** `qr_scanner/lib/services/permission_service.dart`
**Apply to:** Not directly — no auth in this phase. Permission service already injected via constructor.

### Error Handling
**Source:** `qr_scanner/lib/viewmodels/scanner_viewmodel.dart` (lines 19-28)
**Apply to:** `result_viewmodel.dart` action methods
```dart
// Pattern: try/finally for state management
Future<void> checkPermission() async {
  _isCheckingPermission = true;
  notifyListeners();
  try {
    _hasPermission = await _permissionService.hasCameraPermission();
  } finally {
    _isCheckingPermission = false;
    notifyListeners();
  }
}
// ResultViewModel should use same pattern for action methods with error state
```

### Widget Previews
**Source:** `qr_scanner/lib/screens/scanner_screen.dart` (lines 272-353)
**Apply to:** `scan_result_bottom_sheet.dart`
```dart
// Pattern: @Preview annotation with mock services + buildLightTheme()
@Preview(name: '...', group: 'Widgets')
Widget previewName() {
  return MaterialApp(
    theme: buildLightTheme(),
    home: Scaffold(body: YourWidget(...)),
  );
}
```

### Camera Lifecycle
**Source:** `qr_scanner/lib/screens/scanner_screen.dart` (lines 62-73, 84-98)
**Apply to:** `scanner_screen.dart` modification — `_showScanResult` method
```dart
// Pattern: Check _controller.isInitialized before start/stop (lines 62-73)
if (_controller.isInitialized) {
  _controller.start(); // or .stop()
}
// Same pattern in didChangeAppLifecycleState (lines 84-98)
```

### Mock Setup for Tests
**Source:** `qr_scanner/test/viewmodels/scanner_viewmodel_test.dart` (lines 6-15)
**Apply to:** `result_viewmodel_test.dart` and `scan_result_bottom_sheet_test.dart`
```dart
// Pattern: mocktail Mock class + setUp() + when().thenAnswer()
class MockPermissionService extends Mock implements PermissionService {}

setUp(() {
  mockPermissionService = MockPermissionService();
  viewModel = ScannerViewModel(permissionService: mockPermissionService);
});
```

### Responsive Layout
**Source:** `qr_scanner/lib/screens/generator_screen.dart` (lines 7-18)
**Apply to:** `scan_result_bottom_sheet.dart` (D-03: tablet max width 500dp)
```dart
LayoutBuilder(
  builder: (context, constraints) {
    final maxWidth = constraints.maxWidth > 600 ? 500.0 : constraints.maxWidth;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: ...
      ),
    );
  },
)
```

---

## No Analog Found

| File | Role | Data Flow | Reason |
|------|------|-----------|--------|
| `qr_scanner/lib/widgets/scan_result_bottom_sheet.dart` | component | request-response | No bottom sheet widget exists yet — first of its kind; analog is `generator_screen.dart` for responsive pattern only |

## Metadata

**Analog search scope:** `qr_scanner/lib/`, `qr_scanner/test/`
**Files scanned:** 12 source + 11 test files
**Pattern extraction date:** 2026-06-28
