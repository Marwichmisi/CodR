# Phase 3: scan-results-content-display - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-06-28
**Phase:** 03-scan-results-content-display
**Areas discussed:** Conception UI du Bottom Sheet, Détection de types & Regex, Pause/Reprise de la caméra, Gestion d'erreur & Retry

---

## Conception UI du Bottom Sheet

| Option | Description | Selected |
|--------|-------------|----------|
| Boutons horizontaux | (Recommandé) Boutons d'action principaux disposés en ligne horizontale (icône + texte court) pour un rendu moderne et compact. | ✓ |
| Liste verticale | Une liste verticale d'éléments (ListTile avec icône + texte descriptif) offrant plus de clarté pour chaque action. | |
| Gros bouton bas | Un gros bouton contextuel principal en pleine largeur tout en bas, avec les boutons secondaires (Copier, Partager) côte à côte au-dessus. | |

**User's choice:** Boutons horizontaux
**Notes:** -

### Affichage texte volumineux
| Option | Description | Selected |
|--------|-------------|----------|
| Zone scrollable max | (Recommandé) Dans un conteneur scrollable avec hauteur maximale (ex: 150dp à 200dp) pour éviter de masquer tout l'écran. | ✓ |
| Scrolling global | Affichage complet sans limite de hauteur avec scrolling global du bottom sheet. | |
| Affichage tronqué | Affichage tronqué à 3 lignes avec un bouton "Afficher tout" pour étendre la zone de texte. | |

**User's choice:** Zone scrollable max
**Notes:** -

