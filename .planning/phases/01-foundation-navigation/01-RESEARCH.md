# Phase 1: Foundation & Navigation — Research

**Researched:** 2026-06-27
**Domain:** Flutter greenfield project scaffolding, Material 3, navigation, SQLite storage
**Confidence:** HIGH

## Summary

This phase creates a Flutter project from scratch with MVVM architecture, Material 3 theming (seed: sky blue, light mode only), bottom navigation via `go_router` with `StatefulShellRoute.indexedStack`, two data models (ScanRecord, GenerationRecord), a single SQLite storage service via `sqflite`, and responsive layout foundations. All Flutter skills (architecture, routing, tests, previews, responsive) are mandatory.

**Primary recommendation:** Use `StatefulShellRoute.indexedStack` with Material 3 `NavigationBar`, `ColorScheme.fromSeed()` with seed `Color(0xFF87CEEB)`, `google_fonts` for Inter, and `sqflite` 2.4.3 with a singleton database service pattern.

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| INFRA-01 | Initialiser le projet Flutter avec structure MVVM | Architecture skill prescribes data/domain/ui layers; skill pattern is definitive |
| INFRA-02 | Configurer le thème Material 3 (couleurs, typography) | ColorScheme.fromSeed + google_fonts for Inter; seed = sky blue + green |
| INFRA-03 | Mettre en place la navigation entre les écrans | go_router StatefulShellRoute.indexedStack with NavigationBar |
| INFRA-04 | Créer les modèles de données (ScanRecord, GenerationRecord) | Manual JSON serialization via dart:convert per skill pattern |
| INFRA-05 | Mettre en place le service de stockage SQLite (sqflite) | sqflite singleton service with openDatabase, onCreate, versioning |
| UI-01 | Interface Material 3 avec navigation intuitive | NavigationBar with 3 destinations per M3 spec |
| UI-05 | Widget previews pour les composants UI | @Preview annotation from flutter/widget_previews.dart (Flutter 3.35+) |
| QUAL-03 | Layout responsive | LayoutBuilder per skill, breakpoint at 600px |
</phase_requirements>

## User Constraints (from CONTEXT.md)

