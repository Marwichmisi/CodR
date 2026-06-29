# Phase 4: QR Generation - Pattern Map

**Mapped:** 2026-06-29
**Files analyzed:** 7
**Analogs found:** 5 / 7

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `qr_scanner/lib/viewmodels/generator_viewmodel.dart` | viewmodel | transform | `qr_scanner/lib/viewmodels/scanner_viewmodel.dart` | exact |
| `qr_scanner/lib/screens/generator_screen.dart` | screen | request-response | `qr_scanner/lib/screens/scanner_screen.dart` | exact |
| `qr_scanner/lib/navigation/app_router.dart` | config | request-response | (self — modify existing) | exact |
| `qr_scanner/lib/services/permission_service.dart` | service | request-response | (self — extend existing) | exact |
| `qr_scanner/test/viewmodels/generator_viewmodel_test.dart` | test | batch | `qr_scanner/test/viewmodels/scanner_viewmodel_test.dart` | exact |
| `qr_scanner/test/screens/generator_screen_test.dart` | test | batch | `qr_scanner/test/screens/scanner_screen_test.dart` | exact |
| `qr_scanner/pubspec.yaml` | config | — | (self — add dependencies) | — |

## Pattern Assignments

### `qr_scanner/lib/viewmodels/generator_viewmodel.dart` (viewmodel, transform)

**Analog:** `qr_scanner/lib/viewmodels/scanner_viewmodel.dart`

**Imports pattern** (lines 1-2):
```dart
import 'package:flutter/foundation.dart';
import '../services/permission_service.dart';
```

**ChangeNotifier class pattern** (lines 4-8):
```dart
class ScannerViewModel extends ChangeNotifier {
  final PermissionService _permissionService;

  ScannerViewModel({required PermissionService permissionService})
      : _permissionService = permissionService;
```

**State fields pattern** (lines 10-17):
```dart
  bool _isCheckingPermission = true;
  bool get isCheckingPermission => _isCheckingPermission;

  bool _hasPermission = false;
  bool get hasPermission => _hasPermission;
```

**Async action with notifyListeners pattern** (lines 19-28):
```dart
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
```

**Timer/debounce anti-pattern from RESEARCH.md** (dispose must cancel):
```dart
  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
```

**Key adaptation:** GeneratorViewModel adds:
- `Timer? _debounceTimer` for 300ms debounce
- `_inputText` / `_qrText` / `_isUrlDetected` state fields with getters
- `updateText(String)` with debounce timer logic
- `_detectUrl(String)` pure pattern matching
- `_processText(String)` adds `https://` if URL without scheme
- `saveToGallery()` → permission check + `SaverGallery.saveImage()`
- `shareImage()` → capture widget to PNG + temp file + `SharePlus.instance.share()`
- `copyToClipboard()` → `Clipboard.setData()`
- `dispose()` cancels `_debounceTimer`

---

### `qr_scanner/lib/screens/generator_screen.dart` (screen, request-response)

**Analog:** `qr_scanner/lib/screens/scanner_screen.dart`

**Imports pattern** (lines 1-8):
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';
import '../viewmodels/scanner_viewmodel.dart';
import '../services/permission_service.dart';
import '../theme/app_theme.dart';
```

**StatefulWidget with ViewModel injection pattern** (lines 11-19):
```dart
class ScannerScreen extends StatefulWidget {
  final ScannerViewModel viewModel;
  final MobileScannerController? mockController;

  const ScannerScreen({
    required this.viewModel,
    this.mockController,
    super.key,
  });

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}
```

**ListenableBuilder wrapping Scaffold pattern** (lines 101-104):
```dart
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
```

**LayoutBuilder + ConstrainedBox responsive pattern** (lines 125-128):
```dart
          body: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;