### Responsivité tablette
| Option | Description | Selected |
|--------|-------------|----------|
| Largeur contrainte | (Recommandé) Centrer le bottom sheet avec une largeur maximale contrainte (ex: 500dp max) pour un rendu équilibré sur grand écran. | ✓ |
| Pleine largeur | S'étirer sur toute la largeur de l'écran (comportement par défaut, mais peut paraître trop étiré). | |
| Agent décide | Vous décidez (l'agent choisira la meilleure option ergonomique au moment du dev). | |

**User's choice:** Largeur contrainte
**Notes:** -

### Poignée de glissement
| Option | Description | Selected |
|--------|-------------|----------|
| Poignée standard | (Recommandé) Utiliser la poignée de glissement Material 3 standard (showDragHandle: true) en haut du sheet. | ✓ |
| Pas de poignée | Pas de poignée visuelle, s'appuyer uniquement sur le bouton de fermeture explicite et le geste naturel. | |
| Poignée + Croix | Ajouter une poignée de glissement (drag handle) ET un bouton Fermer (icône croix) en haut à droite. | |

**User's choice:** Poignée standard
**Notes:** -

---

## Détection de types & Regex

### Sensibilité URL
| Option | Description | Selected |
|--------|-------------|----------|
| URL absolue http(s) | (Recommandé) Détection stricte uniquement des URLs absolues commençant par "http://" ou "https://" pour éviter tout comportement dangereux. | ✓ |
| URLs sans protocole | Détection élargie incluant les domaines sans protocole (ex: "flutter.dev", en ajoutant automatiquement "https://" à l'ouverture). | |
| Custom schemes | Accepter tous les schémas d'URL (y compris les Custom Schemes comme "custom://"), mais filtrer explicitement les schémas à risque (javascript:, file:, data:). | |

**User's choice:** URL absolue http(s)
**Notes:** -

### Validation E-mail
| Option | Description | Selected |
|--------|-------------|----------|
| Regex standardisée | (Recommandé) Regex standard standardisée (ex: ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$) pour une bonne balance précision/simplicité. | ✓ |
| Validation souple | Validation souple : vérifier simplement la présence d'un caractère "@" et d'au moins un point après celui-ci. | |

**User's choice:** Regex standardisée
**Notes:** -

### Validation Téléphone
| Option | Description | Selected |
|--------|-------------|----------|
| Regex souple | (Recommandé) Regex souple acceptant le format international (commençant par "+") et le format national (de 9 à 14 chiffres, acceptant espaces/tirets/parenthèses). | ✓ |
| Regex stricte | Regex stricte imposant uniquement les chiffres et le "+" optionnel au début, sans séparateurs (espaces/tirets). | |
| Agent décide | Vous décidez (l'agent choisira la regex standard la plus robuste au moment du dev). | |

**User's choice:** Regex souple
**Notes:** -

### Texte mixte
| Option | Description | Selected |
|--------|-------------|----------|
| Traité en brut | (Recommandé) Traiter tout le texte comme brut (pas d'action contextuelle) ; le bouton contextuel n'apparaît que si le texte nettoyé (trim) correspond à 100% à une URL/email/téléphone pur. | ✓ |
| Extraction premier | Extraire la première URL, le premier email ou téléphone trouvé au sein du texte mixte et l'associer au bouton d'action contextuelle, tout en affichant le texte complet. | |

**User's choice:** Traité en brut
**Notes:** -

---

## Pause/Reprise de la caméra

### Suspension caméra
| Option | Description | Selected |
|--------|-------------|----------|
| Arrêt complet | (Recommandé) Appeler _controller.stop() à l'ouverture pour figer le flux de la caméra et libérer les ressources système. | ✓ |
| Verrou logique | Garder le flux caméra actif, mais utiliser un verrou logique dans le ViewModel pour ignorer tout nouveau scan tant que le bottom sheet est visible (plus fluide mais consomme plus d'énergie). | |

**User's choice:** Arrêt complet
**Notes:** -

### Callback reprise
| Option | Description | Selected |
|--------|-------------|----------|
| whenComplete M3 | (Recommandé) Utiliser le callback ".whenComplete()" de showModalBottomSheet() pour appeler systématiquement _controller.start() lors de la fermeture (gère swipe-down, bouton, et clic extérieur). | ✓ |
| Gestion manuelle | Gérer manuellement dans chaque bouton de fermeture, et interdire la fermeture par swipe-down ou clic extérieur (fermeture uniquement par bouton Fermer). | |

**User's choice:** whenComplete M3
**Notes:** -

### Transitions asynchrones
| Option | Description | Selected |
|--------|-------------|----------|
| Gestion silencieuse | (Recommandé) Gérer les exceptions silencieusement et vérifier _controller.isInitialized avant d'appeler start()/stop() pour éviter les plantages ou états incohérents. | ✓ |
| Await stop | Attendre la fin asynchrone complète (await) de stop() avant d'afficher le bottom sheet (peut ajouter un délai visible à l'écran). | |
| Agent décide | Vous décidez (l'agent choisira la meilleure approche robuste lors du codage). | |

**User's choice:** Gestion silencieuse
**Notes:** -

### Délai de garde
| Option | Description | Selected |
|--------|-------------|----------|
| Verrou court post-fermeture | (Recommandé) Conserver ou réactiver un verrou court (ex: 1 à 2 secondes) après la fermeture pour laisser le temps de déplacer le téléphone sans re-scanner instantanément. | ✓ |
| Scanner immédiat | Aucun verrou post-fermeture ; le scanner est immédiatement disponible pour scanner dès la fermeture du bottom sheet. | |

**User's choice:** Verrou court post-fermeture
**Notes:** -

---

## Gestion d'erreur & Retry

### UI Erreur
| Option | Description | Selected |
|--------|-------------|----------|
| Design dédié | (Recommandé) Afficher le bottom sheet avec un design d'erreur dédié : icône d'avertissement rouge, message explicite ("Code QR vide ou invalide"), et les boutons "Réessayer" et "Fermer". | ✓ |
| SnackBar | Afficher une simple SnackBar d'erreur sans ouvrir de bottom sheet (le scan reprend automatiquement). | |
| Boîte dialogue | Utiliser une boîte de dialogue standard (AlertDialog) au-dessus de l'écran de scan au lieu du bottom sheet pour forcer l'attention. | |

**User's choice:** Design dédié
**Notes:** -

### Retry action
| Option | Description | Selected |
|--------|-------------|----------|
| Fermer + relancer | (Recommandé) Fermer le bottom sheet d'erreur puis relancer immédiatement le scan de la caméra (en libérant le verrou). | ✓ |
| Réinitialiser sur place | Réinitialiser l'état mais laisser le bottom sheet ouvert (l'utilisateur doit le fermer lui-même). | |

**User's choice:** Fermer + relancer
**Notes:** -

### Espaces vides
| Option | Description | Selected |
|--------|-------------|----------|
| Erreur après trim | (Recommandé) Le catégoriser comme contenu invalide après trim() et ouvrir le bottom sheet en état d'erreur. | ✓ |
| Ignorer silencieusement | L'ignorer silencieusement sans retour visuel (la caméra continue de scanner). | |

**User's choice:** Erreur après trim
**Notes:** -

### Actions sur erreur
| Option | Description | Selected |
|--------|-------------|----------|
| Masquer / Désactiver | (Recommandé) Masquer ou désactiver complètement les boutons "Copier" et "Partager" pour éviter que l'utilisateur n'exporte du vide. | ✓ |
| Boutons grisés | Garder les boutons affichés mais inactifs avec un retour visuel grisé. | |
| Agent décide | Vous décidez (l'agent choisira la meilleure option ergonomique au moment du dev). | |

**User's choice:** Masquer / Désactiver
**Notes:** -

---

## the agent's Discretion

Aucune (l'agent suivra scrupuleusement les choix recommandés et appliquera les skills Flutter).

## Deferred Ideas

Aucune.
