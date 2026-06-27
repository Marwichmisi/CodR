# Technology Stack

**Project:** QR Code Scanner & Generator Flutter App
**Researched:** 2026-06-27

## Recommended Stack

### Core Framework
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| Flutter | 3.x (latest stable) | Cross-platform mobile framework | Imposed by project constraints; excellent for camera-based apps |
| Dart | 3.x | Programming language | Flutter's native language, required |

### QR Code Scanning
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| **mobile_scanner** | ^7.2.0 | Camera-based QR/barcode scanning | **Best choice.** 1K+ stars, 1M+ downloads, actively maintained (last update: Feb 2026). Uses CameraX/ML Kit on Android, AVFoundation/Apple Vision on iOS. Real-time detection, customizable camera behavior, supports multiple barcode formats. |

**Why not alternatives:**
- `qr_code_scanner` — Deprecated, last update 2023, no longer maintained
- `flutter_barcode_scanner` — Less popular, fewer features, less frequent updates
- `camera` + manual ML Kit — Too much boilerplate for a simple scanner

**Key mobile_scanner features for this project:**
- Real-time QR code detection
- Torch (flashlight) control for low-light scanning
- Auto-zoom on Android
- Customizable scan window
- Camera lifecycle management

### QR Code Generation
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| **qr_flutter** | ^4.1.0 | Render QR codes as widgets | Most popular (2.3K stars, 1.4M downloads). Pure Dart, no platform dependencies. Supports versions 1-40, error correction, image overlays, configurable styles. |

**Key qr_flutter features for this project:**
- `QrImageView` widget for direct rendering
- Automatic version detection (`QrVersions.auto`)
- Configurable size, colors, error correction
- Export to image data for saving/sharing

### Local Storage (History)
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| **sqflite** | ^2.4.1 | SQLite database for scan history | Battle-tested, relational, no codegen overhead. Perfect for structured history data (timestamp, content, type, isURL). |

**Why not alternatives:**
- `drift` — Overkill for simple history; adds codegen complexity
- `hive` — Abandoned by original author; community fork only. Key-value model doesn't suit structured history queries
- `isar` — Experimental community fork; maintenance risk not worth it for a simple app
- `shared_preferences` — Not a database; only for settings/flags

**Schema suggestion:**
```sql
CREATE TABLE history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  content TEXT NOT NULL,
  type TEXT NOT NULL, -- 'scan' or 'generate'
  is_url BOOLEAN NOT NULL DEFAULT 0,
  timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

### Permissions & Platform Integration
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| **permission_handler** | ^11.3.1 | Request/manage camera permission | Standard for Flutter permission handling. Handles Android runtime permissions and iOS Info.plist entries. Cross-platform API. |

### Image Saving & Sharing
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| **image_gallery_saver** | ^2.0.3 | Save QR images to device gallery | Simple API, handles Android/iOS gallery writes. Mature package. |
| **share_plus** | ^9.0.0 | Native share sheet integration | Official Flutter community package. Wraps ACTION_SEND (Android) / UIActivityViewController (iOS). Supports text, files, images. |
| **path_provider** | ^2.1.3 | Get temp directory for sharing | Required by share_plus for temporary file storage before sharing. |

### UI Framework
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| **Material 3** | (built into Flutter) | Design system | Imposed by project requirements. Modern, well-supported, accessible. |

### State Management
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| **setState** | (built-in) | Simple state management | **For this project, setState is sufficient.** The app has 2-3 screens, no complex state flows. No need for Riverpod/Bloc overhead. |

**Why not Riverpod/Bloc:**
- Project is small (scanner → result → history)
- Learning project — keep complexity low
- setState + StatefulWidgets cover all needs here
- If app grows, refactor to Riverpod later (best upgrade path)

### Clipboard
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| **flutter/services.dart** (Clipboard) | (built-in) | Copy to clipboard | No package needed; Flutter's built-in `Clipboard.setData()` handles this. |

## Complete pubspec.yaml

```yaml
name: qr_scanner_generator
description: A QR code scanner and generator Flutter app
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.7.0

dependencies:
  flutter:
    sdk: flutter

  # QR Code Scanning (camera-based)
  mobile_scanner: ^7.2.0

  # QR Code Generation
  qr_flutter: ^4.1.0

  # Local Database (history)
  sqflite: ^2.4.1

  # Permissions
  permission_handler: ^11.3.1

  # Image saving and sharing
  image_gallery_saver: ^2.0.3
  share_plus: ^9.0.0
  path_provider: ^2.1.3

  # UI (built into Flutter)
  # Material 3 is included by default

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

## What NOT to Use

| Technology | Why Not |
|------------|---------|
| `qr_code_scanner` | Deprecated, unmaintained since 2023 |
| `flutter_barcode_scanner` | Less popular, fewer features than mobile_scanner |
| `hive` / `isar` | Abandoned/unmaintained; sqflite is more reliable for this use case |
| `drift` | Overkill; adds codegen for a simple history table |
| `riverpod` / `bloc` | Too heavy for a 2-3 screen app; setState is sufficient |
| `get_it` + `injectable` | DI is overkill for this project size |
| `dio` | No HTTP needed; app is 100% offline |
| `firebase_*` | No backend required |

## Platform-Specific Setup

### Android (android/app/src/main/AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.FLASHLIGHT" />
```

### iOS (ios/Runner/Info.plist)
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to scan QR codes</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photos access to save QR code images</string>
```

## Confidence Assessment

| Component | Confidence | Notes |
|-----------|------------|-------|
| mobile_scanner | **HIGH** | 1M+ downloads, actively maintained, clear API, well-documented |
| qr_flutter | **HIGH** | 1.4M downloads, stable, feature-complete for QR generation |
| sqflite | **HIGH** | Industry standard, battle-tested, perfect for simple history |
| permission_handler | **HIGH** | Official Flutter community package, widely used |
| image_gallery_saver | **MEDIUM** | Works but less maintained than others; may need fork for latest Flutter versions |
| share_plus | **HIGH** | Official Flutter community package, well-maintained |
| setState (no state mgmt) | **HIGH** | App is simple enough; no need for external state management |

## Sources

- pub.dev/packages/mobile_scanner (official docs, 2026)
- pub.dev/packages/qr_flutter (official docs, 2026)
- pub.dev/packages/sqflite (official docs, 2026)
- pub.dev/packages/share_plus (official docs, 2026)
- pub.dev/packages/permission_handler (official docs, 2026)
- pub.dev/packages/image_gallery_saver (GitHub, 2026)
- "The Flutter Local Database Landscape in 2026" — Luci Studio (June 2026)
- "Provider vs Riverpod vs Bloc for Flutter state management in 2026" — Start Debugging (June 2026)
- "Flutter Local Storage Options Comparison" — Ajmani Dev (April 2026)