```

**SnackBar feedback pattern** (lines 250-268):
```dart
  void _showScanResult(String content) {
    ScaffoldMessenger.of(context).clearSnackBars();
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

**Preview pattern** (lines 291-299):
```dart
@Preview(name: 'Scanner Screen - Granted', group: 'Screens')
Widget scannerGrantedPreview() {
  return MaterialApp(
    theme: buildLightTheme(),
    home: ScannerScreen(
      viewModel: ScannerViewModel(permissionService: _MockGrantedPermissionService()),
    ),
  );
}
```

**Key adaptation for GeneratorScreen:**
- Convert `StatelessWidget` → `StatefulWidget` (existing placeholder is stateless)
- Constructor takes `GeneratorViewModel viewModel` (required)
- Add `GlobalKey _qrKey` for RepaintBoundary capture
- Use `ListenableBuilder` → build Column with: TextField + URL Badge + QrImageView + Action Buttons
- SnackBar feedback for save/share/copy actions
- LayoutBuilder + ConstrainedBox (max 480dp) wrapping body

---

### `qr_scanner/lib/navigation/app_router.dart` (config, request-response)

**Analog:** self (existing file, lines 1-55)

**Router factory pattern** (lines 11-13):
```dart
GoRouter createAppRouter({PermissionService? permissionService, MobileScannerController? mockController}) {
  return GoRouter(
```

**ViewModel injection in route builder** (lines 22-29):
```dart
            GoRoute(
              path: '/scanner',
              builder: (context, state) => ScannerScreen(
                viewModel: ScannerViewModel(
                  permissionService: permissionService ?? SystemPermissionService(),
                ),
                mockController: mockController,
              ),
            ),
```

**Current generator stub** (lines 36-37):
```dart
            GoRoute(
              path: '/generator',
              builder: (context, state) => const GeneratorScreen(),
            ),
```

**Key adaptation:** Replace the stub with ViewModel injection:
```dart
            GoRoute(
              path: '/generator',
              builder: (context, state) => GeneratorScreen(
                viewModel: GeneratorViewModel(),
              ),
            ),
```

---

### `qr_scanner/lib/services/permission_service.dart` (service, request-response)

**Analog:** self (existing file, lines 1-26)

**Abstract interface pattern** (lines 3-7):
```dart
abstract class PermissionService {
  Future<bool> hasCameraPermission();
  Future<bool> requestCameraPermission();
  Future<bool> openSettings();
}
```

**Implementation pattern** (lines 9-26):
```dart
class SystemPermissionService implements PermissionService {
  @override
  Future<bool> hasCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  @override
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  @override
  Future<bool> openSettings() async {
    return await openAppSettings();
  }
}
```

**Key adaptation:** Add gallery permission methods to both abstract interface and implementation:
```dart
  Future<bool> hasGalleryPermission();
  Future<bool> requestGalleryPermission();
```

Implementation uses `Permission.photos` (iOS) and `Permission.storage` (Android).

---

### `qr_scanner/test/viewmodels/generator_viewmodel_test.dart` (test, batch)

**Analog:** `qr_scanner/test/viewmodels/scanner_viewmodel_test.dart`

**Test file structure** (lines 1-15):
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qr_scanner/services/permission_service.dart';
import 'package:qr_scanner/viewmodels/scanner_viewmodel.dart';

class MockPermissionService extends Mock implements PermissionService {}

void main() {
  late MockPermissionService mockPermissionService;
  late ScannerViewModel viewModel;

  setUp(() {
    mockPermissionService = MockPermissionService();
    viewModel = ScannerViewModel(permissionService: mockPermissionService);
  });
```

**Group + test pattern** (lines 17-31):
```dart
  group('ScannerViewModel Permissions', () {
    test('checkPermission sets hasPermission to true if granted', () async {
      when(() => mockPermissionService.hasCameraPermission()).thenAnswer((_) async => true);
      
      expect(viewModel.isCheckingPermission, true);
      
      final future = viewModel.checkPermission();
      expect(viewModel.isCheckingPermission, true);
      
      await future;
      
      expect(viewModel.isCheckingPermission, false);
      expect(viewModel.hasPermission, true);
      verify(() => mockPermissionService.hasCameraPermission()).called(1);
    });
```

**Timer test pattern** (lines 62-91):
```dart
    testWidgets('handleQrCodeDetected handles empty codes and throttling', (tester) async {
      // ...
      await tester.pump(const Duration(seconds: 2));
      expect(viewModel.isScanningLocked, false);
      // ...
    });
```

**Key adaptation for GeneratorViewModel tests:**
- Mock `PermissionService` for gallery permission tests
- Test debounce timer: pump 300ms → verify `_qrText` updated
- Test URL detection: various inputs → verify `_isUrlDetected`
- Test `_processText`: URL without scheme gets `https://` prepended
- Test `copyToClipboard`: verify `ClipboardData` set
- Test dispose cancels timer

---

### `qr_scanner/test/screens/generator_screen_test.dart` (test, batch)

**Analog:** `qr_scanner/test/screens/scanner_screen_test.dart`

**Test file setup pattern** (lines 34-51):
```dart
void main() {
  late MockPermissionService mockPermissionService;
  late ScannerViewModel viewModel;
  late MockMobileScannerController mockController;

  setUp(() {
    mockPermissionService = MockPermissionService();
    viewModel = ScannerViewModel(permissionService: mockPermissionService);
    mockController = MockMobileScannerController();
    
    when(() => mockController.value).thenReturn(const MobileScannerState.uninitialized());
    // ...
  });

  Widget buildApp() {
    return MaterialApp(
      home: ScannerScreen(
        viewModel: viewModel,
        mockController: mockController,
      ),
    );
  }
```

**Widget test with pumpAndSettle** (lines 62-77):
```dart
  testWidgets('ScannerScreen shows error when permission denied', (tester) async {
    when(() => mockPermissionService.hasCameraPermission()).thenAnswer((_) async => false);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Accès à l\'appareil photo requis'), findsWidgets);
    // ...
  });
```

**Key adaptation for GeneratorScreen tests:**
- Create mock `GeneratorViewModel` (use `Mocktail` or fake)
- Test empty state shows placeholder icon
- Test text input triggers QR render after debounce
- Test character limit 250
- Test URL detection badge visibility
- Test save/share/copy buttons trigger correct SnackBar
- Use `tester.pump(Duration(milliseconds: 400))` to advance debounce

---

## Shared Patterns

### MVVM Architecture
**Source:** `qr_scanner/lib/viewmodels/scanner_viewmodel.dart` + `qr_scanner/lib/screens/scanner_screen.dart`
**Apply to:** All new ViewModel and Screen files
**Pattern:**
```
ViewModel (ChangeNotifier):
  - Private state fields with public getters
  - Dependency injection via constructor
  - notifyListeners() after each mutation
  - dispose() cancels timers/controllers

Screen (StatefulWidget):
  - Takes ViewModel as required constructor param
  - ListenableBuilder wrapping build()
  - LayoutBuilder + ConstrainedBox for responsive
  - SnackBar via ScaffoldMessenger
```

### Dependency Injection via Constructor
**Source:** `qr_scanner/lib/viewmodels/scanner_viewmodel.dart` line 7
**Apply to:** `GeneratorViewModel`, `GeneratorScreen`
```dart
ScannerViewModel({required PermissionService permissionService})
    : _permissionService = permissionService;
```

### LayoutBuilder + ConstrainedBox Responsive Pattern
**Source:** `qr_scanner/lib/screens/generator_screen.dart` lines 11-14 (existing placeholder)
**Apply to:** `GeneratorScreen`
```dart
LayoutBuilder(
  builder: (context, constraints) {
    final maxWidth =
        constraints.maxWidth > 600 ? 480.0 : constraints.maxWidth;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        // ...
      ),
    );
  },
)
```

### SnackBar Feedback Pattern
**Source:** `qr_scanner/lib/screens/scanner_screen.dart` lines 250-268
**Apply to:** All GeneratorScreen action handlers
```dart
ScaffoldMessenger.of(context).clearSnackBars();
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('QR sauvegardé !'),
    duration: const Duration(seconds: 3),
  ),
);
```

### Mock Pattern for Tests
**Source:** `qr_scanner/test/viewmodels/scanner_viewmodel_test.dart` lines 6, 39-50
**Apply to:** All test files
```dart
class MockPermissionService extends Mock implements PermissionService {}

setUp(() {
  mockPermissionService = MockPermissionService();
  viewModel = ScannerViewModel(permissionService: mockPermissionService);
  when(() => mockPermissionService.hasCameraPermission()).thenAnswer((_) async => true);
});
```

### Widget Preview Pattern
**Source:** `qr_scanner/lib/screens/scanner_screen.dart` lines 273-299
**Apply to:** `GeneratorScreen`
```dart
class _MockViewModel implements GeneratorViewModel { ... }

@Preview(name: 'Generator Screen', group: 'Screens')
Widget generatorPreview() {
  return MaterialApp(
    theme: buildLightTheme(),
    home: GeneratorScreen(viewModel: _MockViewModel()),
  );
}
```

---

## No Analog Found

Files with no close match in the codebase (planner should use RESEARCH.md patterns instead):

| File | Role | Data Flow | Reason |
|------|------|-----------|--------|
| `qr_scanner/lib/viewmodels/generator_viewmodel.dart` | viewmodel | transform | Partial analog exists (ScannerViewModel), but QR generation + debounce + URL detection is new logic — use RESEARCH.md code examples (lines 348-421) |

---

## Key Packages to Install

| Package | Version | Purpose | Added to pubspec |
|---------|---------|---------|-----------------|
| `qr_flutter` | ^4.1.0 (verify latest) | QR code rendering widget | No — NEW |
| `share_plus` | ^11.0.0 (verify latest) | Native share sheet | No — NEW |
| `saver_gallery` | ^4.0.0 | Save images to gallery | No — NEW |
| `path_provider` | ^2.1.0 | Temp directory for share | Yes — ALREADY INSTALLED |
| `permission_handler` | ^12.0.3 | Permission requests | Yes — ALREADY INSTALLED |

**Install command:** `flutter pub add qr_flutter share_plus saver_gallery`

---

## Metadata

**Analog search scope:** `qr_scanner/lib/` (viewmodels, screens, services, navigation, theme, models), `qr_scanner/test/`
**Files scanned:** 11 existing source files + 11 test files
**Pattern extraction date:** 2026-06-29
