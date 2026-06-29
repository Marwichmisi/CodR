# Phase 5: History & Data Persistence - Context

**Gathered:** 2026-06-29
**Status:** Ready for planning

<domain>
## Phase Boundary

Câbler `StorageService` aux écrans Scanner et Generator (insertion après action utilisateur), créer `HistoryViewModel` avec liste, recherche, filtre par type et suppression par swipe, reconstruire `HistoryScreen` comme `StatefulWidget` avec une liste de 100 entrées max (FIFO auto-cleanup). L'écran History actuel est un placeholder statique (icône + titre) — tout est à créer.

</domain>

<spec_lock>
## Requirements (locked via SPEC.md)

**5 requirements are locked.** See `05-SPEC.md` for full requirements, boundaries, and acceptance criteria.

Downstream agents MUST read `05-SPEC.md` before planning or implementing. Requirements are not duplicated here.

**In scope (from SPEC.md):**
- Wiring `StorageService` into `ScannerViewModel` and `GeneratorViewModel` (insert on user action)
- Creating `HistoryViewModel` with list loading, search, filter, and delete methods
- Rebuilding `HistoryScreen` as `StatefulWidget` with list, search bar, type filter, swipe-to-delete
- FIFO auto-cleanup when inserting the 101st record
- Injection of `StorageService` through `createAppRouter()` to all ViewModels

**Out of scope (from SPEC.md):**
- Push notifications for new history entries — not requested for v1
- Export history to CSV/file — listed as DIFF-07 in v2 backlog
- Pagination/infinite scroll — 100 entries max fits in a single scrollable list
- Batch delete (select multiple then delete) — single swipe delete only
- History detail screen (tap to view full content) — content is short enough for preview

</spec_lock>

<decisions>
## Implementation Decisions

