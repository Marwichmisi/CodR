# Feature Landscape

**Domain:** QR Code Scanner & Generator Mobile App
**Researched:** 2026-06-27

## Table Stakes

Features users expect. Missing = product feels incomplete.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| **QR scanning via camera** | Core functionality — users install app for this | Medium | Use `mobile_scanner` package (ML Kit on Android, AVFoundation on iOS). Must handle poor lighting, reflections, partial obstruction |
| **Real-time scan feedback** | Users expect instant detection (<2 seconds) | Low | Show scan window overlay, vibration/sound on detect |
| **Flash/torch control** | Many QR codes are in low-light environments (restaurants, events) | Low | Simple toggle button on scanner UI |
| **QR generation from text/URL** | Second core function — creating codes for sharing | Low | Use `qr_flutter` package. Text input field with character counter |
| **Display scanned content with actions** | Users need to do something with scanned data | Low | Open URL, copy to clipboard, share via native sheet |
| **Save generated QR as image** | Users want to keep/share their generated codes | Medium | Save to gallery with proper permissions handling (`image_gallery_saver` or `gal`) |
| **Share QR code** | Native share sheet for sharing generated codes | Low | Use `share_plus` package |
| **Copy scanned content** | Quick clipboard access for URLs, text | Low | Clipboard API + toast/snackbar feedback |
| **Scan history (local)** | Users scan codes multiple times, need to find previous scans | Medium | SQLite via `sqflite` or `drift`. Store: content, type, timestamp. Max ~500 entries with LRU eviction |
| **Material 3 UI** | Modern, consistent design language | Low | Use Flutter's built-in Material 3 theme |
| **URL detection & actions** | Most scanned QR codes contain URLs — must handle gracefully | Low | Regex detection, show "Open in browser" button for URLs |
| **Offline operation** | App must work without internet (project constraint) | Low | All processing local, no network calls |

## Differentiators

Features that set product apart. Not expected, but valued.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| **Scan from gallery/images** | Scan QR codes from screenshots, photos | Medium | Use `image_picker` + `mobile_scanner` analyzeImage. Out of scope per PROJECT.md but commonly requested |
| **Batch scanning** | Scan multiple QR codes in sequence without navigating away | Medium | Hold scan results in list, continue scanning. Useful for inventory, events |
| **QR type presets** | Quick access to common QR types: URL, WiFi, contact, email | Low | Pre-formatted input templates instead of raw text |
| **Dark mode support** | Better UX in low-light scanning environments | Low | Flutter's `ThemeMode` with system preference detection |
| **Scan result type detection** | Auto-detect if QR contains URL, email, phone, WiFi, vCard | Low | Parse content pattern, show relevant actions per type |
| **Custom QR colors** | Personalize generated QR codes | Low | Color picker for foreground/background (within contrast limits) |
| **QR code frames/borders** | Add visual frames around QR codes for printing | Medium | Decorative frames with text (e.g., "Scan Me") |
| **Export history as CSV** | Power users need data export | Low | Export scan history to CSV file for spreadsheet use |
| **Barcode support** | Scan EAN-13, UPC, Code 128 in addition to QR | Medium | `mobile_scanner` supports multiple formats — just enable them |
| **Sound/vibration feedback** | Tactile confirmation on successful scan | Low | Haptic feedback + optional beep sound |
| **Scan region overlay** | Visual guide showing where to point camera | Low | Animated border/overlay on camera preview |

## Anti-Features

Features to explicitly NOT build.

