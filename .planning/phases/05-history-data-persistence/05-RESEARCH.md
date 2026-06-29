# Phase 05: History & Data Persistence — RESEARCH.md

**Researched:** 2026-06-29  
**Domain:** Flutter SQLite persistence, MVVM ViewModel integration, real-time search/filter  
**Confidence:** HIGH

---

## Summary

Cette phase connecte le StorageService existant aux ViewModels Scanner et Generator, crée un HistoryViewModel pour gérer l'historique (chargement, recherche, filtrage, suppression), et reconstruit l'HistoryScreen en un StatefulWidget fonctionnel. La persistance SQLite est déjà en place (scan_records, generation_records tables) — le travail consiste à injecter StorageService dans les ViewModels existants et à créer la couche de présentation pour l'historique.

**Recommandation principale:** Créer un abstrait `RecordBase` pour unifier ScanRecord et GenerationRecord, ajouter `get_time_ago` pour les timestamps relatifs en français, et suivre le pattern ChangeNotifier existant pour HistoryViewModel.

---

## Architectural Responsibility Map

| Capacité | Tier Principal | Tier Secondaire | Rationale |
|----------|---------------|-----------------|-----------|
| Insertion scan en BDD | API / Backend (ViewModel) | — | ScannerViewModel orchestre l'action, StorageService persiste |
| Insertion génération en BDD | API / Backend (ViewModel) | — | GeneratorViewModel orchestre, StorageService persiste |
| Chargement historique | API / Backend (ViewModel) | UI (Screen) | HistoryViewModel charge depuis BDD, Screen affiche |
| Recherche/Filtrage | API / Backend (ViewModel) | UI (Screen) | Logique métier dans ViewModel, UI réagit via ChangeNotifier |
| Suppression avec confirmation | UI (Screen) | API / Backend (ViewModel) | Dialog dans Screen, appel ViewModel pour persister |
| FIFO auto-cleanup | API / Backend (StorageService) | — | Logique de nettoyage au moment de l'insertion |
| Affichage timestamps relatifs | UI (Screen/Widget) | — | Formatage dans le widget, données du ViewModel |

---

## Standard Stack

### Core (déjà installé)

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| sqflite | ^2.3.0 | SQLite database | Stockage persistant, déjà configuré |
| go_router | ^17.3.0 | Routing | Navigation existante, StatefulShellRoute |
| flutter | SDK | UI framework | Stack principal |

### Nouveaux packages à ajouter

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| get_time_ago | ^2.3.2 | Timestamps relatifs ("il y a X min", "hier") | Formatage locale-fr pour l'historique |
| intl | (transitive via get_time_ago) | Formattage dates | Utilisé par get_time_ago pour le locale FR |

### Dev Dependencies (déjà installé)

| Library | Version | Purpose |
|---------|---------|---------|
| mocktail | ^1.0.5 | Mocking pour tests ViewModel |
| sqflite_common_ffi | ^2.4.2 | SQLite en test |

**Installation:**
```bash
cd qr_scanner && flutter pub add get_time_ago
```

**Vérification versions:** `get_time_ago` v2.3.2 confirmé sur pub.dev [CITED: pub.dev/packages/get_time_ago]

---

## Package Legitimacy Audit

| Package | Registry | Age | Downloads | Source Repo | Verdict | Disposition |
|---------|----------|-----|-----------|-------------|---------|-------------|
| get_time_ago | npm/PyPI/pub.dev | ~2 years | 10.4k/wk | github.com/nixrajput/get-time-ago | OK | Approved |

*Package existant, bien maintenu, supports FR nativement.*

---

## Architecture Patterns

### Pattern existant: ChangeNotifier ViewModel

Tous les ViewModels du projet suivent le même pattern [VERIFIED: codebase]:
- Constructor avec dépendances injectées via nommés `required`
- État privé avec getters publics
- `notifyListeners()` après chaque mutation d'état
- Tests avec `mocktail` pour les services

