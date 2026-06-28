# Phase 2: Camera Scanner - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-06-28
**Phase:** 02-camera-scanner
**Areas discussed:** Liaison MVVM et gestion d'état, Rendu de l'overlay de guidage, Affichage temporaire du QR Code scanné, Stratégie de tests de widgets et mocking

---

## Liaison MVVM et gestion d'état

| Option | Description | Selected |
|--------|-------------|----------|
| Option A | (Recommandé) Widget gère MobileScannerController en interne (StatefulWidget) et notifie le ViewModel des détections. | ✓ |
| Option B | Le ViewModel instancie et gère le contrôleur de caméra, puis l'injecte dans le Widget. | |
| Option C | Vous décidez (Laisser l'agent choisir la meilleure intégration). | |

**User's choice:** Option A
**Notes:** Isole la dépendance matérielle de la caméra dans l'UI pour un meilleur respect des couches.

| Option | Description | Selected |
|--------|-------------|----------|
| Option A | (Recommandé) Le ViewModel expose un état réactif via un service abstrait, et le Widget s'y abonne pour s'afficher ou se rediriger. | ✓ |
| Option B | L'UI gère directement la vérification et la demande de permissions avec permission_handler de manière autonome. | |
| Option C | Vous décidez. | |

**User's choice:** Option A
**Notes:** Garantit que l'état d'autorisation et le flux de navigation restent sous le contrôle du ViewModel.

| Option | Description | Selected |
|--------|-------------|----------|
| Option A | (Recommandé) Dans le ViewModel, en filtrant les événements de détection successifs avec un état de chargement/verrouillage de 2s. | ✓ |
| Option B | Dans l'UI, en appelant directement start() / stop() sur le MobileScannerController pour suspendre le flux vidéo. | |
| Option C | Vous décidez. | |

**User's choice:** Option A
**Notes:** La logique de throttle métier est encapsulée côté ViewModel.

| Option | Description | Selected |
|--------|-------------|----------|
| Option A | (Recommandé) Dans l'UI (le Widget), déclenchée lors de la détection réussie en réponse à une notification ou événement du ViewModel. | ✓ |
| Option B | Dans le ViewModel, via un HapticService injecté. | |
| Option C | Vous décidez. | |

**User's choice:** Option A
**Notes:** Le retour tactile est géré en tant qu'effet secondaire UI pur.

---

## Rendu de l'overlay de guidage

| Option | Description | Selected |
|--------|-------------|----------|
| Option A | (Recommandé) Utiliser un CustomPainter avec PathOperation.difference pour dessiner un masque semi-transparent percé au centre. | ✓ |
| Option B | Utiliser une Stack de conteneurs opaques/semi-transparents autour d'une zone vide. | |
| Option C | Vous décidez. | |

**User's choice:** Option A
**Notes:** Rendu net, précis et plus performant.

| Option | Description | Selected |
|--------|-------------|----------|
| Option A | (Recommandé) Dessiner les coins à l'aide de lignes épaisses dans le CustomPainter pour une précision parfaite. | ✓ |
| Option B | Utiliser un conteneur décoré (BoxDecoration) centré avec des bordures pour matérialiser les coins. | |
| Option C | Vous décidez. | |

**User's choice:** Option A
**Notes:** Tracé direct dans le CustomPainter pour éviter les calculs de Stack complexes.

| Option | Description | Selected |
|--------|-------------|----------|
| Option A | (Recommandé) Dimension dynamique basée sur la taille disponible (ex: 70% de la largeur avec min 200 et max 320). | ✓ |
| Option B | Taille fixe de 250x250 pixels indépendamment de la taille de l'écran. | |
| Option C | Vous décidez. | |

**User's choice:** Option A
**Notes:** Rend l'overlay responsive sur téléphones et tablettes.

| Option | Description | Selected |
|--------|-------------|----------|
| Option A | Non, pas d'animation de balayage pour rester minimaliste et sobre. | ✓ |
| Option B | Oui, une ligne de balayage laser animée se déplaçant verticalement. | |
| Option C | Vous décidez. | |

**User's choice:** Option A
**Notes:** Pas de ligne de balayage (laser) animée pour respecter les directives minimalistes.

---

## Affichage temporaire du QR Code scanné

| Option | Description | Selected |
|--------|-------------|----------|
| Option A | (Recommandé) Utiliser une SnackBar standard en bas de l'écran, affichant le texte avec un bouton facultatif pour fermer. | ✓ |
| Option B | Concevoir un panneau (Widget personnalisé) superposé en bas de l'écran avec un slide-up de 3 secondes. | |
| Option C | Vous décidez. | |

**User's choice:** Option A
**Notes:** Utilisation du composant standard Flutter.

| Option | Description | Selected |
|--------|-------------|----------|
| Option A | (Recommandé) Fermer immédiatement la SnackBar précédente et afficher la nouvelle pour un retour instantané. | ✓ |
| Option B | Ignorer les nouveaux résultats tant que la SnackBar active est affichée. | |
| Option C | Vous décidez. | |

**User's choice:** Option A
**Notes:** Expérience utilisateur plus réactive en cas de scans successifs.

| Option | Description | Selected |
|--------|-------------|----------|
| Option A | (Recommandé) Prévoir déjà un bouton d'action "Ouvrir" dans la SnackBar si le texte ressemble à un lien URL. | ✓ |
| Option B | Afficher uniquement le texte brut sans logique de bouton d'action. | |
| Option C | Vous décidez. | |

**User's choice:** Option A
**Notes:** Pré-câblage visuel de l'interaction URL pour la phase suivante.

---

## Stratégie de tests de widgets et mocking

| Option | Description | Selected |
|--------|-------------|----------|
| Option A | (Recommandé) Injecter un service wrapper ou un contrôleur de caméra mocké dans le constructeur de l'écran ou le fournisseur d'état. | ✓ |
| Option B | Remplacer le widget de la caméra par un composant fictif lors de la construction de test. | |
| Option C | Vous décidez. | |

**User's choice:** Option A
**Notes:** Injection de mocks classiques pour tester l'écran de façon déconnectée du matériel.

| Option | Description | Selected |
|--------|-------------|----------|
| Option A | (Recommandé) Déclencher manuellement le callback de détection (onDetect) sur le widget ou via le mock de contrôleur dans le test. | ✓ |
| Option B | Créer un stream d'événements de détection dans le ViewModel permettant de pousser de fausses données de test. | |
| Option C | Vous décidez. | |

**User's choice:** Option A
**Notes:** Déclenchement manuel de `onDetect` dans le widget test.

| Option | Description | Selected |
|--------|-------------|----------|
| Option A | (Recommandé) Mock-er le PermissionService pour simuler le refus permanent, cliquer sur le bouton et vérifier l'appel de openAppSettings() avec Mocktail. | ✓ |
| Option B | Se limiter à tester l'apparition du bouton d'erreur de permission à l'écran sans vérifier l'appel d'ouverture des paramètres. | |
| Option C | Vous décidez. | |

**User's choice:** Option A
**Notes:** Vérification rigoureuse du flux d'erreur de permission.

---

## the agent's Discretion

Les éléments mineurs de style, les marges de l'UI et l'enregistrement de l'injection de dépendances concrètes sont laissés à la discrétion de l'agent.

## Deferred Ideas

Aucune idée différée hors périmètre n'a été introduite dans cette discussion.