### Locked Decisions
- **D-01:** Couleurs seed = bleu ciel + vert (pas de dégradé/gradiant)
- **D-02:** Mode clair uniquement (pas de dark mode pour l'instant)
- **D-03:** Police = Inter (moderne, lisible, via Google Fonts)
- **D-04:** Style = minimaliste / épuré
- **D-05:** go_router déclaratif
- **D-06:** Retour Android = retour au 1er onglet (Scanner)
- **D-07:** Toujours Scanner au lancement
- **D-08:** Comportement back = retour au 1er onglet
- **D-09:** Icônes Material standards
- **D-10:** Contenu minimal = titre + icône centrale
- **D-11:** AppBar sur chaque écran
- **D-12:** Couleur onglet actif = seed color

### the agent's Discretion
- Choisir les noms d'icônes exactes selon les standards Material 3
- Choisir la teinte exacte de bleu ciel + vert qui fonctionne bien ensemble
- Organiser les sous-dossiers de tests selon les conventions Flutter standard

### Deferred Ideas (OUT OF SCOPE)
- Mode sombre avec détection automatique (DIFF-01 — v2)
- Presets de types QR (DIFF-02 — v2)
- Couleurs personnalisées pour les QR codes (DIFF-03 — v2)
- QR codes WiFi, contacts, vCards (hors scope v1)
- Backend / serveur (app 100% offline)
- Authentification / comptes utilisateurs (projet perso, pas besoin)

## Project Constraints (from AGENTS.md)
No AGENTS.md found. No project-specific constraints to enforce.

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Material 3 theme | UI (main.dart) | — | ThemeData applied at root via MaterialApp.router |
| Bottom navigation shell | UI (navigation shell) | go_router | StatefulShellRoute manages branch switching |
| Screen rendering | UI (screens) | — | Each screen is a standalone widget |
| Data models (ScanRecord, GenerationRecord) | Data (models/) | — | Plain Dart classes with serialization |
| SQLite storage | Data (services/) | — | StorageService wraps sqflite directly |
| Responsive layout | UI (screens) | — | LayoutBuilder per screen, no server interaction |
| Widget previews | UI (previews) | — | @Preview annotations in screen files |

## Standard Stack

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Flutter SDK | 3.44.x (stable) | Framework | Latest stable, Dart 3.x |
| go_router | 17.3.0 | Declarative routing with StatefulShellRoute | Official Flutter package, Flutter Favorite, 5.7k likes |
| sqflite | 2.4.3 | SQLite database access | Flutter Favorite, 5.5k likes, battle-tested for local storage |
| google_fonts | 8.1.0 | Inter font loading | Flutter Favorite, official Flutter team package |
| path | (bundled) | File path joining for SQLite DB path | Required by sqflite |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| flutter_test | (SDK) | Widget and unit testing | Always — test infrastructure |
| dart:convert | (SDK) | JSON serialization for models | Always — toJson/fromJson |
| widget_previews | (SDK, Flutter 3.35+) | Widget preview annotations | Always — @Preview annotations |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| sqflite | drift (moor) | drift is more powerful (type-safe queries) but heavier; sqflite is simpler for basic CRUD |
| sqflite | hive | hive is NoSQL, not relational; spec requires SQLite |
| go_router | auto_route | go_router is official Flutter package; auto_route uses codegen |
| google_fonts | Bundled font asset | Bundling is faster at runtime but increases app size; google_fonts caches on first load |

**Installation:**
```bash
flutter create qr_scanner --org com.example
cd qr_scanner
flutter pub add go_router
flutter pub add sqflite
flutter pub add google_fonts
flutter pub add path_provider  # needed by google_fonts for caching
```

**Version verification:** Before writing the Standard Stack table, verify each recommended package exists and is current using pub.dev. WebSearch confirmed: go_router 17.3.0 (Jun 2026), sqflite 2.4.3 (Jun 2026), google_fonts 8.1.0 (Apr 2026). [VERIFIED: pub.dev]

## Package Legitimacy Audit

| Package | Registry | Age | Downloads | Source Repo | Verdict | Disposition |
|---------|----------|-----|-----------|-------------|---------|-------------|
| go_router | pub.dev (Flutter) | 5+ years | 3.16M+ | github.com/flutter/packages | OK | Approved |
| sqflite | pub.dev | 8+ years | 2.15M+ | github.com/tekartik/sqflite | OK | Approved |
| google_fonts | pub.dev (Flutter) | 5+ years | 2.64M+ | github.com/flutter/packages | OK | Approved |
| path_provider | pub.dev (Flutter) | 5+ years | 50M+ | github.com/flutter/packages | OK | Approved |

**Packages removed due to [SLOP] verdict:** none
**Packages flagged as suspicious [SUS]:** none

## Architecture Patterns

### System Architecture Diagram

```
┌─────────────────────────────────────────────────┐
│                   main.dart                      │
│          MaterialApp.router(config: router)       │
│              ↓ Theme + Router applied             │
├─────────────────────────────────────────────────┤
│          StatefulNavigationShell                  │
│     ┌──────────┬──────────┬──────────┐          │
│     │Scanner   │Generator │ History  │          │
│     │(tab 0)   │(tab 1)   │(tab 2)   │          │
│     │/scanner  │/generator│/history  │          │
│     └──────────┴──────────┴──────────┘          │
│              ↓ NavigationBar                     │
├─────────────────────────────────────────────────┤
│  Data Layer                                      │
│  ┌──────────────────┐  ┌───────────────────┐    │
│  │ StorageService    │  │ ScanRecord        │    │
│  │ (sqflite wrapper) │  │ GenerationRecord  │    │
│  └──────────────────┘  └───────────────────┘    │
└─────────────────────────────────────────────────┘
```

### Recommended Project Structure

Following the `flutter-apply-architecture-best-practices` skill (simplified for Phase 1 — no ViewModels yet):

```
lib/
├── main.dart                          # App entry, theme, router
├── models/
│   ├── scan_record.dart               # ScanRecord data model
│   └── generation_record.dart         # GenerationRecord data model
├── services/
│   └── storage_service.dart           # SQLite CRUD service
├── screens/
│   ├── scanner_screen.dart            # Placeholder + preview
│   ├── generator_screen.dart          # Placeholder + preview
│   └── history_screen.dart            # Placeholder + preview
├── navigation/
│   └── app_router.dart                # GoRouter config + ScaffoldWithNavBar
└── theme/
    └── app_theme.dart                 # ColorScheme.fromSeed, TextTheme, ThemeData
```

### Pattern 1: go_router StatefulShellRoute with NavigationBar

**What:** Persistent bottom navigation shell that preserves tab state across switches.
**When to use:** When you need bottom navigation with state preservation.
**Source:** go_router skill `flutter-setup-declarative-routing` (lines 161-199, 203-238).

```dart
// Source: flutter-setup-declarative-routing SKILL.md
final GoRouter _router = GoRouter(
  initialLocation: '/scanner',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/scanner',
              builder: (context, state) => const ScannerScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/generator',
              builder: (context, state) => const GeneratorScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/history',
              builder: (context, state) => const HistoryScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({required this.navigationShell, super.key});
  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _goBranch,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.camera_alt), label: 'Scanner'),
          NavigationDestination(icon: Icon(Icons.qr_code), label: 'Générateur'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Historique'),
        ],
      ),
    );
  }
}
```

**Key decision (D-06/D-07/D-08):** Back button on non-Scanner tabs returns to Scanner. Use `redirect` on GoRouter to handle this:

```dart
redirect: (context, state) {
  // D-06/D-08: If user presses back on Generator/History, go to Scanner
  final isOnFirstTab = state.matchedLocation == '/scanner';
  if (!isOnFirstTab && state.matchedLocation == '/generator' || state.matchedLocation == '/history') {
    // go_router handles back button via Navigator; this redirect
    // ensures initial location is always /scanner
  }
  return null;
},
```

Actually, simpler approach: go_router handles back natively. When the user presses Android back on a non-root tab, `StatefulShellRoute` pops to the root branch. To ensure Scanner is always initial, set `initialLocation: '/scanner'` and use `initialLocation: index == navigationShell.currentIndex` in `goBranch`.

### Pattern 2: Material 3 Theme with ColorScheme.fromSeed

**What:** Theme configuration using a single seed color to generate the full Material 3 color scheme.
**When to use:** Always for Material 3 apps — it's the standard approach.
**Source:** Flutter API docs `ColorScheme.fromSeed` (api.flutter.dev).

```dart
// Source: api.flutter.dev/flutter/material/ColorScheme/ColorScheme.fromSeed.html
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color seedColor = Color(0xFF87CEEB); // Sky blue

ThemeData buildLightTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.light,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    textTheme: GoogleFonts.interTextTheme(),
  );
}
```

**Key insight:** `ColorScheme.fromSeed()` with `Brightness.light` generates the full tonal palette. The seed `Color(0xFF87CEEB)` (sky blue) will produce a teal-ish primary (`~#00796B`) and harmonious secondary tones. No manual color overrides needed beyond the seed. [CITED: api.flutter.dev]

### Pattern 3: Data Model with Manual JSON Serialization

**What:** Plain Dart classes with `fromJson`/`toJson` using `dart:convert`.
**When to use:** For simple data models in Phase 1 (no code generation).
**Source:** `flutter-implement-json-serialization` skill.

```dart
// Source: flutter-implement-json-serialization SKILL.md
import 'dart:convert';

class ScanRecord {
  final int id;
  final String content;
  final DateTime timestamp;
  final String type; // 'scan' or 'generation'

  const ScanRecord({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.type,
  });

  factory ScanRecord.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': int id,
        'content': String content,
        'timestamp': String timestamp,
        'type': String type,
      } =>
        ScanRecord(
          id: id,
          content: content,
          timestamp: DateTime.parse(timestamp),
          type: type,
        ),
      _ => throw const FormatException('Failed to load ScanRecord.'),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
    };
  }
}
```

### Pattern 4: Singleton SQLite Storage Service

**What:** Single StorageService class wrapping sqflite with lazy database initialization.
**When to use:** When all models share one database.
**Source:** sqflite documentation and community patterns.

```dart
// Source: sqflite documentation + community patterns
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class StorageService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'qr_scanner.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE scan_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE generation_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');
  }

  // CRUD methods for both models
  Future<void> insertRecord(String table, Map<String, dynamic> data) async {
    final db = await database;
    await db.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> getAll(String table) async {
    final db = await database;
    return await db.query(table, orderBy: 'timestamp DESC');
  }

  Future<Map<String, dynamic>?> getById(String table, int id) async {
    final db = await database;
    final results = await db.query(table, where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> delete(String table, int id) async {
    final db = await database;
    await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }
}
```

**Key insight (SPEC prohibition):** One database file, two tables. Both `scan_records` and `generation_records` share a single `qr_scanner.db` file. This is explicitly required by SPEC prohibition R5.

### Pattern 5: Widget Preview Setup

**What:** `@Preview` annotations on screen widgets for isolated preview rendering.
**When to use:** On all screen widgets per UI-05 requirement.
**Source:** `flutter-add-widget-preview` skill + Flutter API docs.

```dart
// Source: flutter-add-widget-preview SKILL.md
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

@Preview(name: 'Scanner Screen', group: 'Screens')
Widget scannerPreview() {
  return MaterialApp(
    theme: buildLightTheme(),
    home: const ScannerScreen(),
  );
}
```

**Note:** Widget Previewer requires Flutter 3.35+. IDE support (VS Code, Android Studio) requires Flutter 3.38+. Launch via `flutter widget-preview start` or IDE sidebar. [CITED: docs.flutter.dev/tools/widget-previewer]

### Anti-Patterns to Avoid

- **Hardcoding colors:** Never use `Colors.xxx` directly — always use `Theme.of(context).colorScheme` (SPEC prohibition R2).
- **Separate databases:** Do not create separate `openDatabase` calls for ScanRecord and GenerationRecord — use one database with two tables.
- **BottomNavigationBar (deprecated):** Use `NavigationBar` (Material 3) instead of `BottomNavigationBar` (Material 2).
- **setState across screens:** Keep state local to each screen (SPEC prohibition R1). No global state management needed for 3 screens.
- **Dark mode theme:** Do not configure `Brightness.dark` — light mode only per D-02.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| SQLite wrapper | Custom database class | `sqflite` package | Handles platform differences, background threads, migrations |
| Navigation state | Manual Stack + Navigator | `go_router` with `StatefulShellRoute` | Handles back stack, deep linking, state preservation |
| Google Fonts | Bundled .ttf files | `google_fonts` package | Automatic caching, version management, huge font catalog |
| JSON serialization | Manual string parsing | `dart:convert` with `fromJson`/`toJson` | Type safety, error handling, standard pattern |
| Widget preview | Custom dev tools | `flutter widget_previews.dart` | Built-in Flutter feature, IDE integration |
| Responsive layout | Hardcoded pixel values | `LayoutBuilder` per skill | Prevents overflow, adapts to window size |

**Key insight:** Flutter's built-in `NavigationBar`, `ColorScheme.fromSeed()`, and `widget_previews.dart` cover the UI foundations. Do not build custom navigation, color, or preview systems.

## Common Pitfalls

### Pitfall 1: RenderFlex overflow on tablet
**What goes wrong:** Content overflows when tested on 768px tablet width.
**Why it happens:** Placeholder screens use `Column` without `Expanded` or `ConstrainedBox`.
**How to avoid:** Wrap placeholder content in `ConstrainedBox(maxWidth: 480)` and `Center` for tablet layout per UI-SPEC responsive contract.
**Warning signs:** Yellow/black overflow stripes in debug mode.

### Pitfall 2: BottomNavigationBar vs NavigationBar confusion
**What goes wrong:** Using deprecated `BottomNavigationBar` instead of Material 3 `NavigationBar`.
**Why it happens:** Old tutorials still reference `BottomNavigationBar`.
**How to avoid:** Always use `NavigationBar` with `NavigationDestination` (not `BottomNavigationBarItem`). The skill explicitly shows `NavigationBar`.

### Pitfall 3: go_router initialLocation mismatch
**What goes wrong:** App doesn't start on Scanner tab, or back button exits app unexpectedly.
**Why it happens:** `initialLocation` in GoRouter doesn't match the first `StatefulShellBranch` route path.
**How to avoid:** Set `initialLocation: '/scanner'` matching the first branch's route path. Use `initialLocation: index == navigationShell.currentIndex` in `goBranch`.

### Pitfall 4: sqflite not initializing on first launch
**What goes wrong:** Database file not created, CRUD operations fail.
**Why it happens:** Missing `WidgetsFlutterBinding.ensureInitialized()` before `sqflite` operations, or `onCreate` callback not provided.
**How to avoid:** Add `WidgetsFlutterBinding.ensureInitialized()` in `main()` before any async operation. Provide `onCreate` callback in `openDatabase`.

### Pitfall 5: DateTime serialization in SQLite
**What goes wrong:** `DateTime` objects stored as strings lose precision or timezone info.
**Why it happens:** SQLite has no native DateTime type; strings must be in consistent format.
**How to avoid:** Always use `toIso8601String()` for storage and `DateTime.parse()` for retrieval. Store as `TEXT NOT NULL`.

### Pitfall 6: google_fonts network dependency in tests
**What goes wrong:** Widget tests fail because `google_fonts` tries to fetch fonts from network.
**Why it happens:** `GoogleFonts.inter()` fetches fonts at runtime by default.
**How to avoid:** In tests, use `GoogleFonts.config.allowRuntimeFetching = false` or bundle the font in assets for offline-first apps. For Phase 1, tests can use the default theme text style as fallback.

### Pitfall 7: Widget Previewer not finding @Preview
**What goes wrong:** `flutter widget-preview start` shows no previews.
**Why it happens:** Annotations not in a discoverable location, or missing `import 'package:flutter/widget_previews.dart'`.
**How to avoid:** Ensure `@Preview` is on top-level functions or static methods (not private functions). Import `package:flutter/widget_previews.dart`.

## Code Examples

### main.dart — App Entry Point

```dart
import 'package:flutter/material.dart';
import 'navigation/app_router.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QRScannerApp());
}

class QRScannerApp extends StatelessWidget {
  const QRScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'QR Scanner',
      theme: buildLightTheme(),
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
```

### app_theme.dart — Theme Configuration

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color seedColor = Color(0xFF87CEEB); // Sky blue

ThemeData buildLightTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.light,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    textTheme: GoogleFonts.interTextTheme(),
  );
}
```

### Placeholder Screen — All 3 screens follow this pattern

```dart
// Source: flutter-build-responsive-layout SKILL.md
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth > 600 ? 480.0 : constraints.maxWidth;
        return Scaffold(
          appBar: AppBar(title: const Text('QR Scanner')),
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt,
                      size: 64, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 32),
                  Text('Scanner',
                      style: Theme.of(context).textTheme.displayMedium),
                  const SizedBox(height: 16),
                  Text('Pointez votre caméra vers un QR code',
                      style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Widget preview
@Preview(name: 'Scanner Screen', group: 'Screens')
Widget scannerPreview() {
  return MaterialApp(
    theme: buildLightTheme(),
    home: const ScannerScreen(),
  );
}
```

### Unit Test — Data Model

```dart
// test/models/scan_record_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_scanner/models/scan_record.dart';

void main() {
  group('ScanRecord', () {
    test('serializes to JSON and back without data loss', () {
      final record = ScanRecord(
        id: 1,
        content: 'https://example.com',
        timestamp: DateTime(2026, 6, 27, 12, 0),
        type: 'scan',
      );
      final json = record.toJson();
      final restored = ScanRecord.fromJson(json);
      expect(restored.id, record.id);
      expect(restored.content, record.content);
      expect(restored.timestamp, record.timestamp);
      expect(restored.type, record.type);
    });

    test('throws FormatException on invalid JSON', () {
      expect(
        () => ScanRecord.fromJson({'id': 'not_an_int'}),
        throwsFormatException,
      );
    });
  });
}
```

### Widget Test — Navigation

```dart
// test/screens/navigation_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_scanner/navigation/app_router.dart';

void main() {
  testWidgets('bottom navigation switches between screens',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: appRouter));
    await tester.pumpAndSettle();

    // Scanner is shown by default (D-07)
    expect(find.text('Scanner'), findsOneWidget);

    // Tap Generator tab
    await tester.tap(find.text('Générateur'));
    await tester.pumpAndSettle();
    expect(find.text('Générateur'), findsWidgets);

    // Tap History tab
    await tester.tap(find.text('Historique'));
    await tester.pumpAndSettle();
    expect(find.text('Historique'), findsWidgets);

    // Tap back to Scanner
    await tester.tap(find.text('Scanner'));
    await tester.pumpAndSettle();
    expect(find.text('Scanner'), findsWidgets);
  });
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| BottomNavigationBar | NavigationBar (M3) | Flutter 3.16+ | New widget, different API |
| useMaterial3: true explicit | Material 3 default | Flutter 3.16+ | No need to set explicitly |
| navigator 1.0 (Navigator.push) | go_router (Navigator 2.0) | Flutter 3.x ecosystem | Declarative, URL-based routing |
| Manual font bundling | google_fonts package | 2020+ | Runtime fetching + caching |
| Manual color schemes | ColorScheme.fromSeed | Material 3 (2021+) | Single seed generates full palette |

