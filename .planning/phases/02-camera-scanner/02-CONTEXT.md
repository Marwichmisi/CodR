# Phase 2: Camera Scanner - Context

**Gathered:** 28 juin 2026
**Status:** Ready for planning

<domain>
## Phase Boundary

Permettre à l'utilisateur de scanner des codes QR en temps réel via la caméra de son appareil avec une gestion robuste des permissions, du cycle de vie du contrôleur de caméra et une prévention des détections multiples.

</domain>

<spec_lock>
## Requirements (locked via SPEC.md)

**7 requirements are locked.** See `02-SPEC.md` for full requirements, boundaries, and acceptance criteria.

Downstream agents MUST read `02-SPEC.md` before planning or implementing. Requirements are not duplicated here.

**In scope (from SPEC.md):**
- Intégration du package `mobile_scanner` et du widget de prévisualisation.
- Demande et gestion réactive des permissions avec redirection vers les paramètres système.
- Affichage de l'overlay de guidage de scan (responsive).
- Toggle de la lampe de poche via un bouton flottant superposé.
- Gestion du cycle de vie du contrôleur via le widget et l'application (arrière-plan).
- Vibration et debounce de 2 secondes lors du scan réussi.
- Affichage temporaire du texte scanné sur l'écran du scanner (en attente de la phase de résultats).

**Out of scope (from SPEC.md):**
- Redirection vers l'écran complet de résultats — *reporté à la Phase 3*.
- Enregistrement des scans dans la base de données locale SQLite — *reporté à la Phase 5*.
- Scan à partir d'une image de la galerie — *reporté à la v2 (DIFF-05)*.
- Prise en charge des formats de codes-barres autres que les QR codes — *reporté à la v2 (DIFF-04)*.

</spec_lock>

<decisions>
## Implementation Decisions

### Liaison MVVM et gestion d'état
- **D-01:** Le Widget gère le `MobileScannerController` en interne dans un `StatefulWidget` (cycle de vie, initialisation et libération) et notifie le ViewModel des détections.
- **D-02:** Le ViewModel expose un état réactif de permission caméra via un `PermissionService` abstrait. Le Widget s'abonne à cet état pour se reconstruire (affichage caméra ou écran d'erreur).
- **D-03:** La logique de debounce/limitation de 2 secondes pour éviter les détections multiples (SCAN-06) s'exécute dans le ViewModel en ignorant temporairement les scans successifs à l'aide d'un état de chargement/verrou.
- **D-04:** Le retour haptique (vibration) est déclenché par l'UI (le Widget) en réponse à un changement d'état ou événement de détection réussie notifié par le ViewModel.

### Rendu de l'overlay de guidage
- **D-05:** Le calque d'assombrissement semi-transparent percé au centre est dessiné avec un `CustomPainter` utilisant `PathOperation.difference` pour un rendu net et performant.
- **D-06:** Les coins épais matérialisant les angles de la zone de guidage sont tracés directement dans le même `CustomPainter`.
- **D-07:** La taille du carré de visée est dynamique et s'adapte à l'écran (responsivité) en prenant 70% de la largeur disponible, contraint par un minimum de 200dp et un maximum de 320dp.
- **D-08:** Aucune animation de balayage laser n'est ajoutée au centre du guide de scan afin de respecter la consigne de sobriété et de minimalisme de l'interface.

### Affichage temporaire du QR Code scanné
- **D-09:** Le texte scanné est affiché temporairement via une `SnackBar` standard en bas de l'écran avec un bouton pour la fermer manuellement.
- **D-10:** Si un nouveau scan intervient alors qu'une SnackBar est déjà visible, celle-ci est immédiatement fermée et remplacée par la nouvelle pour un retour visuel instantané.
- **D-11:** Si le texte détecté correspond à une URL, un bouton d'action "Ouvrir" (pré-câblé pour l'UI, même si le comportement d'ouverture complet sera géré en Phase 3) est affiché dans la `SnackBar`.

### Stratégie de tests de widgets et mocking
- **D-12:** Le mocking de la caméra pour les Widget Tests utilise l'injection d'un contrôleur ou service mocké (`MobileScannerController` ou wrapper) via le constructeur de l'écran ou le gestionnaire d'état.
- **D-13:** La détection du code QR dans les tests est simulée en appelant manuellement le callback `onDetect` du widget ou via le mock du contrôleur.
- **D-14:** Le test de redirection vers les paramètres système consiste à mocker le `PermissionService` (pour renvoyer un statut définitivement refusé), à simuler le clic sur le bouton d'erreur de permission et à vérifier l'appel de `openAppSettings()` via un mock Mocktail.

### the agent's Discretion
- Choisir les dimensions précises et marges des boutons de contrôle (ex: lampe de poche).
- Déterminer les détails de style de la SnackBar et du bouton d'erreur (couleurs, rayons d'angles).
- Mettre en œuvre l'implémentation concrète de `PermissionService` et son enregistrement dans les dépendances.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Exigences et Spécifications
- `.planning/phases/02-camera-scanner/02-SPEC.md` — Spécifications, cas limites et prohibitions de la Phase 02
- `.planning/REQUIREMENTS.md` — Traçabilité des exigences du projet v1
- `.planning/ROADMAP.md` — Roadmap globale du projet et critères de succès

### Skills Flutter (OBLIGATOIRES)
- `.agents/skills/flutter-apply-architecture-best-practices/SKILL.md` — Bonnes pratiques d'architecture MVVM et structure de dossier
- `.agents/skills/flutter-add-widget-test/SKILL.md` — Écriture des tests unitaires et widget tests sous Flutter
- `.agents/skills/flutter-add-widget-preview/SKILL.md` — Système de preview pour les widgets Flutter
- `.agents/skills/flutter-build-responsive-layout/SKILL.md` — Création de layouts réactifs (MediaQuery, LayoutBuilder)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- [AppTheme](file:///home/marwane/Documents/CodR/qr_scanner/lib/theme/app_theme.dart) : Thème Material 3 configuré à la Phase 1 à utiliser pour l'écran de scan et l'affichage d'erreur.
- [AppRouter](file:///home/marwane/Documents/CodR/qr_scanner/lib/navigation/app_router.dart) : Router existant configuré avec `go_router` où l'écran `ScannerScreen` est déjà branché sur l'onglet de démarrage.

### Established Patterns
- Architecture MVVM : Les écrans sont connectés à des ViewModels héritant de `ChangeNotifier` et reconstruits via `ListenableBuilder` (ou similaire).
- Widget Previews : Utilisation de l'annotation `@Preview` pour exposer les composants dans previews.dart.

### Integration Points
- `ScannerScreen` existant dans `qr_scanner/lib/screens/scanner_screen.dart` à modifier pour intégrer la caméra et les états.

</code_context>

<specifics>
## Specific Ideas

- Projet 100% hors-ligne, tout en local.
- L'usage des skills Flutter locaux est obligatoire pour guider le développement de haute qualité.

</specifics>

<deferred>
## Deferred Ideas

- Redirection vers l'écran de résultats complet — *prévue pour la Phase 3*.
- Enregistrement des codes scannés dans la base SQLite locale — *prévue pour la Phase 5*.
- Scan d'un QR code depuis une image de la galerie — *prévue pour la v2*.

</deferred>

---

*Phase: 02-camera-scanner*
*Context gathered: 28 juin 2026*
