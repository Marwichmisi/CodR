# QR Code Scanner & Generator

## What This Is

Une application mobile Flutter qui permet de scanner des QR codes pour en récupérer le contenu (liens, texte) et de générer des QR codes à partir de texte ou d'URLs. L'app affiche le contenu scanné avec des actions (ouvrir, copier, partager) et permet de sauvegarder les QR codes générés en image dans la galerie ou de les partager directement. Projet perso/défi entre camarades.

## Core Value

Scanner un QR code et obtenir le contenu instantanément, avec la possibilité de le partager ou d'agir dessus.

## Requirements

### Validated

- [x] Scanner un QR code via caméra et afficher le contenu récupéré (Validated in Phase 02: camera-scanner)

### Active

- [ ] Détecter automatiquement les URLs et proposer de les ouvrir
- [ ] Afficher le contenu du QR code avec des boutons d'action (ouvrir, copier, partager)
- [ ] Générer un QR code à partir d'un champ texte (max 250 caractères)
- [ ] Détecter les URLs dans le texte généré
- [ ] Enregistrer le QR code généré en image dans la galerie
- [ ] Partager le QR code généré via le share sheet natif
- [ ] Copier le contenu du QR code dans le presse-papiers
- [ ] Historique des scans et générations récentes
- [ ] Interface Material 3 avec navigation intuitive

### Out of Scope

- Authentification / comptes utilisateurs — projet perso, pas besoin
- QR codes WiFi, contacts, vCards — texte et URLs suffisent pour v1
- Scan depuis image/galerie — scan caméra uniquement
- Génération de QR codes animés ou avec logo — fonctionnalité avancée, pas prioritaire
- Backend / serveur — app 100% offline, tout en local

## Context

- Application mobile Flutter (iOS et Android)
- Projet d'apprentissage et défi entre camarades
- Le scan utilise la caméra de l'appareil
- La génération produit des images QR standard
- Pas de backend, tout est stocké localement
- Max 250 caractères pour le champ de texte de génération

## Constraints

- **Tech stack**: Flutter avec Dart — langage et framework imposés
- **Hors-ligne**: Pas de connexion serveur requise, tout en local
- **Performance**: Le scan doit être réactif (< 2 secondes)
- **Compatibilité**: iOS et Android minimum
- **Skills Flutter obligatoires**: Utiliser les skills Flutter installés (`.agents/skills/flutter-*`) pour suivre les bonnes pratiques et produire du code de qualité. Skills disponibles : architecture best practices (MVVM), widget tests, widget previews, responsive layout, JSON serialization, routing déclaratif, localization, HTTP package, fix layout issues

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Flutter comme framework | Projet d'apprentissage Flutter, choix imposé par le défi | — Pending |
| Texte + URLs uniquement | Simplicité pour v1, les types QR complexes ajoutent de la complexité | — Pending |
| Material 3 | Design standard Google, bien supporté par Flutter | — Pending |
| Pas de backend | App simple, données en local, pas de besoin de sync | — Pending |
| Skills Flutter obligatoires | Suivre les bonnes pratiques via les skills installés (architecture, tests, previews, etc.) | — Pending |

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
*Last updated: 2026-06-28 after phase 02 completion*
