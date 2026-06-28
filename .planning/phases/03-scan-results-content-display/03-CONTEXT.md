# Phase 3: Scan Results & Content Display - Context

**Gathered:** 2026-06-28
**Status:** Ready for planning

> [!IMPORTANT]
> **DIRECTIVE OBLIGATOIRE POUR L'AGENT DÉVELOPPEUR :**
> L'usage des **skills Flutter locaux** installés sur la machine est **STRICTEMENT OBLIGATOIRE** pour tout le développement et la validation de cette phase.
> L'agent développeur doit s'y référer pour appliquer les bonnes pratiques, structurer le code sans se perdre, et produire du code qualitatif :
> - [flutter-apply-architecture-best-practices](file:///home/marwane/Documents/CodR/.agents/skills/flutter-apply-architecture-best-practices/SKILL.md) : Pour l'architecture MVVM du `ResultViewModel` et des composants associés.
> - [flutter-add-widget-test](file:///home/marwane/Documents/CodR/.agents/skills/flutter-add-widget-test/SKILL.md) : Pour l'écriture des tests unitaires et widget tests.
> - [flutter-add-widget-preview](file:///home/marwane/Documents/CodR/.agents/skills/flutter-add-widget-preview/SKILL.md) : Pour la mise en place de previews de widgets du Bottom Sheet.
> - [flutter-build-responsive-layout](file:///home/marwane/Documents/CodR/.agents/skills/flutter-build-responsive-layout/SKILL.md) : Pour s'assurer que le Bottom Sheet s'affiche correctement sur tablette et mobile.
> - [flutter-fix-layout-issues](file:///home/marwane/Documents/CodR/.agents/skills/flutter-fix-layout-issues/SKILL.md) : En cas de problèmes de contraintes ou d'overflow.

<domain>
## Phase Boundary

Afficher le contenu d'un QR code scanné dans un bottom sheet Material 3 avec des actions contextuelles (Copier, Partager, Ouvrir URL, Envoyer e-mail, Appeler) et gérer proprement le cycle de vie de la caméra (pause/reprise) pendant que le bottom sheet est ouvert, avec un traitement MVVM et des tests unitaires associés.

</domain>

<spec_lock>
## Requirements (locked via SPEC.md)

**9 requirements are locked.** See `03-SPEC.md` for full requirements, boundaries, and acceptance criteria.

Downstream agents MUST read `03-SPEC.md` before planning or implementing. Requirements are not duplicated here.

**In scope (from SPEC.md):**
- Bottom sheet Material 3 avec contenu scanné et boutons d'action
- Détection de type de contenu : URL (http/https), email, téléphone
- Priorité de détection : URL > email > téléphone (un seul bouton contextuel)
- Actions : Copier (Clipboard), Partager (share_plus), Ouvrir URL (url_launcher), Envoyer mail (mailto:), Appeler (tel:)
- Gestion d'erreur pour contenu vide/invalide avec retry
- Pause/reprise caméra synchronisée avec le bottom sheet
- ResultViewModel avec tests unitaires
- Ajout des dépendances `url_launcher` et `share_plus` dans pubspec.yaml

**Out of scope (from SPEC.md):**
- Sauvegarde du scan en historique SQLite — Phase 5
- Écran de résultat dédié plein écran — le bottom sheet suffit pour v1
- Personnalisation du thème du bottom sheet — utilise le thème Material 3 existant de l'app
- Gestion des formats barcode non-QR (EAN-13, UPC) — fonctionnalité v2
- Scan depuis galerie/images — fonctionnalité v2
- QR codes WiFi, vCards, contacts — hors scope v1

</spec_lock>

<decisions>
## Implementation Decisions

### Conception UI du Bottom Sheet
- **D-01 :** Les boutons d'action principaux (Copier, Partager, action contextuelle) sont disposés sur une ligne horizontale (icône + texte court) pour un rendu moderne et compact.
- **D-02 :** Le contenu brut scanné est affiché dans un conteneur scrollable avec une hauteur maximale de 150dp à 200dp pour éviter de masquer tout l'écran.
- **D-03 :** Pour la responsivité tablette / grand écran, le bottom sheet sera centré avec une largeur maximale contrainte de 500dp.
- **D-04 :** Utilisation de la poignée de glissement Material 3 standard (`showDragHandle: true`) en haut du sheet pour indiquer la fermeture par glissement.

### Détection de types & Regex
- **D-05 :** Détection stricte uniquement des URLs absolues commençant par "http://" ou "https://" pour éviter tout comportement dangereux.
- **D-06 :** Validation des adresses e-mail via regex standardisée (`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`).
- **D-07 :** Validation des numéros de téléphone via une regex souple acceptant le format international (commençant par "+") et le format national (de 9 à 14 chiffres, acceptant espaces/tirets/parenthèses).
- **D-08 :** Les textes mixtes (ex: "Mon site: https://flutter.dev") sont traités entièrement comme texte brut. Le bouton contextuel n'apparaît que si le contenu nettoyé (trim) correspond à 100% à une URL/email/téléphone pur.

### Pause/Reprise de la caméra
- **D-09 :** Appel immédiat de `_controller.stop()` à l'ouverture du bottom sheet pour figer le flux et économiser les ressources.
- **D-10 :** Utilisation du callback `whenComplete` de `showModalBottomSheet()` pour appeler systématiquement `_controller.start()` peu importe le mode de fermeture.
- **D-11 :** Gestion des exceptions silencieusement et vérification de `_controller.isInitialized` avant tout appel de `start()` ou `stop()`.
- **D-12 :** Conserver ou réactiver un verrou court (debounce) de 1 à 2 secondes après fermeture du bottom sheet pour laisser le temps d'éloigner l'appareil.

### Gestion d'erreur & Retry
- **D-13 :** Le bottom sheet présente un design d'erreur dédié : icône d'avertissement rouge, message d'erreur explicite ("Code QR vide ou invalide"), et les boutons "Réessayer" et "Fermer".
- **D-14 :** Le bouton "Réessayer" ferme le bottom sheet d'erreur et relance immédiatement le scan de la caméra.
- **D-15 :** Les contenus scannés ne contenant que des espaces (ex: "   ") sont considérés comme invalides (après trim) et déclenchent l'UI d'erreur.
- **D-16 :** Les options "Copier" et "Partager" sont masquées ou désactivées en cas d'erreur de contenu.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Exigences et Spécifications
- `.planning/phases/03-scan-results-content-display/03-SPEC.md` — Spécifications, cas limites et prohibitions de la Phase 03
- `.planning/REQUIREMENTS.md` — Traçabilité des exigences du projet v1
- `.planning/ROADMAP.md` — Roadmap globale du projet et critères de succès

### Skills Flutter (OBLIGATOIRES)
- `.agents/skills/flutter-apply-architecture-best-practices/SKILL.md` — Bonnes pratiques d'architecture MVVM et structure de dossier
- `.agents/skills/flutter-add-widget-test/SKILL.md` — Écriture des tests unitaires et widget tests sous Flutter
- `.agents/skills/flutter-add-widget-preview/SKILL.md` — Système de preview pour les widgets Flutter
- `.agents/skills/flutter-build-responsive-layout/SKILL.md` — Création de layouts réactifs (MediaQuery, LayoutBuilder)
- `.agents/skills/flutter-fix-layout-issues/SKILL.md` — Fix des erreurs de layout (overflow, etc.)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- [AppTheme](file:///home/marwane/Documents/CodR/qr_scanner/lib/theme/app_theme.dart) : Thème Material 3 configuré à la Phase 1 pour le bottom sheet.
- [PermissionService](file:///home/marwane/Documents/CodR/qr_scanner/lib/services/permission_service.dart) : Service de permission caméra réutilisé.

### Established Patterns
- Architecture MVVM : Les ViewModels étendent `ChangeNotifier`, les widgets écoutent via `ListenableBuilder`.
- Widget Previews : Utilisation de l'annotation `@Preview` pour exposer les composants dans previews.dart.

### Integration Points
- `ScannerScreen` ([scanner_screen.dart](file:///home/marwane/Documents/CodR/qr_scanner/lib/screens/scanner_screen.dart)) : Modifier pour afficher le bottom sheet et lier le cycle de vie de la caméra.
- `ScannerViewModel` ([scanner_viewmodel.dart](file:///home/marwane/Documents/CodR/qr_scanner/lib/viewmodels/scanner_viewmodel.dart)) : Coexister ou s'interfacer avec le nouveau `ResultViewModel`.

</code_context>

<specifics>
## Specific Ideas

- Projet 100% hors-ligne, tout en local.
- L'usage des skills Flutter locaux est strictement obligatoire pour guider le développement de haute qualité.

</specifics>

<deferred>
## Deferred Ideas

- Sauvegarde du scan en historique SQLite — Phase 5
- Écran de résultat dédié plein écran — le bottom sheet suffit pour v1
- Personnalisation du thème du bottom sheet — utilise le thème Material 3 existant de l'app
- Gestion des formats barcode non-QR (EAN-13, UPC) — fonctionnalité v2
- Scan depuis galerie/images — fonctionnalité v2
- QR codes WiFi, vCards, contacts — hors scope v1

</deferred>

---

*Phase: 03-scan-results-content-display*
*Context gathered: 2026-06-28*
