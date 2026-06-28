# Phase 4: QR Generation - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-06-28
**Phase:** 04-qr-generation
**Areas discussed:** Version qr_flutter, Layout écran, Débounce 300ms, Détection URL, Permissions galerie

---

## Version qr_flutter

| Option | Description | Selected |
|--------|-------------|----------|
| qr_flutter ^5.2.0 | Widget QrImage, version v5 stable, bien documenté | ✓ |
| qr_flutter ^4.1.0 | Widget legacy, moins maintenu, moins de breaking changes | |

**User's choice:** qr_flutter ^5.2.0 (Recommandé)
**Notes:** Version actuelle stable, suffisante pour du noir et blanc.

---

## Layout écran

| Option | Description | Selected |
|--------|-------------|----------|
| Vertical: Texte → QR → Actions | Disposition colonne simple: champ texte, preview QR, boutons d'action | ✓ |
| Adaptatif selon la taille | Côte à côte sur tablette, vertical sur mobile | |
| Sections avec onglets | Onglets pour séparer saisie et rendu | |

**User's choice:** Vertical: Texte → QR → Actions (Recommandé)
**Notes:** Layout épuré et équilibré, conforme au style minimaliste du projet.

---

## Débounce 300ms

| Option | Description | Selected |
|--------|-------------|----------|
| Timer Dart | Timer classique dans le ViewModel, reset à chaque keystroke | ✓ |
| Stream + RxDart | Transformer en Stream avec debounce via rxdart | |

**User's choice:** Timer Dart (Recommandé)
**Notes:** Pas de dépendance externe, simple et direct.

---

## Détection URL

| Option | Description | Selected |
|--------|-------------|----------|
| Regex simple '.' + pas d'espace | Contient un '.' et pas d'espace, ajoute https:// | |
| Détection par patterns connus | Vérifier schemes (http, https, ftp), www., extensions (.com, .fr, etc.) | ✓ |
| Uri.tryParse | Valider si le texte est une URI valide | |

**User's choice:** Détection par patterns connus
**Notes:** Plus robuste que la regex simple, couvre les cas courants.

---

## Permissions galerie

| Option | Description | Selected |
|--------|-------------|----------|
| Au clic Sauvegarder | Demander la permission au moment de l'action | ✓ |
| Au lancement de l'écran | Demander au chargement de l'écran | |

**User's choice:** Au clic Sauvegarder (Recommandé)
**Notes:** Permission explicite au moment de l'action, utilise permission_handler déjà installé.

---

## the agent's Discretion

- Dimensions et position du badge URL
- Style du placeholder (icône, sous-titre) quand le champ est vide
- Patterns d'URL exacts à détecter
- Logique concrète de sauvegarde PNG (widget → image → fichier)
- Taille et disposition des boutons d'action

---

## Deferred Ideas

- Personnalisation des couleurs QR — v2 (DIFF-03)
- Formats barcode — v2 (DIFF-04)
- Batch generation — v2 (DIFF-06)
- Cadres/borders — v2 (DIFF-08)
- Import depuis galerie — v2 (DIFF-05)
- Sauvegarde automatique dans l'historique — Phase 5

