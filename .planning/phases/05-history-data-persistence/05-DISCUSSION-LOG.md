# Phase 5: History & Data Persistence - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-06-29
**Phase:** 05-history-data-persistence
**Areas discussed:** Unification des types d'enregistrements, Stratégie FIFO 100 entrées, Injection de StorageService, Disposition des éléments de liste

---

## Unification des types d'enregistrements

### Comment fusionner ScanRecord et GenerationRecord pour l'affichage liste ?

| Option | Description | Selected |
|--------|-------------|----------|
| Classe de base commune | Créer RecordBase abstraite avec champs communs, sous-classes ScanRecord/GenerationRecord | ✓ |
| Modèle unifié HistoryRecord | Un seul modèle avec tous les champs + type enum | |
| Tu décides | L'agent choisit l'approche | |

**User's choice:** Classe de base commune
**Notes:** Typée forte et évolutive. Fichier séparé record_base.dart.

### RecordBase doit-elle avoir une factory fromJson polymorphique ?

| Option | Description | Selected |
|--------|-------------|----------|
| Factory polymorphique | RecordBase.fromJson détecte le type et retourne la bonne sous-classe | |
| Charger séparément | Garder les méthodes séparées, combiner en mémoire | |
| Tu décides | L'agent choisit | ✓ |

**User's choice:** Tu décides
**Notes:** L'agent choisira le pattern le plus adapté au code existant.

### Où placer la classe de base RecordBase ?

| Option | Description | Selected |
|--------|-------------|----------|
| Nouveau fichier record_base.dart | Un seul fichier dédié dans lib/models/ | ✓ |
| Dans le même fichier qu'un des modèles | Ajouter RecordBase dans scan_record.dart ou generation_record.dart | |
| Tu décides | L'agent choisit | |

**User's choice:** Nouveau fichier record_base.dart
**Notes:** Respecte la séparation des modèles existants.

### StorageService doit-il avoir une méthode getHistory() ?

| Option | Description | Selected |
|--------|-------------|----------|
| Méthode getHistory() | Une seule méthode qui charge les deux tables et retourne une liste untriée | ✓ |
| Combiner dans le ViewModel | Le ViewModel appelle les deux méthodes et fusionne | |
| Tu décides | L'agent choisit | |

**User's choice:** Oui, méthode getHistory()
**Notes:** Le ViewModel n'a pas à combiner — StorageService expose une interface unifiée.

---

## Stratégie FIFO 100 entrées

### Où implémenter la logique FIFO ?

| Option | Description | Selected |
|--------|-------------|----------|
| Dans le ViewModel | HistoryViewModel vérifie le count après insertion | |
| Dans StorageService | Service vérifie et supprime automatiquement | |
| Dans les deux | ViewModel déclenche, Service applique | ✓ |
| Tu décides | L'agent choisit | |

**User's choice:** Dans les deux (ViewModel + Service)
**Notes:** Double vérification pour robustesse.

### La suppression FIFO s'applique-t-elle ensemble ou séparément ?

| Option | Description | Selected |
|--------|-------------|----------|
| Séparément par type | Max 100 scans ET max 100 générations indépendamment | |
| Ensemble (100 total) | 100 entrées au total mélangées | |
| Tu décides | L'agent choisit | ✓ |

**User's choice:** Tu décides
**Notes:** L'agent évaluera selon l'usage attendu.

### Suppression silencieuse ou avec notification ?

| Option | Description | Selected |
|--------|-------------|----------|
| Silencieuse | Pas de notification, la liste reste à 100 max | ✓ |
| Avec SnackBar | Notification "Ancienne entrée supprimée" | |
| Tu décides | L'agent choisit | |

**User's choice:** Silencieuse
**Notes:** Non intrusif, simple.

### Vérification à l'insertion ou aussi au démarrage ?

| Option | Description | Selected |
|--------|-------------|----------|
| À l'insertion seulement | Vérifier uniquement quand un enregistrement est ajouté | ✓ |
| Insertion + démarrage | Vérifier aussi au lancement de l'app | |
| Tu décides | L'agent choisit | |

**User's choice:** À l'insertion seulement
**Notes:** Pas de surcharge au démarrage.

---

## Injection de StorageService

### Comment injecter StorageService aux ViewModels ?

| Option | Description | Selected |
|--------|-------------|----------|
| Via createAppRouter() | Créer dans main.dart, passer au router, qui le passe aux ViewModels | |
| Singleton global | StorageService.instance accessible partout | |
| Tu décides | L'agent choisit | ✓ |

