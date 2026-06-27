# Phase 1: Foundation & Navigation - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-06-27
**Phase:** 01-foundation-navigation
**Areas discussed:** Couleur seed du thème, Stratégie de navigation, Structure des placeholders, Organisation des tests

---

## Couleur seed du thème

| Option | Description | Selected |
|--------|-------------|----------|
| Teal / Vert d'eau | Fraîche et moderne — évoque la technologie et la clarté | |
| Bleu profond | Classique et fiable — style Google-like | |
| Violet | Créatif et distinctif — se démarque des apps utilitaires | |
| Tu décides | Laisse l'agent choisir la meilleure option | |

**User's choice:** "bleu ciel et du vert je ne veux pas de dégradé(gradiant)"
**Notes:** Couleurs sky blue + green, pas de gradients

---

## Thème — Mode

| Option | Description | Selected |
|--------|-------------|----------|
| Clair uniquement | Plus simple, pas de gestion de dark mode pour l'instant | ✓ |
| Clair + Sombre auto | Détecte le thème système automatiquement | |
| Tu décides | Choisis la meilleure option pour un projet d'apprentissage | |

**User's choice:** Clair uniquement

---

## Thème — Typography

| Option | Description | Selected |
|--------|-------------|----------|
| Défaut Flutter (Roboto) | Simple, rapide, pas de setup supplémentaire | |
| Google Font spécifique | Tu as une police en tête ? | |
| Tu décides | Choisis une police moderne et lisible | ✓ |

**User's choice:** Tu décides → Agent choisit Inter

---

## Thème — Style

| Option | Description | Selected |
|--------|-------------|----------|
| Minimaliste / Épuré | Beaucoup d'espace blanc, interface sobre | ✓ |
| Coloré / Dynamique | Couleurs vives, éléments visuels marquants | |
| Tu décides | Choisis ce qui va bien avec bleu ciel + vert | |

**User's choice:** Minimaliste / Épuré

---

## Stratégie de navigation — Router

| Option | Description | Selected |
|--------|-------------|----------|
| go_router (déclaratif) | Skill disponible, routing par URLs, bon pour le deep linking futur | |
| Navigator natif (imperatif) | Plus simple, pas de dépendance, suffisant pour 3 tabs | |
| Tu décides | Choisis la meilleure option pour ce projet | ✓ |

**User's choice:** Tu décides → Agent choisit go_router (skill disponible, better for future)

---

## Navigation — Back button

| Option | Description | Selected |
|--------|-------------|----------|
| Retour au 1er onglet | Le retour ramène toujours à l'onglet Scanner | ✓ |
| Quitter l'app | Double-tap pour quitter | |
| Tu décides | Choisis le comportement le plus naturel | |

**User's choice:** Retour au 1er onglet

---

## Navigation — Tab persistence

| Option | Description | Selected |
|--------|-------------|----------|
| Non, toujours Scanner au lancement | L'app s'ouvre toujours sur l'onglet Scanner | ✓ |
| Oui, mémoriser le dernier | L'app rouvre sur le dernier onglet utilisé | |
| Tu décides | Choisis ce qui est le plus pratique | |

**User's choice:** Non, toujours Scanner au lancement

---

## Structure des placeholders — Contenu

| Option | Description | Selected |
|--------|-------------|----------|
| Titre + icône centrale | Un grand titre + une icône représentative | ✓ |
| Titre + message descriptif | Un titre + un texte expliquant ce que fera l'écran | |
| Tu décides | Choisis le placeholder le plus élégant | |

**User's choice:** Tu décides → Agent choisit titre + icône centrale (plus épuré)

---

## Placeholders — Icônes

| Option | Description | Selected |
|--------|-------------|----------|
| Material Icons standards | Icons.camera_alt, Icons.qr_code, Icons.history | ✓ |
| Tu décides | Choisis des icônes cohérentes avec le thème | |

**User's choice:** Material Icons standards

---

## Placeholders — Couleur onglet actif

| Option | Description | Selected |
|--------|-------------|----------|
| Seed color (teinte principale) | L'onglet actif utilise la couleur principale du thème | ✓ |
| Vert (couleur secondaire) | L'onglet actif est vert, les autres en gris | |
| Tu décides | Choisis le style le plus cohérent | |

**User's choice:** Seed color (teinte principale)

---

## Placeholders — AppBar

| Option | Description | Selected |
|--------|-------------|----------|
| AppBar sur chaque écran | Un titre en haut de chaque écran | ✓ |
| Pas d'AppBar | Écran plein, le bottom nav suffit | |
| Tu décides | Choisis ce qui est le plus épuré | |

**User's choice:** AppBar sur chaque écran

---

## Organisation des tests — Structure

| Option | Description | Selected |
|--------|-------------|----------|
| Même structure que lib/ | test/models/, test/viewmodels/, test/services/, test/screens/ | ✓ |
| Dossier test/ plat | Tous les fichiers de test dans test/ sans sous-dossiers | |
| Tu décides | Choisis la structure la plus claire | |

**User's choice:** Même structure que lib/

---

## Tests — Priorité

| Option | Description | Selected |
|--------|-------------|----------|
| Modèles + Storage d'abord | Unit tests pour ScanRecord/GenerationRecord et StorageService en priorité | |
| Navigation d'abord | Widget tests pour la bottom nav | |
| Tout en même temps | Couvrir modèles, storage et navigation dès le début | ✓ |
| Tu décides | Choisis la meilleure stratégie | |

**User's choice:** Tout en même temps

---

## Tests — Couverture

| Option | Description | Selected |
|--------|-------------|----------|
| Basique | Tests critiques uniquement | |
| Intermédiaire | Ajouter les edge cases — erreurs SQLite, serialisation JSON | ✓ |
| Complet | Couvrir tous les cas possibles dès le début | |
| Tu décides | Choisis le niveau approprié | |

**User's choice:** Intermédiaire

---

## Tests — Nommage

| Option | Description | Selected |
|--------|-------------|----------|
| describe/it (comportement) | group('ScanRecord', () { test('should serialize to JSON', ...) | ✓ |
| test_ (fonctionnel) | test('scan_record_to_json', ...) | |
| Tu décides | Choisis le style le plus lisible | |

**User's choice:** "lis les skills pour prendre la meilleur décision" → Agent choisit testWidgets('description', ...) avec group() (selon skill flutter-add-widget-test)

---

## L'agent's Discretion

- **Couleur seed exacte:** Agent choisira la teinte de bleu ciel + vert qui fonctionne bien ensemble
- **Police Inter:** Confirmée via Google Fonts
- **Noms d'icônes exactes:** Selon les standards Material 3
- **Structure des dossiers de tests:** Selon les conventions Flutter standard

## Deferred Ideas

- Mode sombre avec détection automatique (DIFF-01 — v2)
- Presets de types QR (URL, texte, email) (DIFF-02 — v2)
- Couleurs personnalisées pour les QR codes (DIFF-03 — v2)
- QR codes WiFi, contacts, vCards (hors scope v1)
- Backend / serveur (app 100% offline)
- Authentification / comptes utilisateurs (projet perso, pas besoin)