### Unification des types d'enregistrements
- **D-01:** Créer une classe abstraite `RecordBase` dans un nouveau fichier `lib/models/record_base.dart` avec les champs communs : `id` (int), `content` (String), `timestamp` (DateTime), `type` (String). `ScanRecord` et `GenerationRecord` étendent cette classe.
- **D-02:** La factory `RecordBase.fromJson()` doit détecter automatiquement le type (scan/generation) à partir du champ 'type' et retourner la bonne sous-classe. (L'agent décide du pattern exact — factory polymorphique ou chargement séparé + fusion en mémoire).
- **D-03:** Ajouter une nouvelle méthode `getHistory()` dans `StorageService` qui charge les deux tables (`scan_records` + `generation_records`), les fusionne et retourne `List<RecordBase>` triée par `timestamp DESC`.

### Stratégie FIFO 100 entrées
- **D-04:** La logique FIFO est implémentée dans les deux couches : `HistoryViewModel` vérifie le count après chaque insertion et demande à `StorageService` de supprimer le plus ancien si > 100.
- **D-05:** La limite de 100 s'applique **séparément par type** : max 100 scans ET max 100 générations indépendamment. (L'agent décide selon l'usage attendu — séparément ou ensemble).
- **D-06:** La suppression FIFO est **silencieuse** — pas de notification SnackBar. L'utilisateur voit simplement la liste qui reste à 100 entrées.
- **D-07:** La vérification FIFO se fait **uniquement à l'insertion** d'un nouvel enregistrement, pas au démarrage de l'app.

### Injection de StorageService
- **D-08:** `StorageService` est créé dans `main.dart` et passé à `createAppRouter()` comme paramètre optionnel avec défaut `null` (crée un `SystemStorageService` si non fourni). Même pattern que `PermissionService` existant.
- **D-09:** `createAppRouter()` signature : `createAppRouter({PermissionService? permissionService, StorageService? storageService, MobileScannerController? mockController})`.
- **D-10:** `ScannerViewModel` et `GeneratorViewModel` reçoivent `StorageService` via le constructeur (named parameter) pour appeler `insertScanRecord()` / `insertGenerationRecord()` quand l'utilisateur tape copier/partager/sauvegarder.
- **D-11:** `HistoryViewModel` reçoit `StorageService` via le constructeur — même pattern que les autres ViewModels.
- **D-12:** Le `StorageService` est injecté dans `HistoryScreen` via `createAppRouter()` qui crée le `HistoryViewModel` avec le service.

### Disposition des éléments de liste
- **D-13:** Chaque entrée est affichée dans une `Card` contenant un `ListTile` : icône type (scan: `Icons.qr_code_scanner`, génération: `Icons.qr_code`) à gauche, aperçu contenu au centre (max 1 line, ellipsis), timestamp relatif ("il y a X min", "hier") à droite.
- **D-14:** Le contenu est tronqué à `maxLines: 1` avec ellipsis — un seul aperçu ligne suffisant pour un QR code.
- **D-15:** Le timestamp utilise un format **relatif** : "il y a X min/h/j" pour les entrées récentes, date complète pour les plus anciennes.
- **D-16:** Le swipe-to-delete utilise le widget `Dismissible` natif de Flutter avec un fond rouge et une icône poubelle. Un `AlertDialog` de confirmation apparaît avant la suppression effective.

### the agent's Discretion
- Le pattern exact de la factory `RecordBase.fromJson` (polymorphique vs chargement séparé + fusion).
- La limite FIFO séparée ou ensemble par type.
- Les détails visuels de la Card (ombre, bordure, padding exact).
- Le seuil de transition du timestamp relatif vers la date complète.
- Le style exact du `AlertDialog` de confirmation (icône, couleurs, boutons).
- Les patterns d'URL et de contenu à afficher dans l'aperçu de la liste.
- L'implémentation concrète du nettoyage FIFO dans StorageService.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Exigences et Spécifications
- `.planning/phases/05-history-data-persistence/05-SPEC.md` — Requirements verrouillées, boundaries, acceptance criteria, edge coverage
- `.planning/REQUIREMENTS.md` — Traçabilité des 33 requirements v1 (HIST-01 à HIST-04, UI-04 pour Phase 5)
- `.planning/ROADMAP.md` — Phase 5 details, success criteria, plans
- `.planning/PROJECT.md` — Contexte projet, contraintes, key decisions

### Skills Flutter (OBLIGATOIRES)
- `.opencode/skills/flutter-apply-architecture-best-practices/SKILL.md` — Architecture MVVM, structure de dossier, workflow de feature
- `.opencode/skills/flutter-add-widget-test/SKILL.md` — Widget tests, patterns de test, examples
- `.opencode/skills/flutter-add-widget-preview/SKILL.md` — Widget previews pour les composants UI
- `.opencode/skills/flutter-build-responsive-layout/SKILL.md` — Layout responsive (LayoutBuilder, MediaQuery)
- `.opencode/skills/flutter-fix-layout-issues/SKILL.md` — Fix des erreurs de layout (overflow, etc.)

### Patterns existants
- `.planning/phases/04-qr-generation/04-CONTEXT.md` — Décisions Phase 4 (MVVM, debounce, SnackBar, injection)
- `.planning/phases/03-scan-results-content-display/03-CONTEXT.md` — Décisions Phase 3 (bottom sheet, caméra lifecycle)
- `.planning/phases/02-camera-scanner/02-CONTEXT.md` — Décisions Phase 2 (pattern MVVM, overlay, anti-rebond)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `StorageService` (lib/services/storage_service.dart) : Service SQLite complet avec `insertScanRecord`, `insertGenerationRecord`, `getAllScanRecords`, `getAllGenerationRecords`, `delete`. Tables `scan_records` et `generation_records` déjà créées.
- `ScanRecord` (lib/models/scan_record.dart) : Modèle avec `fromJson`/`toJson`. Champs : id, content, timestamp, type.
- `GenerationRecord` (lib/models/generation_record.dart) : Même structure que ScanRecord. Les deux modèles sont identiques — parfait pour une classe de base commune.
- `HistoryScreen` (lib/screens/history_screen.dart) : Widget placeholder existant avec `LayoutBuilder` + `ConstrainedBox` (max 480dp). À transformer en StatefulWidget avec ViewModel.
- `AppRouter` (lib/navigation/app_router.dart) : Router go_router avec branche `/history` déjà configurée, instancie `HistoryScreen()` sans injection.
- `ScannerViewModel` (lib/viewmodels/scanner_viewmodel.dart) : Pattern ChangeNotifier avec injection PermissionService. Modèle à reproduire pour HistoryViewModel.
- `GeneratorViewModel` (lib/viewmodels/generator_viewmodel.dart) : Même pattern, gère debounce et actions utilisateur.

### Established Patterns
- Architecture MVVM : ViewModels extend `ChangeNotifier`, Widgets écoutent via `ListenableBuilder`
- Injection de dépendances : via constructeur avec named parameters, mocks passés en test
- Naming : `*_viewmodel.dart`, `*_screen.dart`, `*_service.dart`
- Tests : mocktail pour les mocks, `testWidgets()` pour tous les tests, `pumpAndSettle()` après async
- Responsive : LayoutBuilder wrapping body, max 480dp pour écrans larges
- Feedback : SnackBar pour les retours utilisateur
- Styles : Material 3, thème cohérent via AppTheme

### Integration Points
- `ScannerScreen` (lib/screens/scanner_screen.dart) : Modifier pour injecter StorageService au ResultViewModel ou ScannerViewModel, appeler insertScanRecord() après action utilisateur dans le bottom sheet.
- `GeneratorScreen` (lib/screens/generator_screen.dart) : Modifier pour injecter StorageService au GeneratorViewModel, appeler insertGenerationRecord() après save/share/copy.
- `app_router.dart` : Modifier `createAppRouter()` pour prendre `StorageService?` et le passer aux ViewModels. Modifier la branche `/history` pour injecter HistoryViewModel avec StorageService.
- `ScannerViewModel` (lib/viewmodels/scanner_viewmodel.dart) : Ajouter StorageService comme dépendance, ajouter méthode pour insérer après action.
- `GeneratorViewModel` (lib/viewmodels/generator_viewmodel.dart) : Même modification — ajouter StorageService et logique d'insertion.

</code_context>

<specifics>
## Specific Ideas

- Projet 100% hors-ligne, tout en local.
- L'usage des skills Flutter locaux est **OBLIGATOIRE** pour guider le développement (architecture, tests, responsive, layout fixes).
- Les UI texts sont en français.
- Style minimaliste et épuré (beaucoup d'espace blanc, interface sobre).
- La classe de base `RecordBase` doit être dans un fichier séparé `lib/models/record_base.dart`.
- Le timestamp relatif est un must — "il y a 5 min" est plus naturel qu'une date complète.

</specifics>

<deferred>
## Deferred Ideas

- Export historique en CSV — v2 (DIFF-07)
- Push notifications pour nouveaux entrées historique — pas demandé pour v1
- Pagination/infinite scroll — 100 entrées max tient dans une liste scrollable
- Batch delete (sélection multiple) — suppression par swipe simple uniquement
- Écran détail historique (tap pour voir contenu complet) — contenu suffisamment court pour l'aperçu

</deferred>

---

*Phase: 05-history-data-persistence*
*Context gathered: 2026-06-29*