```dart
// Source: qr_scanner/lib/viewmodels/scanner_viewmodel.dart
class ScannerViewModel extends ChangeNotifier {
  final PermissionService _permissionService;
  ScannerViewModel({required PermissionService permissionService})
      : _permissionService = permissionService;
  // ... state fields, getters, methods calling notifyListeners()
}
```

### Pattern existant: Injection via createAppRouter()

Les ViewModels sont créés inline dans `app_router.dart` [VERIFIED: codebase]:
```dart
GoRoute(
  path: '/scanner',
  builder: (context, state) => ScannerScreen(
    viewModel: ScannerViewModel(
      permissionService: permissionService ?? SystemPermissionService(),
    ),
    resultViewModel: ResultViewModel(),
  ),
),
```

**Décision clé:** StorageService doit être injecté via `createAppRouter()` et passé aux ViewModels Scanner/Generator, puis transmis au HistoryViewModel.

### Pattern recommandé: RecordBase abstraction

`ScanRecord` et `GenerationRecord` ont des structures identiques (id, content, timestamp, type) [VERIFIED: codebase]. Créer une classe abstraite commune:

```dart
abstract class RecordBase {
  int get id;
  String get content;
  DateTime get timestamp;
  String get type; // 'scan' ou 'generation'
}
```

Les deux modèles existants implémentent cette interface. Cela permet à HistoryViewModel de manipuler une liste unifiée `List<RecordBase>` sans perte de type.

### Pattern recommandé: Dismissible + confirmDismiss

Le pattern Flutter standard pour suppression avec confirmation [CITED: docs.flutter.dev/cookbook/gestures/dismissible]:

```dart
Dismissible(
  key: Key(record.id.toString()),
  confirmDismiss: (direction) => showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Supprimer ?'),
      content: const Text('Cette action est irréversible.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
      ],
    ),
  ),
  onDismissed: (direction) => viewModel.deleteRecord(record),
  background: Container(color: Colors.red, alignment: Alignment.centerRight, child: Icon(Icons.delete, color: Colors.white)),
  child: RecordCard(record: record),
)
```

### Pattern recommandé: Recherche temps réel + filtre type

Utiliser un `ValueNotifier<String>` pour la recherche et un `ValueNotifier<RecordType?>` pour le filtre, combinés via un getter filtré dans le ViewModel:

```dart
// Dans HistoryViewModel
final searchController = TextEditingController();
RecordType? _selectedFilter;

List<RecordBase> get filteredRecords {
  var records = List<RecordBase>.from(_allRecords);
  if (_selectedFilter != null) {
    records = records.where((r) => r.type == _selectedFilter!.name).toList();
  }
  if (searchController.text.isNotEmpty) {
    final query = searchController.text.toLowerCase();
    records = records.where((r) => r.content.toLowerCase().contains(query)).toList();
  }
  return records;
}
```

---

## Integration Points — Emplacements exacts dans le code

### 1. ScannerViewModel → StorageService

**Fichier:** `qr_scanner/lib/viewmodels/scanner_viewmodel.dart`

- Ajouter `StorageService` au constructor
- Créer une méthode `saveScanRecord(String content)` qui:
  - Crée un `ScanRecord(id: 0, content: content, timestamp: DateTime.now(), type: 'scan')`
  - Appelle `storageService.insertScanRecord(record)`
- Appeler cette méthode depuis `ScannerScreen._showScanResult()` quand l'utilisateur confirme le scan

**Point d'appel:** `ScannerScreen._showScanResult()` (ligne 254) — le scan est accepté ici, c'est le bon moment pour persister.

### 2. GeneratorViewModel → StorageService

**Fichier:** `qr_scanner/lib/viewmodels/generator_viewmodel.dart`

