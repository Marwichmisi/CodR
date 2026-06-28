# Phase 03 Context

## Domain
Affichage du contenu scanné, détection d'URL, actions (copier, partager, ouvrir) et gestion des erreurs de scan.

## Locked Requirements
> **Note:** Requirements are locked by `03-SPEC.md`.

## Canonical References
- `.planning/phases/03-scan-results-content-display/03-SPEC.md` (Locked requirements — MUST read before planning)
- `.agents/skills/flutter-add-widget-preview/SKILL.md` (Obligatoire pour les prévisualisations UI)
- `.agents/skills/flutter-add-widget-test/SKILL.md` (Obligatoire pour les tests)
- `.agents/skills/flutter-build-responsive-layout/SKILL.md` (Obligatoire pour le layout responsive)

## Decisions
### 1. Interface de résultat
- Affichage dans une **BottomSheet** (modale depuis le bas, fluide) pour maintenir le contexte du scanner.

### 2. Aperçu des URLs
- **Texte brut uniquement** : pour des performances optimales et éviter des requêtes réseau supplémentaires inutiles.

### 3. Reprise du scan
- **Délai avant reprise** : après la fermeture de la BottomSheet, attendre un délai de 2 secondes avant de reprendre le scan automatiquement.

### 4. Directives Agent Développeur
- L'utilisation des skills Flutter locaux (notamment `flutter-add-widget-preview`, `flutter-add-widget-test`, `flutter-apply-architecture-best-practices`) est **strictement obligatoire** pour l'implémentation.