**User's choice:** Tu décides
**Notes:** Pattern existant avec PermissionService sera suivi.

### HistoryViewModel reçoit StorageService via constructeur ou load() ?

| Option | Description | Selected |
|--------|-------------|----------|
| Constructeur | HistoryViewModel(storageService: ...) | ✓ |
| Méthode load() | Créer le ViewModel vide, puis appeler load() | |
| Tu décides | L'agent choisit | |

**User's choice:** Constructeur
**Notes:** Cohérent avec ScannerViewModel et GeneratorViewModel.

### ScannerViewModel et GeneratorViewModel reçoivent StorageService ?

| Option | Description | Selected |
|--------|-------------|----------|
| Oui, injection via constructeur | Pour appeler insert après action utilisateur | ✓ |
| Non, passer au Widget | Le Widget appelle insert directement | |
| Tu décides | L'agent choisit | |

**User's choice:** Oui, injection via constructeur
**Notes:** Le ViewModel gère la logique métier d'insertion.

### createAppRouter() prend StorageService obligatoire ou optionnel ?

| Option | Description | Selected |
|--------|-------------|----------|
| Optionnel avec défaut | StorageService? storageService, crée SystemStorageService si null | ✓ |
| Obligatoire | Forcer le passage de StorageService | |
| Tu décides | L'agent choisit | |

**User's choice:** Optionnel avec défaut
**Notes:** Cohérent avec le pattern PermissionService existant.

---

## Disposition des éléments de liste

### Comment afficher chaque entrée dans la liste historique ?

| Option | Description | Selected |
|--------|-------------|----------|
| Carte avec icône type + contenu + timestamp | ListTile dans Card avec leading icon, title, trailing | ✓ |
| ListTile simple sans card | ListTile nu, plus minimaliste | |
| Tu décides | L'agent choisit | |

**User's choice:** Carte avec icône type + contenu + timestamp
**Notes:** Material 3 et épuré.

### Comment tronquer le contenu affiché dans la liste ?

| Option | Description | Selected |
|--------|-------------|----------|
| maxLines: 1 + ellipsis | Un seul ligne, overflow en ... | ✓ |
| maxLines: 2 + ellipsis | Deux lignes max | |
| Pas de troncation | Contenu complet | |
| Tu décides | L'agent choisit | |

**User's choice:** maxLines: 1 + ellipsis
**Notes:** Économique en espace, suffisant pour un aperçu.

### Comment formater le timestamp dans la liste ?

| Option | Description | Selected |
|--------|-------------|----------|
| Relatif (il y a 5 min, hier) | Format naturel pour les récentes, date complète pour les anciennes | ✓ |
| Date/heure complète | Format '29/06/2026 14:30' pour toutes | |
| Tu décides | L'agent choisit | |

**User's choice:** Relatif (il y a 5 min, hier)
**Notes:** Plus lisible naturellement.

### Pour le swipe-to-delete, quel widget et style de fond ?

| Option | Description | Selected |
|--------|-------------|----------|
| Dismissible + fond rouge avec icône poubelle | Widget natif Flutter, background rouge | ✓ |
| Dismissible + fond neutre | Fond gris ou sans couleur | |
| Tu décides | L'agent choisit | |

**User's choice:** Dismissible + fond rouge avec icône poubelle
**Notes:** Standard Material 3 et intuitif.

---

## the agent's Discretion

- Pattern exact de la factory `RecordBase.fromJson` (polymorphique vs chargement séparé + fusion)
- Limite FIFO séparée ou ensemble par type
- Détails visuels de la Card (ombre, bordure, padding exact)
- Seuil de transition du timestamp relatif vers la date complète
- Style exact du `AlertDialog` de confirmation
- Patterns d'URL et de contenu à afficher dans l'aperçu
- Implémentation concrète du nettoyage FIFO dans StorageService

## Deferred Ideas

- Export historique en CSV — v2 (DIFF-07)
- Push notifications pour nouveaux entrées historique — pas demandé pour v1
- Pagination/infinite scroll — 100 entrées max tient dans une liste scrollable
- Batch delete (sélection multiple) — suppression par swipe simple uniquement
- Écran détail historique (tap pour voir contenu complet) — contenu suffisamment court pour l'aperçu

---

*Discussion completed: 2026-06-29*
