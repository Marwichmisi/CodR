# Phase 2: Camera Scanner — Spécifications

**Créé le :** 28 juin 2026
**Score d'ambiguïté :** 0.03 (seuil : ≤ 0.20)
**Exigences :** 7 verrouillées

## Objectif

Permettre à l'utilisateur de scanner des codes QR en temps réel via la caméra de son appareil avec une gestion robuste des permissions, du cycle de vie du contrôleur de caméra et une prévention des détections multiples.

## Contexte de base

Actuellement, l'application possède une architecture de navigation de base avec trois écrans. L'écran du scanner (`ScannerScreen`) est un simple composant statique affichant un texte d'instruction. L'intégration de la caméra avec le package `mobile_scanner`, la gestion des permissions avec `permission_handler` et la prévention des détections multiples n'existent pas encore.

## Exigences

1. **SCAN-01 : Scanner un QR code via caméra**
   - Current : `ScannerScreen` est un composant statique affichant un texte temporaire.
   - Target : `ScannerScreen` intègre le widget de caméra de `mobile_scanner` pour diffuser le flux de la caméra en temps réel.
   - Acceptance : La vue de la caméra est active et affiche un flux en temps réel, et un callback est déclenché lors de la détection d'un QR code.

2. **SCAN-02 : Gérer les permissions caméra**
   - Current : Aucune demande de permission caméra n'est implémentée.
   - Target : L'application vérifie la permission caméra via `permission_handler` à l'affichage de l'écran. Si elle est refusée ou définitivement refusée, un écran d'erreur s'affiche avec un bouton permettant d'ouvrir directement les paramètres système.
   - Acceptance : Le refus de la permission affiche l'écran d'erreur avec un bouton actif. Cliquer sur le bouton appelle `openAppSettings()`. L'acceptation de la permission active directement la caméra.

3. **SCAN-03 : Afficher un overlay de guide de scan**
   - Current : Aucun overlay n'est présent.
   - Target : Un overlay visuel semi-transparent avec une zone centrale claire (guide de scan) est affiché pour guider l'utilisateur.
   - Acceptance : L'overlay est centré, s'adapte de manière responsive aux écrans (téléphones/tablettes) et ne bloque pas la vue sous-jacente de la caméra.

4. **SCAN-04 : Bouton lampe/torche flottant**
   - Current : Aucun contrôle de la torche n'est disponible.
   - Target : Un bouton flottant superposé directement en haut à droite de l'overlay permet d'activer/désactiver la lampe de poche via le contrôleur de caméra.
   - Acceptance : Le bouton bascule l'état de la torche entre allumé et éteint. Le bouton est désactivé/ignoré si la caméra n'est pas initialisée.

5. **SCAN-05 : Cycle de vie du contrôleur de caméra**
   - Current : `ScannerScreen` ne gère pas le cycle de vie de la caméra.
   - Target : Un `WidgetsBindingObserver` est mis en place pour suspendre/reprendre le contrôleur de caméra lors des changements d'état de l'application (arrière-plan/premier plan) et pour libérer le contrôleur lors du changement d'onglet ou de la fermeture de l'écran.
   - Acceptance : Naviguer vers un autre onglet puis revenir restaure le flux de caméra immédiatement. Mettre l'application en arrière-plan puis au premier plan restaure le flux sans écran noir.

6. **SCAN-06 : Prévention des détections multiples et retour utilisateur**
   - Current : Aucun filtre sur le scan ou retour haptique n'existe.
   - Target : À la détection d'un QR code, l'application déclenche une vibration haptique (`HapticFeedback.vibrate()`), suspend temporairement le flux de détection (debounce/throttle de 2 secondes), et affiche temporairement le contenu scanné sur l'écran.
   - Acceptance : Scanner un QR code déclenche une seule vibration et un affichage temporaire unique du résultat. Les détections successives dans la fenêtre de 2 secondes sont ignorées.

