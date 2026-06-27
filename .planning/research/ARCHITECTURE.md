# Architecture Patterns — QR Code Scanner & Generator Flutter App

**Domain:** Mobile utility app (QR code scanning and generation)
**Researched:** 2026-06-27
**Overall confidence:** HIGH

## Executive Summary

QR code scanner/generator Flutter apps follow a straightforward two-screen architecture: a **Scanner Screen** (camera-based QR reader) and a **Generator Screen** (text-to-QR renderer). The Flutter team's official architecture guide (MVVM pattern) applies directly here, with a clean separation between UI layer (Views + ViewModels) and Data layer (Repositories + Services). For a project of this scope (~10 features, offline-only, no backend), a simplified MVVM without a domain layer is ideal. The key technical integration points are the `mobile_scanner` package for camera-based scanning and `qr_flutter` for QR code rendering.

## Recommended Architecture

### High-Level Structure

```
┌─────────────────────────────────────────────────────────┐
│                      UI Layer                           │
│  ┌──────────────────┐    ┌──────────────────┐          │
│  │  Scanner Screen   │    │  Generator Screen │         │
│  │  (Camera View)    │    │  (Text Input)     │         │
│  └────────┬─────────┘    └────────┬─────────┘          │
│           │                       │                     │
│  ┌────────▼─────────┐    ┌────────▼─────────┐          │
│  │ ScannerViewModel  │    │ GeneratorViewModel│         │
│  └────────┬─────────┘    └────────┬─────────┘          │
└───────────┼───────────────────────┼─────────────────────┘
            │                       │
┌───────────▼───────────────────────▼─────────────────────┐
│                     Data Layer                          │
│  ┌──────────────────┐    ┌──────────────────┐          │
│  │  History Repository│   │  Share Service    │         │
│  └──────────────────┘    └──────────────────┘          │
│  ┌──────────────────┐    ┌──────────────────┐          │
│  │  Storage Service  │   │  Clipboard Service│         │
│  └──────────────────┘    └──────────────────┘          │
└─────────────────────────────────────────────────────────┘
```

### Component Boundaries

| Component | Responsibility | Communicates With |
|-----------|---------------|-------------------|
| **ScannerScreen** | Camera preview, scan result display, action buttons (open URL, copy, share) | ScannerViewModel |
| **GeneratorScreen** | Text input, QR code preview, save/share buttons | GeneratorViewModel |
| **HistoryScreen** | List of recent scans and generations | HistoryRepository |
| **ScannerViewModel** | Manages scanner state (scanning, result, error), processes scan results | ScannerScreen, HistoryRepository |
| **GeneratorViewModel** | Manages generation state (text input, QR output), handles save/share | GeneratorScreen, HistoryRepository, ShareService |
| **HistoryRepository** | Stores/retrieves scan and generation history locally | StorageService |
| **ShareService** | Handles native share sheet, clipboard operations | Platform channels |
| **StorageService** | Persists data to local storage (SharedPreferences/SQLite) | Platform storage |

### Data Flow (Unidirectional)

```
User Action → View → ViewModel → Repository → Storage
                 ↑                    ↓
                 └──── State Update ──┘
```

1. **Scan flow:** User points camera → `mobile_scanner` detects QR → `ScannerViewModel.onDetect()` → processes result → updates state → UI shows result with action buttons
2. **Generate flow:** User types text → `GeneratorViewModel` validates → `qr_flutter` renders QR → user saves/shares
3. **History flow:** After scan or generation → ViewModel calls `HistoryRepository.save()` → stored locally → `HistoryScreen` reads from repository
4. **Share flow:** User taps share → ViewModel calls `ShareService` → platform share sheet opens

## Key Patterns

### Pattern 1: MVVM (Model-View-ViewModel)
**What:** Separate UI (View) from business logic (ViewModel). View observes ViewModel state changes.
**When:** Always — this is Flutter team's strongly recommended pattern.
**Example:**
```dart
// ViewModel
class ScannerViewModel extends ChangeNotifier {
  String? _scanResult;
  String? get scanResult => _scanResult;
  
  void onDetect(BarcodeCapture capture) {
    if (capture.barcodes.isNotEmpty) {
      _scanResult = capture.barcodes.first.rawValue;
      notifyListeners();
    }
  }
}

// View
class ScannerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: context.read<ScannerViewModel>(),
      builder: (context, child) {
        final vm = context.read<ScannerViewModel>();
        return Column(
          children: [
            MobileScanner(onDetect: vm.onDetect),
            if (vm.scanResult != null) Text(vm.scanResult!),
          ],
        );
      },
    );
  }
}
```

