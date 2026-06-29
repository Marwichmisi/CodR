# Phase 4: QR Generation — Specification

**Created:** 2026-06-28
**Ambiguity score:** 0.10 (gate: ≤ 0.20)
**Requirements:** 7 locked

## Goal

Les utilisateurs peuvent générer des QR codes à partir d'un champ texte avec détection d'URL automatique, prévisualisation en temps réel (debounce 300ms), limite de 250 caractères, et sauvegarder/partager/copier le résultat.

## Background

Le projet dispose déjà d'un `GeneratorScreen` placeholder (icône + titre uniquement), du modèle `GenerationRecord` avec sérialisation JSON, et du `StorageService` avec table `generation_records` SQLite. Aucun code de génération QR n'existe — le package `qr_flutter` n'est pas dans les dépendances. L'écran navigable existe dans `app_router.dart` mais n'a pas de ViewModel associé. Les packages `share_plus` et `path_provider` sont déjà installés.

## Requirements

1. **QR real-time preview**: Le champ texte génère un QR code en temps réel avec debounce 300ms.
   - Current: `GeneratorScreen` est un placeholder sans functionality — pas de champ texte, pas de rendu QR
   - Target: `QrImage` (qr_flutter) rend un QR code à partir du texte saisi, mis à jour après 300ms d'inactivité
   - Acceptance: Taper du texte puis arrêter pendant 300ms affiche le QR correspondant; vider le champ affiche un placeholder

2. **Character limit**: Limite de 250 caractères avec compteur visuel.
   - Current: Aucun champ texte ni compteur n'existe
   - Target: `TextField` avec `maxLength: 250`, compteur affiché `n/250`, texte au-delà de 250 rejeté
   - Acceptance: Taper 250 caractères remplit le compteur; taper le 251e est impossible; le compteur change de couleur à 250

