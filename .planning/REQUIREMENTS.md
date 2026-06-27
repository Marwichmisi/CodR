# Requirements: QR Code Scanner & Generator

**Defined:** 2026-06-27
**Core Value:** Scanner un QR code et obtenir le contenu instantanément, avec la possibilité de le partager ou d'agir dessus.

## v1 Requirements

Requirements for initial release. Each maps to roadmap phases.

### Infrastructure

- [ ] **INFRA-01**: Initialiser le projet Flutter avec structure MVVM (skills flutter-apply-architecture-best-practices)
- [ ] **INFRA-02**: Configurer le thème Material 3 (couleurs, typography)
- [ ] **INFRA-03**: Mettre en place la navigation entre les écrans (skills flutter-setup-declarative-routing)
- [ ] **INFRA-04**: Créer les modèles de données (ScanRecord, GenerationRecord)
- [ ] **INFRA-05**: Mettre en place le service de stockage SQLite (sqflite)

### Scan

- [ ] **SCAN-01**: Scanner un QR code via caméra avec `mobile_scanner`
- [ ] **SCAN-02**: Gérer les permissions caméra (iOS/Android)
- [ ] **SCAN-03**: Afficher un overlay de guide de scan
- [ ] **SCAN-04**: Toggle lampe/torche pour environments sombres
- [ ] **SCAN-05**: Gérer le cycle de vie du contrôleur caméra (éviter écran noir)
- [ ] **SCAN-06**: Empêcher les détections multiples du même QR code
- [ ] **SCAN-07**: Détecter les URLs dans le contenu scanné
- [ ] **SCAN-08**: Afficher le contenu du QR avec actions (ouvrir URL, copier, partager)

### Génération

- [ ] **GEN-01**: Générer un QR code à partir d'un champ texte avec `qr_flutter`
- [ ] **GEN-02**: Limiter le champ texte à 250 caractères avec compteur
- [ ] **GEN-03**: Détecter les URLs dans le texte généré
- [ ] **GEN-04**: Enregistrer le QR code généré en image dans la galerie
- [ ] **GEN-05**: Gérer les permissions galerie (iOS/Android)
- [ ] **GEN-06**: Partager le QR code via le share sheet natif (`share_plus`)
- [ ] **GEN-07**: Copier le contenu dans le presse-papiers

### Historique

- [ ] **HIST-01**: Stocker les scans et générations en SQLite (sqflite)
- [ ] **HIST-02**: Afficher l'historique des scans/rations récentes
- [ ] **HIST-03**: Rechercher/filtrer dans l'historique
- [ ] **HIST-04**: Supprimer des entrées de l'historique

### UI/UX

- [ ] **UI-01**: Interface Material 3 avec navigation intuitive (bottom nav ou tabs)
- [ ] **UI-02**: Écran Scanner avec vue caméra et overlay
- [ ] **UI-03**: Écran Génération avec champ texte et prévisualisation QR
- [ ] **UI-04**: Écran Historique avec liste et recherche
- [ ] **UI-05**: Widget previews pour les composants UI (skills flutter-add-widget-preview)

### Qualité

- [ ] **QUAL-01**: Tests unitaires pour les ViewModels et Repositories
- [ ] **QUAL-02**: Tests de widgets pour les écrans principaux (skills flutter-add-widget-test)
- [ ] **QUAL-03**: Layout responsive (skills flutter-build-responsive-layout)
- [ ] **QUAL-04**: Gestion correcte des erreurs et états de chargement

## v2 Requirements

Deferred to future release. Tracked but not in current roadmap.

### Differentiators

- **DIFF-01**: Mode sombre avec détection automatique
- **DIFF-02**: Presets de types QR (URL, texte, email)
- **DIFF-03**: Couleurs personnalisées pour les QR codes
- **DIFF-04**: Support des formats barcode (EAN-13, UPC)
- **DIFF-05**: Scan depuis la galerie/images
- **DIFF-06**: Batch scanning (plusieurs QR en séquence)
- **DIFF-07**: Export historique en CSV
- **DIFF-08**: Cadres/borders pour les QR codes

## Out of Scope

| Feature | Reason |
|---------|--------|
| Authentification / comptes | Projet perso, pas besoin d'identité utilisateur |
| Backend / serveur | App 100% offline, tout en local |
| QR codes WiFi, contacts, vCards | Texte et URLs suffisent pour v1 |
| QR codes animés ou avec logo | Fonctionnalité avancée, pas prioritaire |
| Scan depuis image/galerie | Scan caméra uniquement pour v1 |
| Impression directe de QR | Pas de support imprimante, sauvegarder/partager à la place |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| INFRA-01 | Phase 1 | Pending |
| INFRA-02 | Phase 1 | Pending |
| INFRA-03 | Phase 1 | Pending |
| INFRA-04 | Phase 1 | Pending |
| INFRA-05 | Phase 1 | Pending |
| SCAN-01 | Phase 2 | Pending |
| SCAN-02 | Phase 2 | Pending |
| SCAN-03 | Phase 2 | Pending |
| SCAN-04 | Phase 2 | Pending |
| SCAN-05 | Phase 2 | Pending |
| SCAN-06 | Phase 2 | Pending |
| SCAN-07 | Phase 3 | Pending |
| SCAN-08 | Phase 3 | Pending |
| GEN-01 | Phase 4 | Pending |
| GEN-02 | Phase 4 | Pending |
| GEN-03 | Phase 4 | Pending |
| GEN-04 | Phase 4 | Pending |
| GEN-05 | Phase 4 | Pending |
| GEN-06 | Phase 4 | Pending |
| GEN-07 | Phase 4 | Pending |
| HIST-01 | Phase 5 | Pending |
| HIST-02 | Phase 5 | Pending |
| HIST-03 | Phase 5 | Pending |
| HIST-04 | Phase 5 | Pending |
| UI-01 | Phase 1 | Pending |
| UI-02 | Phase 2 | Pending |
| UI-03 | Phase 4 | Pending |
| UI-04 | Phase 5 | Pending |
| UI-05 | Phase 1 | Pending |
| QUAL-01 | Phase 3 | Pending |
| QUAL-02 | Phase 4 | Pending |
| QUAL-03 | Phase 1 | Pending |
| QUAL-04 | Phase 3 | Pending |

**Coverage:**
- v1 requirements: 33 total
- Mapped to phases: 33
- Unmapped: 0 ✓

---
*Requirements defined: 2026-06-27*
*Last updated: 2026-06-27 after initial definition*