### Pattern 2: Repository Pattern
**What:** Abstract data access behind a Repository interface. ViewModel never touches storage directly.
**When:** Always — isolates data logic from UI logic.
**Example:**
```dart
abstract class HistoryRepository {
  Future<List<ScanRecord>> getRecentScans();
  Future<void> saveScan(ScanRecord record);
}

class LocalHistoryRepository implements HistoryRepository {
  final StorageService _storage;
  
  LocalHistoryRepository(this._storage);
  
  @override
  Future<List<ScanRecord>> getRecentScans() async {
    final data = await _storage.get('history');
    return (data as List).map((e) => ScanRecord.fromJson(e)).toList();
  }
}
```

### Pattern 3: Dependency Injection
**What:** Provide dependencies through constructors, not global singletons.
**When:** Always — makes code testable and avoids hidden dependencies.
**Example:**
```dart
// Using provider package
void main() {
  final storage = StorageService();
  final historyRepo = LocalHistoryRepository(storage);
  
  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storage),
        Provider<HistoryRepository>.value(value: historyRepo),
        ChangeNotifierProvider(create: (_) => ScannerViewModel()),
        ChangeNotifierProvider(create: (_) => GeneratorViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}
```

## Data Models

### Core Models

```dart
// Scan record stored in history
class ScanRecord {
  final String id;
  final String content;
  final ScanType type; // url, text
  final DateTime timestamp;
  final String? rawValue;
}

// Generation record stored in history
class GenerationRecord {
  final String id;
  final String inputText;
  final DateTime timestamp;
  final String? imagePath; // saved QR image path
}

enum ScanType { url, text, unknown }
```

## Platform Integration Requirements

### Android
- `android/app/build.gradle`: `minSdkVersion 21` (required by mobile_scanner)
- `AndroidManifest.xml`: `<uses-permission android:name="android.permission.CAMERA"/>`
- Camera permission request at runtime

### iOS
- `ios/Runner/Info.plist`: `NSCameraUsageDescription` key with usage description
- Camera permission request via `permission_handler` package

## Recommended Package Stack

| Package | Version | Purpose |
|---------|---------|---------|
| `mobile_scanner` | ^7.0.0 | Camera-based QR/barcode scanning (uses ML Kit on Android, AVFoundation on iOS) |
| `qr_flutter` | ^4.1.0 | QR code rendering as Flutter widget |
| `provider` | ^6.0.0 | Dependency injection and state management |
| `shared_preferences` | ^2.2.0 | Simple key-value local storage for history |
| `path_provider` | ^2.1.0 | File system access for saving QR images |
| `share_plus` | ^7.0.0 | Native share sheet integration |
| `permission_handler` | ^10.2.0 | Runtime permission requests |
| `image_gallery_saver` | ^2.0.0 | Save QR images to device gallery |

## Anti-Patterns to Avoid

### Anti-Pattern 1: Logic in Widgets
**What:** Putting business logic directly in widget build methods.
**Why bad:** Makes code untestable, hard to maintain, causes rebuild issues.
**Instead:** Move all logic to ViewModels. Widgets should only render state.

### Anti-Pattern 2: Global Singletons
**What:** Using static instances or global variables for services.
**Why bad:** Hidden dependencies, impossible to mock for testing.
**Instead:** Use dependency injection via constructor or provider package.

### Anti-Pattern 3: Tight Coupling Between Screens
**What:** One screen directly importing and using another screen's ViewModel.
**Why bad:** Creates circular dependencies, breaks separation of concerns.
**Instead:** Use shared Repositories for cross-screen data sharing.

## Build Order Implications

Based on component dependencies:

1. **StorageService** → Foundation for all persistence
2. **Data Models** → Shared across all layers
3. **HistoryRepository** → Depends on StorageService and models
4. **ScannerViewModel** → Depends on HistoryRepository
5. **ScannerScreen** → Depends on ScannerViewModel
6. **GeneratorViewModel** → Depends on HistoryRepository
7. **GeneratorScreen** → Depends on GeneratorViewModel
8. **ShareService** → Independent, can be built anytime
9. **HistoryScreen** → Depends on HistoryRepository
10. **App Shell (Navigation)** → Ties screens together

## Scalability Considerations

| Concern | Current (Offline, Single User) | Future Expansion |
|---------|-------------------------------|------------------|
| Storage | SharedPreferences (key-value) | SQLite via sqflite for complex queries |
| History | Local only | Cloud sync via Firebase |
| QR Types | Text + URLs | WiFi, vCards, contacts (add new ScanType variants) |
| Sharing | Native share sheet only | Direct integrations (WhatsApp, email templates) |

## Sources

- Flutter Official Architecture Guide: https://docs.flutter.dev/app-architecture/recommendations
- Flutter Architecture Case Study: https://docs.flutter.dev/app-architecture/case-study
- mobile_scanner package: https://pub.dev/packages/mobile_scanner
- qr_flutter package: https://pub.dev/packages/qr_flutter
- QR Scanner Pro (commercial reference): https://codecanyon.net/item/qr-scanner-pro-flutter-qr-code-scanner-generator/59985533
- Building Flutter QR Scanner: https://appilian.com/flutter-qr-code-scanner-mobile-app-development/