| Anti-Feature | Why Avoid | What to Do Instead |
|--------------|-----------|-------------------|
| **User accounts / authentication** | Project scope is personal/offline, adds massive complexity | Keep all data local, no user identity needed |
| **Backend / server** | Explicitly out of scope — app is 100% offline | SQLite for local storage, no API calls |
| **Dynamic QR codes** | Require server to redirect — not possible offline | Static QR codes only |
| **Analytics / tracking** | Privacy concern + requires backend | No analytics, no telemetry |
| **Cloud sync** | Requires backend, contradicts offline constraint | Local storage only |
| **QR customization with logos** | Out of scope per PROJECT.md, adds rendering complexity | Simple color changes only if any customization |
| **Animated QR codes** | Niche feature, high complexity, not useful for personal app | Standard static QR only |
| **QR code from business card** | vCard/contacts explicitly out of scope | Text and URLs only |
| **WiFi QR generation** | Out of scope per PROJECT.md | Defer to future version |
| **Barcode generation** | Scope creep — scanner generates QR, not barcodes | QR only for generation |
| **Print QR codes directly** | Requires printer integration, out of scope | Save/share images instead |
| **QR code editing after creation** | Requires versioning system, adds complexity | Generate new QR codes instead |
| **Multi-language support** | Not needed for personal/learning project | French + English only if needed |

## Feature Dependencies

```
Camera Permission → QR Scanning → Content Display → Actions (open/copy/share)
                                      ↓
                              Content Type Detection → Contextual Actions
                                      ↓
                              History Storage → History View

QR Generation → Color Customization → Save Image → Gallery Permission
                    ↓                        ↓
              Frame Overlay            Share (native share sheet)
```

## MVP Recommendation

**Phase 1 — Core Scanner (MVP)**
1. QR scanning via camera with real-time feedback
2. Flash/torch toggle
3. Display scanned content with URL detection
4. Action buttons: open URL, copy, share

**Phase 2 — Core Generator**
1. QR generation from text/URL input
2. Save generated QR to gallery
3. Share generated QR via native share sheet
4. Character counter (max 250)

**Phase 3 — History & Polish**
1. Scan history with local SQLite storage
2. History view with search/filter
3. Sound/vibration feedback on scan
4. Material 3 theming polish

**Phase 4 — Differentiators**
1. Dark mode support
2. QR type presets (URL, text, email)
3. Custom QR colors (foreground/background)
4. Barcode format support (EAN-13, UPC)

**Defer:**
- Scan from gallery: Out of scope per PROJECT.md
- Batch scanning: Nice-to-have, low priority
- QR frames/borders: Cosmetic, not essential
- CSV export: Power user feature, not MVP

## Flutter-Specific Considerations

| Consideration | Impact | Recommendation |
|--------------|--------|----------------|
| **mobile_scanner package** | Best Flutter QR scanning option (ML Kit backend, 1.2k stars, active maintenance) | Use `mobile_scanner` — handles camera, ML Kit, multi-format |
| **qr_flutter package** | Standard for QR generation in Flutter | Use `qr_flutter` — simple, reliable, customizable |
| **Camera permissions** | iOS requires `NSCameraUsageDescription` in Info.plist | Add proper permission strings early |
| **Gallery permissions** | iOS requires `NSPhotoLibraryUsageDescription` | Only if adding scan-from-gallery feature |
| **Platform differences** | mobile_scanner uses ML Kit (Android) vs AVFoundation (iOS) | Test on both platforms, behavior may differ |
| **Detection speed** | mobile_scanner has `DetectionSpeed.noDuplicates` option | Use this to prevent multiple rapid scans of same code |
| **Package stability** | mobile_scanner has had major version migrations | Pin version, test thoroughly on upgrade |

## Sources

- [QR & Barcode Scanner app features (Gamma Play)](https://play.google.com/store/apps/details?id=com.gamma.scan)
- [Air Apps QR Code Reader features](https://airapps.co/qr-code)
- [Uniqode Best QR Scanner Apps 2026](https://www.uniqode.com/blog/qr-code-basics/best-qr-code-scanner-apps)
- [QR Code Generator comparison 2026](https://qr-code-maker.app/which-qr-code-generator-is-best)
- [Flutter mobile_scanner package](https://pub.dev/packages/mobile_scanner)
- [Scanbot Flutter QR Scanner SDK](https://scanbot.io/developer/flutter-barcode-scanner/qr-code)