**Deprecated/outdated:**
- `BottomNavigationBar` → replaced by `NavigationBar` (Material 3)
- `ThemeData.dark()` → use `ColorScheme.fromSeed(brightness: Brightness.dark)` for M3
- `useMaterial3: true` → no longer needed (M3 is default since Flutter 3.16)

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Flutter SDK 3.44.x is available on the target machine | Standard Stack | flutter create will fail; planner must verify Flutter installation |
| A2 | Widget Previewer is available (Flutter 3.35+) | Standard Stack | @Preview annotations won't render; planner should verify Flutter version |
| A3 | Seed color Color(0xFF87CEEB) produces teal-ish primary | Theme | Color may not match design intent; user should verify visually |
| A4 | `google_fonts` will fetch Inter font at runtime in dev | google_fonts | Tests may fail if network unavailable; planner should add test workaround |

**If this table is empty:** No empty table — 4 assumptions documented for user confirmation.

## Open Questions

1. **Flutter version on target machine**
   - What we know: Dart 3.11.0 is installed
   - What's unclear: Flutter SDK version (command timed out)
   - Recommendation: Planner should run `flutter --version` before first task to confirm 3.35+ for Widget Previewer support

2. **Seed color exact value**
   - What we know: UI-SPEC specifies `Color(0xFF87CEEB)` (sky blue)
   - What's unclear: Whether this specific hex was visually verified by the user
   - Recommendation: Use the specified value; user can adjust in app_theme.dart if needed

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter SDK | All phases | Unknown (command timed out) | — | Must verify before first task |
| Dart SDK | All phases | ✓ | 3.11.0 | — |
| Android SDK | Emulator testing | Unknown | — | Use physical device or skip |
| Xcode | iOS testing | N/A (Linux) | — | iOS testing requires macOS |