- Ajouter `StorageService` au constructor
- Créer une méthode `saveGenerationRecord()` qui:
  - Crée un `GenerationRecord(id: 0, content: _inputText, timestamp: DateTime.now(), type: 'generation')`
  - Appelle `storageService.insertGenerationRecord(record)`
- Appeler cette méthode depuis `GeneratorScreen._saveToGallery()` OU ajouter un bouton dédié "Sauvegarder en historique"

**Point d'appel:** `GeneratorScreen._saveToGallery()` (ligne 205) — ou ajouter un callback séparé pour la persistance.

### 3. HistoryViewModel (nouveau)

**Fichier:** `qr_scanner/lib/viewmodels/history_viewmodel.dart`

- Constructor: `HistoryViewModel({required StorageService storageService})`
- État: `_allRecords`, `_searchQuery`, `_selectedType`
- Méthodes: `loadRecords()`, `deleteRecord(RecordBase)`, `setFilter(RecordType?)`
- FIFO: intégré dans `loadRecords()` ou dans `StorageService.insertScanRecord/insertGenerationRecord`

### 4. app_router.dart — Injection

**Fichier:** `qr_scanner/lib/navigation/app_router.dart`

- Modifier `createAppRouter()` pour accepter `StorageService?` en paramètre
- Créer une instance `StorageService` dans `main.dart` ou au niveau de `createAppRouter()`
- Passer `storageService` à ScannerViewModel, GeneratorViewModel, et HistoryViewModel
- Le route `/history` doit créer HistoryViewModel et le passer à HistoryScreen

### 5. HistoryScreen (rebuild complet)

**Fichier:** `qr_scanner/lib/screens/history_screen.dart`

- Transformer de `StatelessWidget` en `StatefulWidget`
- Intégrer `HistoryViewModel` via constructor
- Structure: `Scaffold → AppBar → LayoutBuilder → Column (SearchBar + TypeFilter + ListView.builder)`
- Chaque item: `Dismissible → Card → ListTile` avec icône type, contenu tronqué, timestamp relatif
- États: vide, chargement, erreur, liste

### 6. RecordBase (nouveau)

**Fichier:** `qr_scanner/lib/models/record_base.dart`

- Classe abstraite avec les getters communs
- Modifier `ScanRecord` et `GenerationRecord` pour l'implémenter

### 7. StorageService — FIFO cleanup

**Fichier:** `qr_scanner/lib/services/storage_service.dart`

- Ajouter une méthode `_enforceFifoLimit(String table, {int maxRecords = 100})`
- L'appeler après chaque `insertScanRecord` et `insertGenerationRecord`
- Logique: compter les enregistrements, si > 100, supprimer les plus anciens (ORDER BY timestamp ASC LIMIT n à supprimer)

---

## Design Decisions

### D1: Où placer la logique FIFO?

**Recommandation:** Dans `StorageService`, pas dans les ViewModels. C'est une contrainte de stockage, pas de métier.

```dart
Future<void> _enforceFifoLimit(Database db, String table, {int maxRecords = 100}) async {
  final count = Sqflite.firstIntValue(
    await db.rawQuery('SELECT COUNT(*) FROM $table'),
  );
  if (count != null && count > maxRecords) {
    final toDelete = count - maxRecords;
    await db.rawDelete(
      'DELETE FROM $table WHERE id IN (SELECT id FROM $table ORDER BY timestamp ASC LIMIT $toDelete)',
    );
  }
}
```

### D2: RecordBase — abstract class ou mixin?

**Recommandation:** `abstract class` — plus simple, pas besoin de mixin ici car les deux modèles ont exactement les mêmes champs. Les deux modèles existants `extends RecordBase`.

### D3: Timestamp relatif — package ou manuel?

**Recommandation:** Utiliser `get_time_ago` v2.3.2. Supporte FR nativement (`GetTimeAgo.parse(dateTime, locale: 'fr')`). Pour les dates > 48h, basculer sur `DateFormat` d'intl.

