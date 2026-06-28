# Phase 3: Scan Results & Content Display — Specification

**Created:** 2026-06-28
**Ambiguity score:** 0.14 (gate: ≤ 0.20)
**Requirements:** 9 locked

> **⚠️ DIRECTIVE OBLIGATOIRE POUR L'AGENT DÉVELOPPEUR :**
> L'utilisation des **skills Flutter installés localement** est **OBLIGATOIRE** pour tout le développement de cette phase. Les skills suivants DOIVENT être consultés et appliqués :
> - `flutter-apply-architecture-best-practices` — pour la structure MVVM du ResultViewModel
> - `flutter-add-widget-test` — pour les tests de widgets du bottom sheet
> - `flutter-add-widget-preview` — pour les previews interactives du bottom sheet
> - `flutter-build-responsive-layout` — pour l'adaptation responsive du bottom sheet
> - `flutter-implement-json-serialization` — pour la sérialisation si nécessaire
> - `flutter-fix-layout-issues` — en cas de problèmes de layout
>
> **Ne pas improviser les patterns d'architecture ou de test** — toujours se référer aux skills pour les bonnes pratiques.

## Goal

Quand un QR code est scanné, un bottom sheet Material 3 glisse depuis le bas avec le contenu scanné, des boutons d'action contextuels (Copier, Partager, et une action spécifique au type de contenu détecté), et la caméra se met en pause pendant que le bottom sheet est ouvert.

## Background

La Phase 2 a implémenté le scan QR avec détection en temps réel, anti-rebond, et gestion du cycle de vie caméra. Actuellement :
- `ScannerViewModel.handleQrCodeDetected(code)` accepte le scan et retourne `true`, mais ne fait rien avec le contenu
- `ScannerScreen._showScanResult()` affiche une SnackBar basique avec le texte et un placeholder "Ouvrir le lien" vide (ligne 262 : `// Action pré-câblée (sera gérée en Phase 3)`)
- La détection URL existe déjà via `Uri.tryParse(content)?.isAbsolute` (ligne 253) mais aucune action n'est déclenchée
- Aucun `ResultViewModel` n'existe
- Aucun bottom sheet de résultat n'existe
- Les packages `url_launcher` et `share_plus` ne sont pas dans `pubspec.yaml`
- Le modèle `ScanRecord` existe mais n'est pas utilisé en dehors des tests

## Requirements

1. **Bottom sheet de résultat** : Après un scan réussi, un bottom sheet Material 3 s'affiche avec le contenu scanné et les boutons d'action.
   - Current: Une SnackBar basique affiche le texte scanné sans actions fonctionnelles
   - Target: Un bottom sheet glisse depuis le bas, affiche le contenu scanné avec son type détecté, et propose les boutons Copier (toujours visible), Partager (toujours visible), et un bouton d'action contextuelle (visible uniquement si URL, email ou téléphone détecté)
   - Acceptance: Le bottom sheet s'affiche après un scan avec le contenu correct ; les boutons Copier et Partager sont visibles pour tout contenu ; le bouton contextuel n'apparaît que pour les contenus typés

2. **Détection d'URL** : Les URLs absolues (http/https) sont identifiées dans le contenu scanné et l'utilisateur peut les ouvrir dans le navigateur système.
   - Current: `Uri.tryParse(content)?.isAbsolute` existe dans `_showScanResult()` mais l'action est un placeholder vide
   - Target: Les URLs http/https sont détectées, un bouton "Ouvrir" apparaît, et un tap lance `url_launcher` pour ouvrir dans le navigateur système
   - Acceptance: Scanner un QR contenant `https://flutter.dev` affiche le bouton "Ouvrir" ; taper dessus lance le navigateur ; scanner du texte brut n'affiche pas le bouton "Ouvrir"

3. **Détection d'email** : Les adresses email sont identifiées dans le contenu scanné et l'utilisateur peut ouvrir l'app mail par défaut.
   - Current: Aucune détection d'email n'existe
   - Target: Les adresses email (regex pattern) sont détectées, un bouton "Envoyer" apparaît, et un tap lance l'app mail via le scheme `mailto:`
   - Acceptance: Scanner un QR contenant `test@example.com` affiche le bouton "Envoyer" ; taper dessus ouvre le client mail