**Missing dependencies with no fallback:**
- Flutter SDK version unknown — planner must verify before execution

**Missing dependencies with fallback:**
- Android/iOS emulators — can test on physical devices or skip platform-specific testing

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | flutter_test (SDK built-in) |
| Config file | none — uses default `flutter test` |
| Quick run command | `flutter test` |
| Full suite command | `flutter test` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| INFRA-04 | ScanRecord JSON roundtrip | unit | `flutter test test/models/scan_record_test.dart -x` | ❌ Wave 0 |
| INFRA-04 | GenerationRecord JSON roundtrip | unit | `flutter test test/models/generation_record_test.dart -x` | ❌ Wave 0 |
| INFRA-05 | StorageService insert + getAll | unit | `flutter test test/services/storage_service_test.dart -x` | ❌ Wave 0 |
| INFRA-03 | Bottom nav switches screens | widget | `flutter test test/screens/navigation_test.dart -x` | ❌ Wave 0 |
| INFRA-02 | Theme renders with correct colors | widget | `flutter test test/theme/theme_test.dart -x` | ❌ Wave 0 |
| UI-01 | NavigationBar present on all screens | widget | `flutter test test/screens/navigation_test.dart -x` | ❌ Wave 0 |
| QUAL-03 | No overflow at 360px and 768px | widget | `flutter test test/screens/responsive_test.dart -x` | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** `flutter test`
- **Per wave merge:** `flutter test`
- **Phase gate:** `flutter test` + `flutter analyze` green before `/gsd-verify-work`