```dart
String formatTimestamp(DateTime timestamp) {
  final now = DateTime.now();
  final diff = now.difference(timestamp);
  if (diff.inHours < 48) {
    return GetTimeAgo.parse(timestamp, locale: 'fr');
  } else {
    return DateFormat.yMMMd('fr').add_Hm().format(timestamp);
  }
}
```

### D4: TypeFilter — enum ou string?

**Recommandation:** Créer un enum `RecordType { scan, generation }` pour la cohérence avec `ContentType` existant.

### D5: Où persister le scan — dans le ViewModel ou dans le Screen?

**Recommandation:** Dans le ViewModel (ScannerViewModel) pour garder la logique métier centralisée. Le Screen appelle `viewModel.saveScanRecord(code)` et le ViewModel gère l'insertion + FIFO.

---

## Don't Hand-Roll

| Problème | Ne pas construire | Utiliser à la place | Pourquoi |
|----------|-------------------|---------------------|----------|
| Timestamps relatifs | Calcul manuel DateTime.now().difference() | `get_time_ago` | Gère toutes les unités, locales, edge cases |
| Suppression swipe | Custom gesture detector | `Dismissible` widget | Pattern Flutter standard, animation incluse |
| Recherche temps réel | Polling, Timer.periodic | `TextEditingController` + `addListener` | Réactif, pas de polling |
| FIFO cleanup | Manually tracking count | SQL `DELETE WHERE id IN (SELECT ... LIMIT N)` | Atomic, performant, pas de race condition |

---

## Common Pitfalls

### Pitfall 1: StorageService singleton partagé
**Quoi:** `_database` est un static nullable — si deux instances de StorageService existent, elles partagent la même BDD. C'est OK ici (pattern singleton), mais attention en test.
**Comment éviter:** En test, créer une StorageService par test via `setUp()` comme dans `storage_service_test.dart` existant.

### Pitfall 2: FIFO race condition
**Quoi:** Si deux insertions concurrentes comptent le même nombre d'enregistrements avant que le nettoyage ne s'exécute.
**Comment éviter:** Utiliser une transaction SQLite pour l'insertion + le nettoyage FIFO dans la même opération atomique.

### Pitfall 3: HistoricalScreen rebuild perf
**Quoi:** Rebuild de toute la liste à chaque caractère tapé dans la recherche.
**Comment éviter:** Debounce de 300ms sur la recherche (pattern déjà utilisé dans GeneratorViewModel). Ou filtrer en mémoire sans notifier à chaque keystroke.

### Pitfall 4: DateTime timezone
**Quoi:** Les timestamps sont stockés en ISO 8601 mais SQLite ne gère pas les timezones nativement.
**Comment éviter:** Toujours stocker en UTC (`DateTime.now().toUtc()`) et convertir en local pour l'affichage. Le pattern existant dans les modèles le fait déjà.

### Pitfall 5: HistoryScreen sans injection
**Quoi:** L'HistoryScreen actuel est `const HistoryScreen()` sans paramètres — le routeur le crée sans ViewModel.
**Comment éviter:** Modifier le routeur pour injecter HistoryViewModel dans HistoryScreen.

---

## Runtime State Inventory

> Pas applicable — cette phase n'est pas un rename/refactor/migration.

---

## Environment Availability

| Dépendance | Requis par | Disponible | Version | Fallback |
|------------|-----------|-----------|---------|----------|
| Dart SDK | Build | ✓ | 3.12.2 | — |
| Flutter SDK | Build | ✓ | 3.44.4 | — |
| sqflite | Stockage BDD | ✓ | ^2.3.0 | — |
| get_time_ago | Timestamps relatifs | ✗ (à installer) | ^2.3.2 | Calcul manuel |

**Dépendances manquantes avec fallback:**
- `get_time_ago` — fallback: calcul manuel avec `DateTime.now().difference()`

---

## Validation Architecture

