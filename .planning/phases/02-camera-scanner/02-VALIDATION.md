---
phase: 2
slug: camera-scanner
status: draft
nyquist_compliant: true
wave_0_complete: false
created: 2026-06-28
---

# Phase 2 — Validation Strategy

> Stratégie de validation par phase pour l'échantillonnage de feedback pendant l'exécution.

---

## Infrastructure de Test

| Propriété | Valeur |
|----------|-------|
| **Framework** | flutter_test / mocktail |
| **Fichier de config** | `qr_scanner/pubspec.yaml` (dépendances de dev) |
| **Commande d'exécution rapide** | `flutter test test/scanner_viewmodel_test.dart` |
| **Commande de la suite complète** | `flutter test` |
| **Temps d'exécution estimé** | ~5 secondes |

---

## Taux d'Échantillonnage (Sampling Rate)

- **Après chaque commit de tâche :** Lancer la commande d'exécution rapide `flutter test test/scanner_viewmodel_test.dart`
- **Après chaque vague du plan :** Lancer la commande de la suite complète `flutter test`
- **Avant `/gsd-verify-work` :** La suite complète doit être verte (tous les tests passent)
- **Latence de feedback maximale :** 10 secondes

---

## Cartographie de Vérification par Tâche

| ID de Tâche | Plan | Vague | Exigence | Réf Menace | Comportement Sécurisé | Type de Test | Commande Automatisée | Fichier Existe | Statut |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 02-01-01 | 01 | 1 | SCAN-02 | T-02-01 | Affiche l'erreur si permission refusée, ouvre les paramètres | widget | `flutter test test/screens/scanner_screen_test.dart` | ❌ W0 | ⬜ pending |
| 02-01-02 | 01 | 1 | SCAN-01 | — | Démarre la caméra si permission accordée | widget | `flutter test test/screens/scanner_screen_test.dart` | ❌ W0 | ⬜ pending |
| 02-01-03 | 01 | 1 | SCAN-03 | — | Dessine l'overlay de scan responsive | widget / goldens | `flutter test test/screens/scanner_overlay_test.dart` | ❌ W0 | ⬜ pending |
| 02-02-01 | 02 | 2 | SCAN-04 | — | Bouton torche désactivé si caméra non prête, actif sinon | widget | `flutter test test/screens/scanner_screen_test.dart` | ❌ W0 | ⬜ pending |
| 02-02-02 | 02 | 2 | SCAN-05 | — | Coupe la caméra lors de la mise en arrière-plan / changement d'onglet | widget | `flutter test test/screens/scanner_lifecycle_test.dart` | ❌ W0 | ⬜ pending |
| 02-03-01 | 03 | 3 | SCAN-06 | T-02-02 | vibration, verrou de 2s (debounce), SnackBar temporaire | unit / widget | `flutter test test/viewmodels/scanner_viewmodel_test.dart` | ❌ W0 | ⬜ pending |

*Statut : ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Exigences de la Vague 0 (Wave 0 Requirements)

- [ ] Création du mock de `PermissionService` dans `test/mocks/permission_service_mock.dart`
- [ ] Création du mock de `MobileScannerController` dans `test/mocks/mobile_scanner_controller_mock.dart`
- [ ] Configuration de base du framework de test avec Mocktail dans `test/viewmodels/scanner_viewmodel_test.dart`

---

## Vérifications Manuelles Uniquement

| Comportement | Exigence | Pourquoi Manuel | Instructions de Test |
|----------|-------------|------------|-------------------|
| Test sur appareil réel (Android / iOS) | SCAN-01, SCAN-04 | L'émulateur/simulateur ne reproduit pas le flux de caméra réel et la torche physique | 1. Lancer l'app sur un terminal réel.<br>2. Accéder à l'onglet Scanner.<br>3. Vérifier que le flux caméra s'affiche bien dans le cadre bleu.<br>4. Tester l'activation/désactivation de la lampe de poche (torche physique). |
| Demande de permission native | SCAN-02 | La boîte de dialogue de permission native de l'OS ne peut être déclenchée qu'une fois par installation | 1. Désinstaller et réinstaller l'app.<br>2. Aller sur l'onglet Scanner.<br>3. Vérifier que la boîte de dialogue système de demande de caméra apparaît.<br>4. Refuser la permission et vérifier la redirection vers l'écran d'erreur. |

---

## Validation Sign-Off

- [ ] Toutes les tâches ont une vérification `<automated>` ou des dépendances Vague 0
- [ ] Continuité d'échantillonnage : pas de 3 tâches consécutives sans vérification automatisée
- [ ] La Vague 0 couvre toutes les références MANQUANTES
- [ ] Pas de drapeaux de mode d'écoute (watch-mode)
- [ ] Latence du feedback < 10s
- [ ] `nyquist_compliant: true` défini dans le frontmatter

**Approbation :** pending
