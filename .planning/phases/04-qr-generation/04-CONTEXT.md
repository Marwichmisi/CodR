# Phase 4: QR Generation - Context

**Gathered:** 2026-06-28
**Status:** Ready for planning

<domain>
## Phase Boundary

Permettre à l'utilisateur de générer des QR codes à partir d'un champ texte (max 250 caractères) avec détection d'URL automatique, prévisualisation en temps réel (debounce 300ms), et sauvegarder/partager/copier le résultat. L'écran GeneratorScreen existant est un placeholder — tout le code de génération est à créer.

</domain>

<spec_lock>
## Requirements (locked via SPEC.md)

**7 requirements are locked.** See `04-SPEC.md` for full requirements, boundaries, and acceptance criteria.

Downstream agents MUST read `04-SPEC.md` before planning or implementing. Requirements are not duplicated here.

**In scope (from SPEC.md):**
- Champ texte avec compteur 250 caractères
- Rendu QR temps réel avec debounce 300ms
- Détection automatique des URLs (badge visuel)
- Sauvegarde en galerie (image PNG 300x300)
- Partage via share sheet natif
- Copie dans le presse-papiers
- SnackBar feedback pour chaque action
- Placeholder avec icône QR quand le champ est vide
- Tests de widgets pour l'écran

**Out of scope (from SPEC.md):**
- Personnalisation des couleurs QR — réservé aux exigences v2 (DIFF-03)
- Formats barcode (EAN-13, UPC) — réservé aux exigences v2 (DIFF-04)
- Batch generation (plusieurs QR en séquence) — réservé aux exigences v2 (DIFF-06)
- Cadres/borders pour les QR codes — réservé aux exigences v2 (DIFF-08)
- Import depuis galerie — scan caméra uniquement pour v1
- Authentification / comptes — app 100% offline
- Backend / serveur — tout en local

</spec_lock>

<decisions>
## Implementation Decisions

### Package QR
- **D-01:** Utiliser `qr_flutter ^5.2.0` (version v5 stable) avec le widget `QrImage` pour le rendu du QR code. Le widget prend une string et rend un QR noir et blanc en 300x300px.

### Layout de l'écran
- **D-02:** Disposition verticale en colonne: champ texte en haut, preview QR au centre (carré via `QrImage`), boutons d'action (Sauvegarder / Partager / Copier) en bas. Layout épuré et équilibré.

### Approche debounce 300ms
- **D-03:** Utiliser un `Timer` Dart classique dans le `GeneratorViewModel`. Chaque modification du texte reset le timer. Après 300ms d'inactivité, le QR se rend. Pas de dépendance externe (pas de RxDart).

### Stratégie de détection URL
- **D-04:** Détection par patterns connus: vérifier les schemes (`http://`, `https://`, `ftp://`), les préfixes `www.`, et les extensions courantes (`.com`, `.fr`, `.org`, etc.). Ajouter `https://` si aucun scheme n'est présent. Afficher un badge visuel "URL détectée".

### Permissions galerie
- **D-05:** Demander la permission galerie au clic sur le bouton "Sauvegarder" (pas au lancement). Utiliser `permission_handler` déjà installé. Si refus → SnackBar erreur. Si accord → sauvegarde l'image.

### Liaison MVVM
- **D-06:** Le `GeneratorViewModel` suit le pattern `ChangeNotifier` identique au `ScannerViewModel`: injection de dépendances via constructeur, champs privés avec getters publics, `notifyListeners()` après chaque mutation d'état.
- **D-07:** Le ViewModel gère: texte saisi, texte décodé pour le QR, état debounce (Timer), détection URL, et les 3 actions (sauvegarder, partager, copier) avec feedback SnackBar.
- **D-08:** Le Widget `GeneratorScreen` utilise `ListenableBuilder` pour s'abonner au ViewModel, avec injection via le constructeur (pas de Provider).

### Feedback utilisateur
- **D-09:** SnackBar pour chaque action: "QR sauvegardé !" (succès), "Copié !" (copie), message d'erreur en cas d'échec. SnackBar avec durée temporaire (2-3 secondes).

