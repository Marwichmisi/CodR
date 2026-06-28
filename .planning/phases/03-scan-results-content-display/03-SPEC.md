# SPEC: Phase 3 - Scan Results & Content Display

## Goal
Display scanned QR code content accurately, detect URLs to allow browser opening, provide copy/share actions, and handle all error/loading states gracefully. 

> [!IMPORTANT]
> **CONTRAINTE ABSOLUE POUR L'AGENT DE DÉVELOPPEMENT (DEV AGENT) :**
> Vous devez OBLIGATOIREMENT utiliser les skills Flutter disponibles (par ex. `flutter-add-widget-preview`, `flutter-add-widget-test`, `flutter-build-responsive-layout`, etc.) lors de l'implémentation. Ces skills sont conçus pour vous guider dans les bonnes pratiques (tests, layout, prévisualisations). L'exécution sans l'appel préalable à ces skills est strictement interdite pour assurer un code de haute qualité !

## Boundaries

### In Scope
- Affichage du contenu brut du QR code dans une modale ou un écran de résultat dédié.
- Détection automatique si le contenu est une URL valide.
- Boutons d'action : "Ouvrir l'URL" (seulement si c'est une URL), "Copier", "Partager".
- Gestion des erreurs : QR code illisible, permission de caméra refusée, et échec d'ouverture de l'URL.
- Tests unitaires pour `ScannerViewModel` et le nouveau `ResultViewModel`.
- Utilisation stricte des skills Flutter locaux pour garantir la qualité.

### Out of Scope
- Historique persistant des scans (prévu pour la Phase 5).
- Génération de QR codes (prévue pour la Phase 4).
- Authentification ou intégration backend.
- Actions spécifiques autres que URL (ex: VCard, Wifi) — tout le reste est traité comme du texte simple.

## Requirements

### R1: Détection des URLs (SCAN-07)
- **Current state**: Le scanner détecte le texte brut mais ne fait aucune différence entre un texte et un lien.
- **Target state**: Le système analyse le texte scanné pour déterminer si c'est une URL cliquable.
- **Acceptance Criteria**:
  - [ ] Le viewmodel retourne un booléen `isUrl` à vrai si le texte commence par `http://` ou `https://` (ou une regex URL valide).
  - [ ] L'interface affiche un bouton "Ouvrir le lien" si et seulement si `isUrl` est vrai.

### R2: Actions sur le résultat (SCAN-08)
- **Current state**: Le résultat du scan est juste affiché ou ignoré, aucune action n'est possible.
- **Target state**: L'utilisateur peut interagir avec le contenu scanné via des boutons standards.
- **Acceptance Criteria**:
  - [ ] Un bouton "Copier" copie le texte dans le presse-papiers du système et affiche un message de succès (SnackBar).
  - [ ] Un bouton "Partager" ouvre le composant natif de partage du téléphone (via `share_plus`).
  - [ ] Un bouton "Ouvrir" lance le navigateur par défaut (via `url_launcher`) si le contenu est une URL.

### R3: Gestion des erreurs (QUAL-04)
- **Current state**: Les erreurs de scan ou de droits peuvent provoquer des écrans vides ou non gérés.
- **Target state**: Toutes les erreurs sont remontées à l'utilisateur de manière compréhensible.
- **Acceptance Criteria**:
  - [ ] Une erreur d'accès à la caméra affiche un message clair avec un bouton "Réessayer" ou "Ouvrir les paramètres".
  - [ ] Si l'ouverture d'une URL échoue, une `SnackBar` d'erreur est affichée.

### R4: Tests et Qualité (QUAL-01, QUAL-04)
- **Current state**: Pas de tests unitaires sur la logique de scan et de résultat.
- **Target state**: Couverture de tests pour la logique métier et respect des bonnes pratiques UI via les skills Flutter.
- **Acceptance Criteria**:
  - [ ] `ScannerViewModel` possède des tests unitaires validant la gestion d'état (en attente, erreur, succès).
  - [ ] `ResultViewModel` possède des tests unitaires validant la détection d'URL.
  - [ ] L'agent dev a utilisé `flutter-add-widget-preview` pour les composants UI créés.

## Edge Coverage
- **E1 (R1 - URL malformée)**: Une URL sans protocole (ex: `www.google.com`). Doit être traitée comme du texte ou corrigée en interne. *[backstop - à tester]*
- **E2 (R2 - Copie vide)**: Le presse-papiers échoue. *[covered]* → Afficher une erreur via SnackBar.
- **E3 (R3 - Droits révoqués en cours)**: L'utilisateur révoque les droits caméra pendant que l'app est en arrière-plan. *[covered]* → Retour à l'état erreur.

## Prohibitions
- [test] **P1**: L'application ne doit pas crasher si le contenu du QR code est null ou excessivement grand (ex: 4000 caractères).
- [judgment] **P2**: L'interface de résultat ne doit pas bloquer la possibilité de rescanner un autre QR (il doit y avoir un bouton de retour clair ou une modale qui se ferme).

## Ambiguity Report
- Goal Clarity: 0.95
- Boundary Clarity: 0.90
- Constraint Clarity: 0.90
- Acceptance Criteria: 0.90
- **Ambiguity Score: 0.08** (Gate: ≤ 0.20) -> PASS.