3. **URL auto-detection**: Détection automatique des URLs dans le texte saisi.
   - Current: Aucune logique de détection URL dans le contexte génération
   - Target: Si le texte ressemble à une URL (contient `.` et pas d'espace), le QR encode l'URL avec `https://` si absent; un badge visuel "URL détectée" s'affiche
   - Acceptance: Taper `example.com` encode `https://example.com.example.com` dans le QR; un badge URL s'affiche; taper du texte pur n'affiche pas le badge

4. **Save to gallery**: Sauvegarde du QR code en image dans la galerie device.
   - Current: Aucune fonctionnalité de sauvegarde
   - Target: Bouton "Sauvegarder" qui exporte le QR en PNG (300x300 fixe) via `image_gallery_saver` avec demande de permission
   - Acceptance: Appuyer "Sauvegarder" déclenche la permission galerie puis écrit l'image;SnackBar affiche "QR sauvegardé !"; annulation affiche un message d'erreur

5. **Share QR image**: Partage du QR code via le share sheet natif.
   - Current: Aucune fonctionnalité de partage
   - Target: Bouton "Partager" qui exporte le QR en PNG temporaire via `share_plus` et ouvre le share sheet natif
   - Acceptance: Appuyer "Partager" ouvre le share sheet avec l'image QR; l'image est un fichier PNG valide

6. **Copy to clipboard**: Copie du contenu encodé dans le presse-papiers.
   - Current: Aucune fonctionnalité de copie
   - Target: Bouton "Copier" qui copie le texte original saisi dans le presse-papiers système
   - Acceptance: Appuyer "Copier" met le texte dans le presse-papiers; SnackBar affiche "Copié !"

7. **Generator widget tests**: Tests de widgets pour l'écran générateur.
   - Current: Aucun test pour `GeneratorScreen`
   - Target: Tests couvrant état vide, saisie texte, limite 250, boutons d'action, feedback SnackBar
   - Acceptance: Tous les tests passent avec `flutter test`; chaque bouton est testé pour afficher le SnackBar attendu

## Boundaries

**In scope:**
- Champ texte avec compteur 250 caractères
- Rendu QR temps réel avec debounce 300ms
- Détection automatique des URLs (badge visuel)
- Sauvegarde en galerie (image PNG 300x300)
- Partage via share sheet natif
- Copie dans le presse-papiers
- SnackBar feedback pour chaque action
- Placeholder avec icône QR quand le champ est vide
- Tests de widgets pour l'écran

**Out of scope:**
- Personnalisation des couleurs QR — réservé aux exigences v2 (DIFF-03)
- Formats barcode (EAN-13, UPC) — réservé aux exigences v2 (DIFF-04)
- Batch generation (plusieurs QR en séquence) — réservé aux exigences v2 (DIFF-06)
- Cadres/borders pour les QR codes — réservé aux exigences v2 (DIFF-08)
- Import depuis galerie — scan caméra uniquement pour v1
- Authentification / comptes — app 100% offline
- Backend / serveur — tout en local

## Constraints

- Le package `qr_flutter` (^4.1.0 ou ^5.x) doit être ajouté aux dépendances
- Le package `image_gallery_saver` doit être ajouté aux dépendances
- Le QR code doit être rendu en noir et blanc uniquement (pas de couleur personnalisable)
- Les dimensions de sauvegarde sont fixes à 300x300px (pas de sélecteur de qualité)
- Le ViewModel doit suivre le pattern `ChangeNotifier` existant (comme `ScannerViewModel`)
- L'écran doit utiliser `LayoutBuilder` avec `ConstrainedBox` (max 480px) pour le responsive
- Les skills Flutter obligatoires doivent être utilisées: `flutter-apply-architecture-best-practices`, `flutter-add-widget-test`, `flutter-build-responsive-layout`

## Acceptance Criteria

- [ ] `GeneratorViewModel` existe et gère l'état texte, QR, debouce 300ms, et actions
- [ ] Le champ texte affiche un compteur `n/250` et bloque à 250 caractères
- [ ] Le QR code se rend en temps réel après debounce de 300ms
- [ ] Un badge "URL détectée" s'affiche quand le texte est une URL
- [ ] Le bouton "Sauvegarder" écrit l'image PNG dans la galerie et affiche SnackBar
- [ ] Le bouton "Partager" ouvre le share sheet natif avec l'image QR
- [ ] Le bouton "Copier" met le texte dans le presse-papiers et affiche SnackBar
- [ ] Un placeholder s'affiche quand le champ texte est vide
- [ ] L'écran est responsive (LayoutBuilder + ConstrainedBox, max 480px)
- [ ] Tests de widgets passent pour chaque bouton et état
- [ ] Le ViewModel a des tests unitaires pour debounce, détection URL, et état

## Edge Coverage

**Coverage:** 6/6 applicable edges resolved · 0 unresolved

| Category | Requirement | Status | Resolution / Reason |
|----------|-------------|--------|---------------------|
| boundary | R2 (character limit) | ✅ covered | AC: compteur affiche n/250, bloque à 250, change couleur |
| empty | R1 (QR preview) | ✅ covered | AC: champ vide affiche placeholder avec icône QR |
| encoding | R6 (URL detection) | ✅ covered | AC: texte avec `.` sans espace détecté comme URL; `https://` ajouté si absent |
| idempotency | R4 (save gallery) | ✅ covered | AC: sauvegarde multiple produit des images distinctes (horodatage dans le nom) |
| idempotency | R5 (share) | ✅ covered | AC: partage multiple ouvre le share sheet à chaque fois sans erreur |
| concurrency | R5 (clipboard) | ✅ covered | AC: copie multiple remplace le contenu du presse-papiers sans erreur |

## Prohibitions (must-NOT)

**Coverage:** 2/2 applicable prohibitions resolved · 0 unresolved

| Prohibition (must-NOT statement) | Requirement | Status | Verification / Reason |
|----------------------------------|-------------|--------|------------------------|
| MUST NOT logger ou transmettre le contenu généré par l'utilisateur (privacy) | R1, R3, R4, R5, R6 | resolved | verification: test — aucun appel réseau ni écriture log avec le contenu texte dans le code génération |
| MUST NOT sauvegarder automatiquement un QR code sans action utilisateur explicite | R4 | resolved | verification: test — la sauvegarde ne se déclenche qu'au clic sur "Sauvegarder", jamais au chargement ou à la saisie |

## Ambiguity Report

| Dimension          | Score | Min  | Status | Notes                                      |
|--------------------|-------|------|--------|--------------------------------------------|
| Goal Clarity       | 0.92  | 0.75 | ✓      | Objectif mesurable avec debounce et limites |
| Boundary Clarity   | 0.95  | 0.70 | ✓      | Scope v1/v2 explicite avec raisons          |
| Constraint Clarity | 0.80  | 0.65 | ✓      | Packages, dimensions fixes, pattern MVVM   |
| Acceptance Criteria| 0.88  | 0.70 | ✓      | 11 critères pass/fail                       |
| **Ambiguity**      | 0.10  | ≤0.20| ✓      |                                            |

Status: ✓ = met minimum

## Interview Log

| Round | Perspective     | Question summary                              | Decision locked                                      |
|-------|-----------------|-----------------------------------------------|------------------------------------------------------|
| 1     | Researcher      | Comportement temps réel du QR                 | Debounce 300ms                                        |
| 1     | Researcher      | Détection URL automatique                     | Auto-détecter URLs, badge visuel                     |
| 1     | Researcher      | Expérience sauvegarde galerie                 | Sauvegarde directe, dimensions fixes 300x300          |
| 2     | Simplificateur  | Couleurs QR                                   | Noir et blanc uniquement (v1)                         |
| 2     | Simplificateur  | Contenu partagé                               | Partager image PNG, pas le texte                      |
| 2     | Simplificateur  | Feedback visuel                               | SnackBar pour chaque action                           |
| 3     | Boundary Keeper | État initial écran                            | Placeholder avec icône QR quand champ vide            |
| 3     | Boundary Keeper | Limite caractères                             | 250 caractères avec compteur visuel confirmé          |

---

*Phase: 04-qr-generation*
*Spec created: 2026-06-28*
*Next step: /gsd-discuss-phase 4 — implementation decisions (qr_flutter version, save strategy, test coverage)*
