---
phase: 03
slug: scan-results-content-display
status: approved
reviewed_at: 2026-06-28
shadcn_initialized: false
preset: none
created: 2026-06-28
---

# Phase 03 — UI Design Contract

> **⚠️ DIRECTIVE OBLIGATOIRE POUR L'AGENT DÉVELOPPEUR :**
> L'utilisation des **skills Flutter installés localement** est **OBLIGATOIRE** pour tout le développement et la validation de cette phase.
> L'agent développeur DOIT se référer aux instructions des skills suivants pour garantir la qualité du code et respecter les bonnes pratiques :
> - [flutter-apply-architecture-best-practices](file:///home/marwane/Documents/CodR/.agents/skills/flutter-apply-architecture-best-practices/SKILL.md) (Architecture MVVM)
> - [flutter-add-widget-test](file:///home/marwane/Documents/CodR/.agents/skills/flutter-add-widget-test/SKILL.md) (Widget & Unit Tests)
> - [flutter-add-widget-preview](file:///home/marwane/Documents/CodR/.agents/skills/flutter-add-widget-preview/SKILL.md) (Interactive Previews)
> - [flutter-build-responsive-layout](file:///home/marwane/Documents/CodR/.agents/skills/flutter-build-responsive-layout/SKILL.md) (Responsivité mobile/tablette)
> - [flutter-fix-layout-issues](file:///home/marwane/Documents/CodR/.agents/skills/flutter-fix-layout-issues/SKILL.md) (Debug Layout/Constraints)

---

## Design System

| Property | Value |
|----------|-------|
| Tool | none |
| Preset | not applicable |
| Component library | none |
| Icon library | Icons (Material Icons) |
| Font | Inter (GoogleFonts.interTextTheme) |

---

## Spacing Scale

Valeurs déclarées (multiples de 4 uniquement) :

| Token | Value | Usage |
|-------|-------|-------|
| xs | 4px | Écarts d'icônes, padding en ligne compact |
| sm | 8px | Espacement compact entre éléments (boutons) |
| md | 16px | Espacement par défaut (marges de contenu) |
| lg | 24px | Padding du Bottom Sheet / sections |
| xl | 32px | Écarts de layout |
| 2xl | 48px | Ruptures de section majeures |
| 3xl | 64px | Espacement au niveau de la page |

Exceptions: none

---

## Typography

| Role | Size | Weight | Line Height |
|------|------|--------|-------------|
| Body | 16px | 400 (regular) | 1.5 |
| Label | 12px | 400 (regular) | 1.2 |
| Heading | 20px | 600 (semibold) | 1.2 |
| Display | 24px | 600 (semibold) | 1.2 |

---

## Color

| Role | Value | Usage |
|------|-------|-------|
| Dominant (60%) | `#FFFFFF` | Fond du bottom sheet, surfaces principales |
| Secondary (30%) | `#F4FAFC` | Zone d'affichage du texte scanné, éléments secondaires |
| Accent (10%) | `#0083B0` | Bouton d'action contextuelle (principal), éléments actifs |
| Destructive | `#D32F2F` | Icônes d'erreur, actions d'annulation/fermeture en erreur |

Accent reserved for: Boutons d'action contextuels (Ouvrir le lien, Envoyer l'e-mail, Appeler le numéro) uniquement.

---

## Visuals & Hierarchy

* **Focal Point :** Le bouton d'action contextuelle accentué (`#0083B0`), positionné au centre ou de manière visible dans la barre d'action du bottom sheet.
* **Visual Hierarchy :**
  1. Titre / Type de contenu détecté (Semibold, 20px).
  2. Contenu textuel scanné dans son cadre scrollable (Secondary, `#F4FAFC`).
  3. Barre d'actions (Bouton contextuel accentué en premier, suivi des boutons secondaires outlinés avec texte "Copier le texte" et "Partager le contenu").
* **Accessibility :** Tous les boutons d'action comportent une étiquette textuelle claire sous ou à côté de leur icône. Aucun bouton n'est purement iconographique sans alternative textuelle visible.

---

## Copywriting Contract

| Element | Copy |
|---------|------|
| Primary CTA (URL) | "Ouvrir le lien" |
| Primary CTA (Email) | "Envoyer l'e-mail" |
| Primary CTA (Phone) | "Appeler le numéro" |
| Primary CTA (Copy) | "Copier le texte" |
| Primary CTA (Share) | "Partager le contenu" |
| Empty state heading | "Aucun code détecté" |
| Empty state body | "Veuillez placer un code QR valide devant la caméra pour le numériser." |
| Error state | "Le code QR scanné est vide ou invalide. Veuillez fermer ce panneau et scanner un autre code." |
| Destructive confirmation | none |

---

## Registry Safety

| Registry | Blocks Used | Safety Gate |
|----------|-------------|-------------|
| shadcn official | none | not required |
| third-party | none | not required |

---

## Checker Sign-Off

- [x] Dimension 1 Copywriting: PASS
- [x] Dimension 2 Visuals: PASS
- [x] Dimension 3 Color: PASS
- [x] Dimension 4 Typography: PASS
- [x] Dimension 5 Spacing: PASS
- [x] Dimension 6 Registry Safety: PASS

**Approval:** approved 2026-06-28
