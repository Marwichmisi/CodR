# Phase 1: Foundation & Navigation — Specification

**Created:** 2026-06-27
**Ambiguity score:** 0.19 (gate: ≤ 0.20)
**Requirements:** 8 locked

## Goal

The Flutter project is scaffolded with MVVM architecture, Material 3 theme, bottom navigation between 3 screens, and SQLite storage foundation ready for subsequent phases.

## Background

No Flutter project exists today — the workspace contains only `.planning/` and `.opencode/` directories. No `pubspec.yaml`, no Dart files, no `lib/` folder. This is a greenfield project that must be created from scratch. The app is a QR Code Scanner & Generator (personal learning project), 100% offline, iOS + Android.

## Requirements

1. **MVVM architecture scaffold**: Flutter project initialized with MVVM folder structure.
   - Current: No project exists — empty workspace
   - Target: Flutter project with `lib/models/`, `lib/viewmodels/`, `lib/services/`, `lib/screens/` directories; `main.dart` entry point that runs without error
   - Acceptance: `flutter analyze` passes with no errors; `flutter run` launches app on emulator/device without crash

2. **Material 3 theme**: Consistent Material 3 theme with colors and typography.
   - Current: No theme configuration
   - Target: `ThemeData` uses `ColorScheme.fromSeed()` with a defined seed color; `TextTheme` configured; app applies theme via `MaterialApp`
   - Acceptance: All screens render with consistent Material 3 styling; `Theme.of(context)` returns non-null colorScheme and textTheme

3. **Bottom navigation shell**: Bottom navigation bar switches between Scanner, Generator, and History screens.
   - Current: No navigation exists
   - Target: `NavigationBar` (Material 3) with 3 tabs; each tab navigates to its respective screen widget; selected tab highlights correctly
   - Acceptance: Tapping each tab switches the visible screen; current tab index persists during session; back button behavior is standard (no exit on first back)

4. **Data models**: ScanRecord and GenerationRecord models defined with simple fields.
   - Current: No models exist
   - Target: `ScanRecord` with fields: `id` (int), `content` (String), `timestamp` (DateTime), `type` (String: 'scan'|'generation'); `GenerationRecord` with same fields; both include `toJson()`/`fromJson()` methods
   - Acceptance: Models can be serialized to JSON and deserialized back without data loss; unit tests pass for both models

5. **SQLite storage service**: Single storage service with CRUD operations for both models.
   - Current: No database or storage service
   - Target: `StorageService` class using `sqflite`; initializes database on first access; provides `insert`, `getAll`, `getById`, `delete` methods for both `ScanRecord` and `GenerationRecord`; database creates tables on first run
   - Acceptance: Database file is created on first app launch; inserting a record and retrieving it returns the same data; `flutter analyze` passes on service code

6. **Responsive layout foundation**: Layout adapts to phone and tablet screen sizes.
   - Current: No layout logic
   - Target: `LayoutBuilder` or `MediaQuery` used in main screens; phone layout uses single-column; tablet layout uses wider content area or side-by-side where applicable
   - Acceptance: App renders correctly on phone (360px width) and tablet (768px width) without overflow errors; no `RenderFlex overflowed` in debug console

7. **Flutter skills applied**: All relevant Flutter skills are used during implementation.
   - Current: Skills available but not applied
   - Target: `flutter-apply-architecture-best-practices` for MVVM structure; `flutter-add-widget-preview` for screen previews; `flutter-add-widget-test` for widget tests; `flutter-build-responsive-layout` for responsive behavior; `flutter-setup-declarative-routing` for navigation
   - Acceptance: Architecture follows skill patterns; widget tests exist for main screens; preview code exists for components

8. **Widget tests for screens**: Unit and widget tests for the foundation.
   - Current: No tests exist
   - Target: Widget tests for at least the main scaffold/navigation; unit tests for data models and StorageService
   - Acceptance: `flutter test` passes with all tests green; test coverage includes navigation, models, and storage

## Boundaries

**In scope:**
- Flutter project creation with `flutter create`
- MVVM folder structure (`lib/models`, `lib/viewmodels`, `lib/services`, `lib/screens`)
- Material 3 theme configuration
- Bottom navigation bar with 3 tabs (Scanner, Generator, History)
- 3 placeholder screen widgets
- Data models: ScanRecord, GenerationRecord (simple fields: id, content, timestamp, type)
- SQLite storage service with basic CRUD
- Responsive layout foundation
- Widget tests for screens and models
- Flutter skills integration

**Out of scope:**
- Camera/scanner functionality — Phase 2
- QR code generation — Phase 4
- History list UI with search/filter — Phase 5
- Actual QR scanning overlay — Phase 2
- Share/copy functionality — Phase 3/4
- Error handling for camera permissions — Phase 2
- Unit tests for ViewModels (no ViewModels yet) — Phase 3

## Constraints

