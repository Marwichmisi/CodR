# Phase 1: Foundation & Navigation - Context

**Gathered:** 2026-06-27
**Status:** Ready for planning

<domain>
## Phase Boundary

Créer un projet Flutter from scratch avec architecture MVVM, thème Material 3, navigation bottom nav entre 3 écrans (Scanner, Generator, History), et fondation SQLite pour les phases suivantes. Aucun code Flutter n'existe aujourd'hui — c'est un projet vert.

</domain>

<spec_lock>
## Requirements (locked via SPEC.md)

**8 requirements are locked.** See `01-SPEC.md` for full requirements, boundaries, and acceptance criteria.

Downstream agents MUST read `01-SPEC.md` before planning or implementing. Requirements are not duplicated here.

**In scope (from SPEC.md):**
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

**Out of scope (from SPEC.md):**
- Camera/scanner functionality — Phase 2
- QR code generation — Phase 4
- History list UI with search/filter — Phase 5
- Actual QR scanning overlay — Phase 2
- Share/copy functionality — Phase 3/4
- Error handling for camera permissions — Phase 2
- Unit tests for ViewModels (no ViewModels yet) — Phase 3

</spec_lock>

<decisions>
## Implementation Decisions

### Thème & Identité Visuelle
- **D-01:** Couleurs seed = bleu ciel + vert (pas de dégradé/gradiant)
- **D-02:** Mode clair uniquement (pas de dark mode pour l'instant)
- **D-03:** Police = Inter (moderne, lisible, via Google Fonts)
- **D-04:** Style = minimaliste / épuré (beaucoup d'espace blanc, interface sobre)

### Stratégie de Navigation
- **D-05:** go_router déclaratif (skill flutter-setup-declarative-routing disponible)
- **D-06:** Retour Android = retour au 1er onglet (Scanner)
- **D-07:** Toujours Scanner au lancement (pas de persistence de l'onglet sélectionné)
- **D-08:** Comportement back = retour au 1er onglet

### Structure des Placeholders
- **D-09:** Icônes Material standards (Icons.camera_alt, Icons.qr_code, Icons.history)
- **D-10:** Contenu minimal = titre + icône centrale représentative
- **D-11:** AppBar sur chaque écran (Scanner, Generator, History)
- **D-12:** Couleur onglet actif = seed color (teinte principale du thème)

### Organisation des Tests
- **D-13:** Même structure que lib/ → test/models/, test/viewmodels/, test/services/, test/screens/
- **D-14:** Tous les types de tests en même temps (modèles + storage + navigation)
- **D-15:** Niveau de couverture = intermédiaire (edge cases inclus : erreurs SQLite, serialisation JSON)
- **D-16:** Style de nommage = `testWidgets('description comportementale', ...)` avec `group()` (selon skill flutter-add-widget-test)

### Discretion de l'agent
- Choisir les noms d'icônes exactes selon les standards Material 3
- Choisir la teinte exacte de bleu ciel + vert qui fonctionne bien ensemble
- Organiser les sous-dossiers de tests selon les conventions Flutter standard

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Exigences & Spécification
- `.planning/phases/01-foundation-navigation/01-SPEC.md` — Requirements verrouillées, boundaries, acceptance criteria
- `.planning/REQUIREMENTS.md` — 33 requirements v1 avec traceability par phase
- `.planning/ROADMAP.md` — 5 phases du projet, success criteria par phase
- `.planning/PROJECT.md` — Contexte projet, contraintes, key decisions

### Skills Flutter (OBLIGATOIRES)
- `.opencode/skills/flutter-apply-architecture-best-practices/SKILL.md` — Architecture MVVM, structure de projet, workflow de feature
- `.opencode/skills/flutter-add-widget-test/SKILL.md` — Widget tests, patterns de test, examples
- `.opencode/skills/flutter-add-widget-preview/SKILL.md` — Widget previews pour les composants UI
- `.opencode/skills/flutter-build-responsive-layout/SKILL.md` — Layout responsive (LayoutBuilder, MediaQuery)
- `.opencode/skills/flutter-setup-declarative-routing/SKILL.md` — Navigation déclarative avec go_router
- `.opencode/skills/flutter-setup-localization/SKILL.md` — Localisation (si nécessaire)
- `.opencode/skills/flutter-fix-layout-issues/SKILL.md` — Fix des erreurs de layout (overflow, etc.)

### Références Techniques
- `.planning/codebase/ARCHITECTURE.md` — Architecture du système de build/tools
- `.planning/codebase/CONVENTIONS.md` — Conventions de code du projet

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- Aucun — projet vert, pas de code Flutter existant

### Established Patterns
- Architecture MVVM recommandée par le skill flutter-apply-architecture-best-practices
- Structure: data/ (models, repositories, services), domain/ (models, use_cases), ui/ (core, features)
- ViewModels extend ChangeNotifier, Views utilisent ListenableBuilder

### Integration Points
- Pas d'intégration existante — tout est à créer from scratch
- Les futures phases (2-5) viendront se connecter à cette fondation

</code_context>

<specifics>
## Specific Ideas

- App 100% offline, tout en local
- Projet d'apprentissage et défi entre camarades
- Le scan utilise la caméra de l'appareil (Phase 2)
- La génération produit des images QR standard (Phase 4)
- Max 250 caractères pour le champ de texte de génération

</specifics>

<deferred>
## Deferred Ideas

- Mode sombre avec détection automatique (DIFF-01 — v2)
- Presets de types QR (URL, texte, email) (DIFF-02 — v2)
- Couleurs personnalisées pour les QR codes (DIFF-03 — v2)
- QR codes WiFi, contacts, vCards (hors scope v1)
- Backend / serveur (app 100% offline)
- Authentification / comptes utilisateurs (projet perso, pas besoin)

</deferred>

---

*Phase: 01-foundation-navigation*
*Context gathered: 2026-06-27*