### the agent's Discretion
- Choisir les dimensions exactes du badge URL (taille, position, style).
- Déterminer les détails visuels du placeholder quand le champ est vide (icône, sous-titre).
- Choisir les patterns d'URL exacts à détecter parmi les courants.
- Implémenter la logique concrète de sauvegarde PNG (widget → image → fichier).
- Sélectionner la taille et la disposition exactes des boutons d'action.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Exigences et Spécifications
- `.planning/phases/04-qr-generation/04-SPEC.md` — Requirements verrouillées, boundaries, acceptance criteria, edge coverage
- `.planning/REQUIREMENTS.md` — Traçabilité des 33 requirements v1 (GEN-01 à GEN-07 pour Phase 4)
- `.planning/ROADMAP.md` — Phase 4 details, success criteria, plans
- `.planning/PROJECT.md` — Contexte projet, contraintes, key decisions

### Skills Flutter (OBLIGATOIRES)
- `.opencode/skills/flutter-apply-architecture-best-practices/SKILL.md` — Architecture MVVM, structure de dossier, workflow de feature
- `.opencode/skills/flutter-add-widget-test/SKILL.md` — Widget tests, patterns de test, examples
- `.opencode/skills/flutter-add-widget-preview/SKILL.md` — Widget previews pour les composants UI
- `.opencode/skills/flutter-build-responsive-layout/SKILL.md` — Layout responsive (LayoutBuilder, MediaQuery)
- `.opencode/skills/flutter-fix-layout-issues/SKILL.md` — Fix des erreurs de layout (overflow, etc.)

### Patterns existants
- `.planning/phases/02-camera-scanner/02-CONTEXT.md` — Décisions Phase 2 (pattern MVVM, mocking, overlay)
- `.planning/phases/01-foundation-navigation/01-CONTEXT.md` — Décisions Phase 1 (thème, navigation, structure)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `GeneratorScreen` (lib/screens/generator_screen.dart) : Widget placeholder existant avec LayoutBuilder + ConstrainedBox (max 480dp). À transformer en StatefulWidget avec ViewModel.
- `GenerationRecord` (lib/models/generation_record.dart) : Modèle avec fromJson/toJson déjà défini. Utilisable pour sauvegarder les générations en Phase 5.
- `StorageService` (lib/services/storage_service.dart) : Service SQLite avec table `generation_records` et helpers typés déjà prêts.
- `AppRouter` (lib/navigation/app_router.dart) : Router go_router avec branche `/generator` déjà configurée.
- `AppTheme` (lib/theme/app_theme.dart) : Thème Material 3 à utiliser pour les couleurs et styles.
- `ScannerViewModel` (lib/viewmodels/scanner_viewmodel.dart) : Pattern ChangeNotifier à reproduire pour GeneratorViewModel.
- `permission_handler` (pubspec.yaml) : Package déjà installé, réutiliser pour les permissions galerie.
- `share_plus` et `path_provider` : **À AJOUTER** au pubspec.yaml (pas encore installés).

### Established Patterns
- Architecture MVVM : ViewModels extend ChangeNotifier, Widgets utilisent ListenableBuilder
- Injection de dépendances : via constructeur avec named parameters, mocks passés en test
- Naming : `*_viewmodel.dart`, `*_screen.dart`, `*_service.dart`
- Tests : mocktail pour les mocks, `testWidgets()` pour tous les tests, `pumpAndSettle()` après async
- Responsive : LayoutBuilder wrapping body, max 480dp pour écrans larges

### Integration Points
- `GeneratorScreen` dans `qr_scanner/lib/screens/generator_screen.dart` : à modifier pour intégrer le ViewModel et la logique QR
- `app_router.dart` : branche `/generator` existante, instancie `GeneratorScreen()` directement (injection à prévoir)
- `pubspec.yaml` : ajouter `qr_flutter ^5.2.0`, `image_gallery_saver`, `share_plus`

</code_context>

<specifics>
## Specific Ideas

- Projet 100% hors-ligne, tout en local.
- L'usage des skills Flutter locaux est OBLIGATOIRE pour guider le développement (architecture, tests, responsive, layout fixes).
- Les UI texts sont en français.
- Style minimaliste et épuré (beaucoup d'espace blanc, interface sobre).

</specifics>

<deferred>
## Deferred Ideas

- Personnalisation des couleurs QR — v2 (DIFF-03)
- Formats barcode (EAN-13, UPC) — v2 (DIFF-04)
- Batch generation (plusieurs QR en séquence) — v2 (DIFF-06)
- Cadres/borders pour les QR codes — v2 (DIFF-08)
- Import depuis galerie — v2 (DIFF-05)
- Sauvegarde automatique des QR dans l'historique — Phase 5

</deferred>

---

*Phase: 04-qr-generation*
*Context gathered: 2026-06-28*