- **Tech stack**: Flutter + Dart (no other frameworks)
- **Offline**: No server connection required, everything local
- **Compatibility**: iOS and Android minimum
- **Skills Flutter obligatoires**: Must use installed Flutter skills (architecture, tests, previews, responsive, routing)
- **Material 3**: Use Flutter's built-in Material 3 support (no custom design systems)
- **State management**: `setState` is sufficient for 2-3 screens (per PROJECT.md decision)

## Acceptance Criteria

- [ ] `flutter create` produces a valid project that runs on emulator/device
- [ ] `lib/models/`, `lib/viewmodels/`, `lib/services/`, `lib/screens/` directories exist
- [ ] `flutter analyze` passes with zero errors
- [ ] Material 3 theme applied via `ColorScheme.fromSeed()`
- [ ] Bottom navigation bar with 3 tabs (Scanner, Generator, History) switches screens
- [ ] ScanRecord and GenerationRecord models with id, content, timestamp, type fields
- [ ] Models support `toJson()`/`fromJson()` serialization
- [ ] StorageService initializes SQLite database on first launch
- [ ] StorageService provides insert, getAll, getById, delete for both models
- [ ] App renders without overflow on 360px (phone) and 768px (tablet) width
- [ ] `flutter test` passes with all tests green
- [ ] Widget tests exist for main scaffold/navigation
- [ ] Unit tests exist for data models

## Edge Coverage

**Coverage:** 8/8 applicable edges resolved · 0 unresolved

| Category | Requirement | Status | Resolution / Reason |
|----------|-------------|--------|---------------------|
| unclassified | R1 | ✅ covered | Acceptance: flutter analyze passes, flutter run launches without crash, folder structure verified |
| unclassified | R2 | ✅ covered | Acceptance: ThemeData uses ColorScheme.fromSeed(), all screens render with consistent styling |
| boundary | R3 | ✅ covered | Acceptance: 3 tabs, each switches screen, tab index persists, standard back button behavior |
| precision | R3 | ✅ covered | Acceptance: NavigationBar (Material 3) used, selected tab highlights correctly |
| unclassified | R4 | ✅ covered | Acceptance: Models have id/content/timestamp/type, toJson/fromJson roundtrip, unit tests pass |
| unclassified | R5 | ✅ covered | Acceptance: DB file created on first launch, insert+getAll returns same data, analyze passes |
| unclassified | R6 | ✅ covered | Acceptance: Renders on 360px and 768px without overflow, LayoutBuilder or MediaQuery used |
| unclassified | R7 | ✅ covered | Acceptance: Architecture follows skill patterns, widget tests exist, preview code exists |

## Prohibitions (must-NOT)

**Coverage:** 3/3 applicable prohibitions resolved · 0 unresolved

| Prohibition (must-NOT statement) | Requirement | Status | Verification / Reason |
|----------------------------------|-------------|--------|------------------------|
| MUST NOT use setState for global state across screens — keep state local to each screen | R1 | resolved | verification: judgment — review during discuss-phase architecture decisions |
| MUST NOT hardcode colors or typography — must use Theme.of(context) | R2 | resolved | verification: test — lint rule or widget test checks Theme.of(context) usage |
| MUST NOT create separate databases for ScanRecord and GenerationRecord — use single SQLite database | R5 | resolved | verification: test — unit test verifies single db instance handles both models |

## Ambiguity Report

| Dimension          | Score | Min  | Status | Notes                                      |
|--------------------|-------|------|--------|---------------------------------------------|
| Goal Clarity       | 0.85  | 0.75 | ✓      | Specific scaffold + navigation + storage     |
| Boundary Clarity   | 0.82  | 0.70 | ✓      | Explicit in/out scope lists                 |
| Constraint Clarity | 0.78  | 0.65 | ✓      | Flutter + Material 3 + skills required      |
| Acceptance Criteria| 0.75  | 0.70 | ✓      | 13 pass/fail checkboxes                     |
| **Ambiguity**      | 0.19  | ≤0.20| ✓      |                                             |

## Interview Log

| Round | Perspective     | Question summary                          | Decision locked                                |
|-------|-----------------|------------------------------------------|------------------------------------------------|
| 1     | Researcher      | Champs des modèles de données ?           | Simples: id, content, timestamp, type          |
| 1     | Researcher      | Icônes/noms de la bottom nav ?            | Icônes spécifiques à choisir en plan           |
| 1     | Researcher      | Contraintes spécifiques ?                 | Roadmap suffit, pas de contraintes supplémentaires |
| 2     | Simplificateur  | Critères d'acceptation ?                  | Basés sur les success criteria du roadmap      |
| 2     | Simplificateur  | Skills Flutter obligatoires ?             | Oui, appliqués à chaque plan                   |
| 2     | Simplificateur  | Organisation SQLite ?                     | Service unique pour les deux modèles           |

---

*Phase: 01-foundation-navigation*
*Spec created: 2026-06-27*
*Next step: /gsd-discuss-phase 1 — implementation decisions (how to build what's specified above)*