7. **SCAN-07 (Obligatoire) : Usage exclusif des compétences Flutter**
   - Current : Projet structuré de base.
   - Target : L'agent développeur doit obligatoirement utiliser les compétences (skills) Flutter fournies sur le système (`flutter-apply-architecture-best-practices`, `flutter-build-responsive-layout`, `flutter-add-widget-test`, `flutter-add-widget-preview`) pour la structure, la responsivité, les tests de widgets et l'écriture de previews interactives.
   - Acceptance : Le code produit respecte rigoureusement l'architecture MVVM du projet et les critères de qualité définis dans les compétences Flutter locales.

## Limites

**Dans le périmètre (In scope) :**
- Intégration du package `mobile_scanner` et du widget de prévisualisation.
- Demande et gestion réactive des permissions avec redirection vers les paramètres système.
- Affichage de l'overlay de guidage de scan (responsive).
- Toggle de la lampe de poche via un bouton flottant superposé.
- Gestion du cycle de vie du contrôleur via le widget et l'application (arrière-plan).
- Vibration et debounce de 2 secondes lors du scan réussi.
- Affichage temporaire du texte scanné sur l'écran du scanner (en attente de la phase de résultats).

**Hors du périmètre (Out of scope) :**
- Redirection vers l'écran complet de résultats — *reporté à la Phase 3*.
- Enregistrement des scans dans la base de données locale SQLite — *reporté à la Phase 5*.
- Scan à partir d'une image de la galerie — *reporté à la v2 (DIFF-05)*.
- Prise en charge des formats de codes-barres autres que les QR codes — *reporté à la v2 (DIFF-04)*.

## Contraintes

- Le scanner doit fonctionner de manière fluide sur iOS et Android (avec les configurations de permissions nécessaires dans `AndroidManifest.xml` et `Info.plist`).
- L'usage des compétences Flutter installées est obligatoire pour guider l'agent de développement.

## Critères d'acceptation (Acceptance Criteria)

- [ ] L'écran du scanner demande la permission caméra uniquement à son ouverture (pas au démarrage global de l'app).
- [ ] Si la permission caméra est refusée, un écran d'erreur affiche un bouton menant aux paramètres du téléphone.
- [ ] Si la permission est accordée, la caméra affiche le flux vidéo en temps réel à l'intérieur de l'overlay de guide.
- [ ] Le bouton flottant permet d'allumer/éteindre la torche de l'appareil.
- [ ] Mettre l'application en arrière-plan puis revenir au premier plan restaure correctement le flux vidéo sans écran noir.
- [ ] À la détection d'un QR code, l'appareil vibre une seule fois et affiche temporairement le texte scanné à l'écran.
- [ ] Scanner le même QR code plusieurs fois en moins de 2 secondes ne déclenche qu'une seule fois la vibration et l'affichage.
- [ ] Les widgets créés comportent une preview interactive conforme au système de preview existant (`flutter-add-widget-preview`).
- [ ] Les tests de widgets existants et nouveaux s'exécutent avec succès (`flutter-add-widget-test`).

## Couverture des cas limites (Edge Coverage)

**Statut global :** 12/12 cas limites résolus · 0 non résolu

| Catégorie | Exigence | Statut | Résolution / Raison |
| :--- | :--- | :--- | :--- |
| **idempotency** | SCAN-01 | ⛔ dismissed | Dédoublonnage géré centralement au niveau de SCAN-06. |
| **concurrency** | SCAN-01 | ✅ covered | La caméra est mise en pause lors de la navigation ou de la mise en arrière-plan. |
| **idempotency** | SCAN-02 | ⛔ dismissed | `permission_handler` gère nativement les requêtes répétées. |
| **concurrency** | SCAN-02 | ⛔ dismissed | La transition est bloquée et gérée par l'OS pendant l'affichage du dialogue système. |
| **concurrency** | SCAN-03 | ⛔ dismissed | L'overlay est purement déclaratif et statique. |
| **idempotency** | SCAN-04 | ⛔ dismissed | L'activation/désactivation de la torche est binaire et idempotente. |
| **concurrency** | SCAN-04 | ✅ covered | Le bouton de la torche est désactivé si le contrôleur n'est pas prêt. |
| **idempotency** | SCAN-05 | ✅ covered | La libération et ré-initialisation sont gérées de manière sûre lors du cycle de vie du widget. |
| **concurrency** | SCAN-05 | ✅ covered | `didChangeAppLifecycleState` gère la libération immédiate en arrière-plan. |
| **idempotency** | SCAN-06 | ✅ covered | Un verrouillage de 2 secondes empêche toute nouvelle détection durant ce délai. |
| **concurrency** | SCAN-06 | ✅ covered | Les frames de caméra reçues en parallèle de l'émission de la vibration/résultat sont jetées si le verrou est actif. |
| **concurrency** | UI-02 | ⛔ dismissed | Composant de rendu UI piloté par l'état du ViewModel. |