4. **Détection de téléphone** : Les numéros de téléphone sont identifiés dans le contenu scanné et l'utilisateur peut ouvrir le dialer.
   - Current: Aucune détection de téléphone n'existe
   - Target: Les numéros de téléphone sont détectés, un bouton "Appeler" apparaît, et un tap ouvre le dialer natif via le scheme `tel:` (l'utilisateur confirme l'appel dans le dialer, pas d'appel automatique)
   - Acceptance: Scanner un QR contenant `+33612345678` affiche le bouton "Appeler" ; taper dessus ouvre le dialer avec le numéro pré-rempli

5. **Copier dans le presse-papiers** : Le contenu scanné peut être copié avec feedback visuel.
   - Current: Aucune fonctionnalité de copie n'existe
   - Target: Le bouton "Copier" est toujours visible dans le bottom sheet ; un tap copie le contenu brut dans le presse-papiers et affiche une SnackBar de confirmation "Contenu copié"
   - Acceptance: Taper "Copier" place le contenu dans le presse-papiers système et affiche la SnackBar de confirmation

6. **Partager via share sheet natif** : Le contenu scanné peut être partagé via le mécanisme de partage natif.
   - Current: Le package `share_plus` n'est pas installé
   - Target: Le bouton "Partager" est toujours visible ; un tap ouvre le share sheet natif avec le contenu texte brut (sans métadonnées de l'app)
   - Acceptance: Taper "Partager" ouvre le share sheet natif du système avec le contenu scanné

7. **Gestion d'erreur contenu vide/invalide** : Le contenu vide ou invalide affiche un état d'erreur dans le bottom sheet avec options de relance.
   - Current: Le contenu vide est filtré par `code.isEmpty` dans `handleQrCodeDetected()` mais sans feedback utilisateur
   - Target: Si le contenu est vide ou invalide (après trim), le bottom sheet s'affiche avec un message d'erreur, un bouton "Réessayer" (ferme le bottom sheet et relance le scan) et un bouton "Fermer"
   - Acceptance: Un contenu vide/whitespace-only ouvre le bottom sheet en état d'erreur avec les boutons "Réessayer" et "Fermer" ; "Réessayer" ferme le bottom sheet et la caméra reprend le scan

8. **Cycle de vie caméra avec bottom sheet** : La caméra se met en pause quand le bottom sheet est ouvert et reprend à la fermeture.
   - Current: La caméra tourne en continu même quand la SnackBar est affichée
   - Target: Quand le bottom sheet s'ouvre, `_controller.stop()` est appelé ; quand le bottom sheet se ferme (swipe ou bouton), `_controller.start()` est appelé ; les deux modes de fermeture (swipe-down et bouton) déclenchent la même reprise
   - Acceptance: La caméra s'arrête visuellement quand le bottom sheet est ouvert ; la caméra reprend après fermeture (swipe ou bouton) ; pas d'écran noir après fermeture

9. **ResultViewModel avec tests unitaires** : Un nouveau ViewModel gère l'état du résultat de scan (type de contenu, actions, erreurs).
   - Current: Aucun `ResultViewModel` n'existe ; le `ScannerViewModel` ne gère que les permissions et le verrou
   - Target: `ResultViewModel` est créé avec : détection du type de contenu (URL/email/téléphone/texte), méthodes pour chaque action (openUrl, sendEmail, callPhone, copy, share), gestion de l'état d'erreur ; tests unitaires couvrent toutes les méthodes et les cas limites
   - Acceptance: `flutter test` passe avec ≥90% de couverture des méthodes du ResultViewModel ; les tests vérifient la détection de type, l'exécution des actions, et les cas d'erreur

## Boundaries

**In scope:**
- Bottom sheet Material 3 avec contenu scanné et boutons d'action
- Détection de type de contenu : URL (http/https), email, téléphone
- Priorité de détection : URL > email > téléphone (un seul bouton contextuel)
- Actions : Copier (Clipboard), Partager (share_plus), Ouvrir URL (url_launcher), Envoyer mail (mailto:), Appeler (tel:)
- Gestion d'erreur pour contenu vide/invalide avec retry
- Pause/reprise caméra synchronisée avec le bottom sheet
- ResultViewModel avec tests unitaires
- Ajout des dépendances `url_launcher` et `share_plus` dans pubspec.yaml

**Out of scope:**
- Sauvegarde du scan en historique SQLite — Phase 5
- Écran de résultat dédié plein écran — le bottom sheet suffit pour v1
- Personnalisation du thème du bottom sheet — utilise le thème Material 3 existant de l'app
- Gestion des formats barcode non-QR (EAN-13, UPC) — fonctionnalité v2
- Scan depuis galerie/images — fonctionnalité v2
- QR codes WiFi, vCards, contacts — hors scope v1

## Constraints

- Packages requis : `url_launcher` (URLs, mailto, tel), `share_plus` (partage natif)
- Le Clipboard utilise `flutter/services.dart` (natif Flutter, pas de package externe)
- Le bottom sheet doit utiliser le thème Material 3 existant (`app_theme.dart`)
- La caméra est contrôlée via le `MobileScannerController` existant
- Architecture MVVM : le `ResultViewModel` suit le même pattern que `ScannerViewModel` (extends `ChangeNotifier`)
- Le filtrage de schémas URL est limité à `http` et `https` uniquement

## Acceptance Criteria

- [ ] Le bottom sheet s'affiche après un scan réussi avec le contenu et les boutons d'action
- [ ] Copier et Partager sont visibles pour tout type de contenu
- [ ] Le bouton contextuel (Ouvrir/Envoyer/Appeler) apparaît uniquement quand le type est détecté
- [ ] Les URLs http/https sont détectées et ouvrent le navigateur via url_launcher
- [ ] Les emails sont détectés et ouvrent l'app mail via mailto:
- [ ] Les numéros de téléphone sont détectés et ouvrent le dialer via tel:
- [ ] Copier place le contenu dans le presse-papiers et affiche une SnackBar de confirmation
- [ ] Partager ouvre le share sheet natif avec le contenu texte brut
- [ ] Le contenu vide/invalide affiche un état d'erreur avec boutons Réessayer et Fermer
- [ ] La caméra pause quand le bottom sheet est ouvert et reprend à la fermeture
- [ ] Les deux modes de fermeture (swipe et bouton) reprennent la caméra de la même façon
- [ ] `flutter test` passe avec les tests unitaires du ResultViewModel
- [ ] Priorité de détection : URL > email > téléphone (un seul bouton contextuel affiché)
- [ ] MUST NOT : Aucune URL n'est ouverte automatiquement sans interaction utilisateur
- [ ] MUST NOT : Les appels téléphoniques passent par le dialer (tel:), jamais d'appel direct
- [ ] MUST NOT : Les schémas non-http(s) (javascript:, file:, data:) ne sont pas ouverts dans le navigateur

## Edge Coverage

**Coverage:** 15/19 applicable edges resolved · 0 unresolved

| Category | Requirement | Status | Resolution / Reason |
|----------|-------------|--------|---------------------|
| boundary | R1 | ✅ covered | Priorité type : URL > email > téléphone, un seul bouton contextuel |
| empty | R1 | ✅ covered | Contenu vide après trim → état d'erreur (R7) |
| encoding | R1 | ⛔ dismissed | Flutter/Dart gère nativement l'UTF-8 |
| precision | R1 | ⛔ dismissed | Pas de calculs numériques applicables |
| unclassified | R2 | ⛔ dismissed | Fonctionnalité simple sans cas limite spécifique |
| unclassified | R3 | ⛔ dismissed | Fonctionnalité simple sans cas limite spécifique |
| boundary | R4 | ⛔ dismissed | Numéros envoyés tel quel au dialer OS |
| precision | R4 | ⛔ dismissed | Pas de calculs numériques applicables |
| unclassified | R5 | ⛔ dismissed | Fonctionnalité simple sans cas limite spécifique |
| empty | R6 | 🧪 backstop | Bouton Partager désactivé si contenu vide/erreur — test unitaire |
| encoding | R6 | ⛔ dismissed | Flutter/Dart gère nativement l'UTF-8 |
| empty | R7 | ✅ covered | Couvert par R1-empty et R7 : contenu vide = état d'erreur |
| encoding | R7 | ⛔ dismissed | Flutter/Dart gère nativement l'UTF-8 |
| idempotency | R7 | 🧪 backstop | Retry répété relance le scan sans crash — test unitaire |
| concurrency | R7 | ✅ covered | Verrou anti-rebond de Phase 2 (2s) déjà en place |
| unclassified | R8 | ✅ covered | Swipe et bouton reprennent la caméra de la même façon |
| adjacency | R9 | ⛔ dismissed | ViewModel traite un seul scan à la fois |
| empty | R9 | 🧪 backstop | ViewModel gère null/empty sans exception — test unitaire |
| ordering | R9 | ⛔ dismissed | ViewModel traite un seul scan à la fois |

## Prohibitions (must-NOT)

**Coverage:** 3/3 applicable prohibitions resolved · 0 unresolved

| Prohibition (must-NOT statement) | Requirement | Status | Verification / Reason |
|----------------------------------|-------------|--------|------------------------|
| MUST NOT ouvrir une URL automatiquement sans interaction utilisateur (tap sur "Ouvrir") | R2 | resolved | verification: test — test vérifie que url_launcher n'est appelé que sur interaction utilisateur |
| MUST NOT déclencher un appel téléphonique directement — doit ouvrir le dialer (tel:) et laisser l'utilisateur confirmer | R4 | resolved | verification: test — test vérifie l'utilisation du scheme `tel:` (dialer) |
| MUST NOT lancer le navigateur pour des schémas non-http(s) (javascript:, file:, data:) — uniquement http et https | R2 | resolved | verification: test — test vérifie le filtrage des schémas URL |

*Canon-referral : injection HTML/XSS est canon security — owned by /gsd-secure-phase + input sanitization; not minted here*
*Routine-engineering : clipboard feedback, camera lifecycle, stack traces — owned by code review*

## Ambiguity Report

| Dimension          | Score | Min  | Status | Notes                              |
|--------------------|-------|------|--------|---------------------------------------|
| Goal Clarity       | 0.92  | 0.75 | ✓      | Bottom sheet + actions + types détectés |
| Boundary Clarity   | 0.88  | 0.70 | ✓      | In/out scope explicites, packages confirmés |
| Constraint Clarity | 0.80  | 0.65 | ✓      | Packages, architecture MVVM, schémas URL |
| Acceptance Criteria| 0.80  | 0.70 | ✓      | 16 critères pass/fail dont 3 prohibitions |
| **Ambiguity**      | 0.14  | ≤0.20| ✓      |                                       |

## Interview Log

| Round | Perspective     | Question summary              | Decision locked                         |
|-------|-----------------|------------------------------|-----------------------------------------|
| 1     | Chercheur      | Flux post-scan : écran dédié, bottom sheet, ou SnackBar ? | Bottom sheet glissant, caméra visible derrière |
| 1     | Chercheur      | Types de contenu à détecter ? | URLs + emails + téléphones, chaque type déclenche une action native |
| 2     | Simplificateur | Boutons d'action du bottom sheet ? | Copier + Partager toujours visibles, action contextuelle si type détecté |
| 2     | Simplificateur | Niveau de gestion d'erreur minimum ? | 2 états : erreur caméra (Phase 2) + contenu vide/invalide dans bottom sheet |
| 3     | Gardien        | Packages Flutter confirmés ? | url_launcher, share_plus, Clipboard natif |
| 3     | Gardien        | Hors périmètre explicite ? | Historique SQLite (P5), écran dédié, thème custom, barcode non-QR |
| 4     | Analyste       | Comportement contenu vide/invalide ? | Bottom sheet erreur avec Réessayer + Fermer |
| 4     | Analyste       | Caméra quand bottom sheet ouvert ? | Pause à l'ouverture, reprise à la fermeture (swipe ou bouton) |

---

*Phase: 03-scan-results-content-display*
*Spec created: 2026-06-28*
*Next step: /gsd-discuss-phase 3 — décisions d'implémentation (comment construire ce qui est spécifié ci-dessus)*
