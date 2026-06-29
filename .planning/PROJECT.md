# QR Code Scanner & Generator

## What This Is

Application mobile Flutter qui permet de scanner des QR codes pour en récupérer le contenu (liens, texte) et de générer des QR codes à partir de texte ou d'URLs. L'app affiche le contenu scanné avec des actions (ouvrir, copier, partager) et permet de sauvegarder les QR codes générés en image dans la galerie ou de les partager directement. Projet perso/défi entre camarades.

## Core Value

Scanner un QR code et obtenir le contenu instantanément, avec la possibilité de le partager ou d'agir dessus.

## Requirements

### Validated

- ✓ Scanner un QR code via caméra et afficher le contenu récupéré — v1.0
- ✓ Générer un QR code à partir d'un champ texte (max 250 caractères) — v1.0
- ✓ Détecter les URLs dans le texte généré — v1.0
- ✓ Enregistrer le QR code généré en image dans la galerie — v1.0
- ✓ Partager le QR code généré via le share sheet natif — v1.0
- ✓ Copier le contenu du QR code dans le presse-papiers — v1.0
- ✓ Interface Material 3 avec navigation intuitive — v1.0
- ✓ Tests de widgets pour l'écran de génération — v1.0
- ✓ Gérer les permissions caméra (iOS/Android) — v1.0
- ✓ Afficher un overlay de guide de scan — v1.0
- ✓ Toggle lampe/torche pour environments sombres — v1.0
- ✓ Gérer le cycle de vie du contrôleur caméra — v1.0
- ✓ Empêcher les détections multiples du même QR code — v1.0
- ✓ Détecter les URLs dans le contenu scanné — v1.0
- ✓ Afficher le contenu du QR avec actions (ouvrir URL, copier, partager) — v1.0
- ✓ Stocker les scans et générations en SQLite — v1.0
- ✓ Afficher l'historique des scans/générations récentes — v1.0
- ✓ Rechercher/filtrer dans l'historique — v1.0
- ✓ Supprimer des entrées de l'historique — v1.0
- ✓ Tests unitaires pour les ViewModels et Repositories — v1.0
- ✓ Tests de widgets pour les écrans principaux — v1.0
- ✓ Layout responsive — v1.0
- ✓ Gestion correcte des erreurs et états de chargement — v1.0
- ✓ Widget previews pour les composants UI — v1.0

### Active

- [ ] Mode sombre avec détection automatique
- [ ] Presets de types QR (URL, texte, email)
- [ ] Couleurs personnalisées pour les QR codes
- [ ] Support des formats barcode (EAN-13, UPC)
- [ ] Scan depuis la galerie/images
- [ ] Batch scanning (plusieurs QR en séquence)
- [ ] Export historique en CSV
- [ ] Cadres/borders pour les QR codes

### Out of Scope

- Authentification / comptes utilisateurs — projet perso, pas besoin
- QR codes WiFi, contacts, vCards — texte et URLs suffisent pour v1
- Scan depuis image/galerie — scan caméra uniquement
- Génération de QR codes animés ou avec logo — fonctionnalité avancée, pas prioritaire
- Backend / serveur — app 100% offline, tout en local

## Context

- Application mobile Flutter (iOS et Android) — 4862 lignes de Dart
- Projet d'apprentissage et défi entre camarades
- Architecture MVVM avec Material 3, go_router, sqflite
- 142+ tests automatisés (unitaires, widgets, intégration)
- Le scan utilise la caméra de l'appareil
- La génération produit des images QR standard
- Pas de backend, tout est stocké localement
- Max 250 caractères pour le champ de texte de génération

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Flutter comme framework | Projet d'apprentissage Flutter, choix imposé par le défi | ✓ Good |
| Texte + URLs uniquement | Simplicité pour v1, les types QR complexes ajoutent de la complexité | ✓ Good |
| Material 3 | Design standard Google, bien supporté par Flutter | ✓ Good |
| Pas de backend | App simple, données en local, pas de besoin de sync | ✓ Good |
| Skills Flutter obligatoires | Suivre les bonnes pratiques via les skills installés | ✓ Good |
| MVVM avec setState | Suffisant pour 2-3 écrans, pas besoin de Riverpod/Bloc | ✓ Good |
| sqflite ^2.3.0 | Compatibilité Dart SDK 3.11.0 (pas ^2.4.3) | ✓ Good |
| WidgetsBindingObserver | Gestion du cycle de vie caméra (éviter écran noir) | ✓ Good |
| Anti-rebond 2s | Éviter les détections multiples d'un même QR | ✓ Good |
| RecordBase factory dispatch | Type-safe dispatch sans codegen pour l'historique | ✓ Good |

## Constraints

- **Tech stack**: Flutter avec Dart — langage et framework imposés
- **Hors-ligne**: Pas de connexion serveur requise, tout en local
- **Performance**: Le scan doit être réactif (< 2 secondes)
- **Compatibilité**: iOS et Android minimum
- **Skills Flutter obligatoires**: Utiliser les skills Flutter installés pour suivre les bonnes pratiques

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-06-29 after v1.0 milestone*