## Prohibitions (must-NOT)

**Statut global :** 3/3 prohibitions résolues · 0 non résolue

| Prohibition (must-NOT statement) | Exigence | Statut | Vérification / Raison |
| :--- | :--- | :--- | :--- |
| Ne doit PAS demander la permission caméra immédiatement au lancement de l'application. | SCAN-02 | resolved | **verification: judgment** (vérifié manuellement pour garantir que la demande n'apparaît qu'au premier accès à l'onglet Scanner). |
| Ne doit PAS laisser le contrôleur de caméra actif ou la torche allumée lorsque l'écran du scanner n'est plus au premier plan ou que l'application est en arrière-plan. | SCAN-05 | resolved | **verification: test** (vérifié par test unitaire de cycle de vie dans `test/scanner_lifecycle_test.dart`).<br>• *check_kind:* `node-test`<br>• *check_target:* `test/scanner_lifecycle_test.dart`<br>• *check_violation_fixture:* `test/fixtures/bad_scanner_lifecycle.dart` |
| Ne doit PAS envoyer de données scannées ou de flux vidéo vers un serveur réseau externe (respect de la confidentialité locale). | SCAN-01 | resolved | **verification: judgment** (audit de sécurité du code pour s'assurer de l'absence de requêtes réseau). |

## Rapport d'Ambiguïté

| Dimension | Score | Min | Statut | Notes |
| :--- | :--- | :--- | :--- | :--- |
| **Clarté de l'objectif** | 0.98 | 0.75 | ✓ | Objectifs clairs et délimités |
| **Clarté des limites** | 0.95 | 0.70 | ✓ | Limites explicites entre les phases 2, 3 et 5 |
| **Clarté des contraintes** | 0.95 | 0.65 | ✓ | Utilisation obligatoire des compétences Flutter |
| **Critères d'acceptation** | 0.98 | 0.70 | ✓ | Critères pass/fail précis |
| **Ambiguity** | **0.03** | **≤0.20** | **✓** | **Prêt pour le développement** |

## Journal d'Interview

| Round | Perspective | Question summary | Decision locked |
| :--- | :--- | :--- | :--- |
| 1 | Gardien | Usage obligatoire des compétences (skills) Flutter locales | L'agent de développement doit impérativement s'appuyer sur les compétences de qualité locales. |
| 1 | Gardien | Comportement en cas de refus de permission caméra | Affichage d'un écran d'erreur avec un bouton redirigeant vers les paramètres système de l'appareil. |
| 1 | Gardien | Retour utilisateur au scan réussi | Déclenchement d'un retour haptique (vibration) à la détection. |
| 2 | Simplificateur | Fonctionnalités de caméra avancées (zoom, etc.) | Limité à la détection automatique simple (pas de slider de zoom). |
| 2 | Simplificateur | Position du bouton de lampe/torche | Bouton flottant directement superposé en haut à droite sur la vue caméra. |
| 3 | Gardien | Comportement temporaire de résultat | Affichage temporaire du texte scanné directement sur l'écran du scanner en attendant la Phase 3. |
| 3 | Gardien | Enregistrement SQLite immédiat | Aucun stockage SQLite dans cette phase, attend la Phase 5 dédiée. |

---

*Phase: 02-camera-scanner*
*Spécification créée le : 28 juin 2026*
*Prochaine étape : /gsd-discuss-phase 02 — Choix techniques et d'implémentation (gestion précise des dépendances, layout et tests).*