### Wave 0 Gaps
- [ ] `test/models/scan_record_test.dart` — covers INFRA-04 ScanRecord
- [ ] `test/models/generation_record_test.dart` — covers INFRA-04 GenerationRecord
- [ ] `test/services/storage_service_test.dart` — covers INFRA-05
- [ ] `test/screens/navigation_test.dart` — covers INFRA-03, UI-01
- [ ] `test/theme/theme_test.dart` — covers INFRA-02
- [ ] `test/screens/responsive_test.dart` — covers QUAL-03
- [ ] No framework install needed — flutter_test is SDK built-in

## Security Domain

> Required when `security_enforcement` is enabled (default).

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | No | No auth in personal offline app |
| V3 Session Management | No | No sessions |
| V4 Access Control | No | Single user, no access control |
| V5 Input Validation | Yes (future) | Will apply when QR content is processed (Phase 3) |
| V6 Cryptography | No | No encryption needed for local SQLite |

### Known Threat Patterns for Flutter + SQLite

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| SQLite injection | Tampering | sqflite parameterized queries (`whereArgs`) |
| Sensitive data in DB | Information Disclosure | Not applicable — all data is user-generated QR content |
| Third-party package vulnerabilities | Tampering | Use only Flutter Favorite packages, pin versions |

## Sources