### Test Framework
| Propriété | Valeur |
|-----------|--------|
| Framework | flutter_test + mocktail |
| Fichier config | pubspec.yaml (dev_dependencies) |
| Commande rapide | `cd qr_scanner && flutter test test/viewmodels/history_viewmodel_test.dart` |
| Commande complète | `cd qr_scanner && flutter test` |

### Phase Requirements → Test Map

| Req ID | Comportement | Type Test | Commande Automatisée | Fichier Existe? |
|--------|-------------|-----------|---------------------|-----------------|
| HIST-01 | Scan persistence | unit | `flutter test test/viewmodels/scanner_viewmodel_test.dart` | ✅ (modify) |
| HIST-02 | Generation persistence | unit | `flutter test test/viewmodels/generator_viewmodel_test.dart` | ✅ (modify) |
| HIST-03 | History list display | widget | `flutter test test/screens/history_screen_test.dart` | ❌ Wave 0 |
| HIST-04 | Search and type filter | unit | `flutter test test/viewmodels/history_viewmodel_test.dart` | ❌ Wave 0 |
| UI-04 | Delete with confirmation | widget | `flutter test test/screens/history_screen_test.dart` | ❌ Wave 0 |

### Sampling Rate
- **Par commit:** `flutter test test/viewmodels/history_viewmodel_test.dart`
- **Par merge:** `flutter test` (full suite)
- **Phase gate:** Full suite green avant `/gsd-verify-work`

### Wave 0 Gaps
- [ ] `test/viewmodels/history_viewmodel_test.dart` — couvre HIST-03, HIST-04
- [ ] `test/screens/history_screen_test.dart` — couvre UI-04
- [ ] `test/models/record_base_test.dart` — vérifie l'implémentation RecordBase
- [ ] Framework install: aucun — déjà configuré

---

## Security Domain

### Applicable ASVS Categories

| Catégorie ASVS | Applicable | Standard Control |
|---------------|-----------|-----------------|
| V5 Input Validation | yes | Validation du contenu avant insertion BDD (content non vide, max 250 chars) |
| V9 Data Protection | yes | Pas de données sensibles stockées (QR content only) |

### Known Threat Patterns

| Pattern | STRIDE | Mitigation Standard |
|---------|--------|---------------------|
| SQL injection via content field | Tampering | sqflite utilise les paramètres (`?`) automatiquement |
| Storage overflow (FIFO) | Denial of Service | FIFO auto-cleanup à 100 enregistrements |
| Swipe delete without confirmation | Tampering | `confirmDismiss` avec AlertDialog obligatoire |

---

## Sources

### Primary (HIGH confidence)
- `qr_scanner/lib/services/storage_service.dart` — Analyse directe du code existant
- `qr_scanner/lib/viewmodels/scanner_viewmodel.dart` — Pattern ChangeNotifier vérifié
- `qr_scanner/lib/navigation/app_router.dart` — Pattern d'injection vérifié
- `qr_scanner/test/` — Patterns de test existants vérifiés

### Secondary (MEDIUM confidence)
- [CITED: docs.flutter.dev/cookbook/gestures/dismissible] — Pattern Dismissible standard
- [CITED: pub.dev/packages/get_time_ago] — Package timestamps relatifs FR
- [CITED: api.flutter.dev/flutter/material/AlertDialog-class.html] — Pattern AlertDialog

### Tertiary (LOW confidence)
- Aucune — toutes les affirmations sont soit vérifiées dans le codebase, soit citées depuis les docs officielles

---

## Metadata

**Confidence breakdown:**
- Standard Stack: HIGH — packages déjà installés, nouveaux packages vérifiés sur pub.dev
- Architecture: HIGH — patterns existants documentés dans le codebase
- Pitfalls: MEDIUM — basé sur patterns SQLite connus et patterns Flutter

**Research date:** 2026-06-29
**Valid until:** 2026-07-29 (30 jours — stack stable)