### Primary (HIGH confidence)
- Flutter API docs: `ColorScheme.fromSeed` — api.flutter.dev
- go_router 17.3.0 documentation — pub.dev/packages/go_router
- Flutter Widget Previewer docs — docs.flutter.dev/tools/widget-previewer
- `flutter-apply-architecture-best-practices` SKILL.md — project skills
- `flutter-setup-declarative-routing` SKILL.md — project skills
- `flutter-add-widget-test` SKILL.md — project skills
- `flutter-add-widget-preview` SKILL.md — project skills
- `flutter-build-responsive-layout` SKILL.md — project skills
- `flutter-implement-json-serialization` SKILL.md — project skills

### Secondary (MEDIUM confidence)
- go_router StatefulShellRoute examples — github.com/flutter/packages (official example)
- sqflite community patterns — flutterexperts.com, dev.to
- Material 3 NavigationBar spec — m3.material.io

### Tertiary (LOW confidence)
- Flutter 3.44 release notes — docs.flutter.dev (not yet read in full)

## Metadata

**Confidence breakdown:**
- Standard Stack: HIGH — all packages verified on pub.dev, official Flutter packages
- Architecture: HIGH — prescribes exact patterns from mandatory skills
- Pitfalls: HIGH — common known issues with sqflite, go_router, Material 3 migration
- Theme: HIGH — ColorScheme.fromSeed is the standard M3 approach, seed color specified in UI-SPEC

**Research date:** 2026-06-27
**Valid until:** 2026-07-27 (30 days — Flutter ecosystem moves fast but API is stable)
