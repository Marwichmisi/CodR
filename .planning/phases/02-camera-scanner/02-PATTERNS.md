# Phase 02: camera-scanner - Pattern Map

**Mapped:** 28 juin 2026
**Files analyzed:** 10
**Analogs found:** 6 / 10

## File Classification
| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
| :--- | :--- | :--- | :--- | :--- |
| `lib/services/permission_service.dart` | Service (Data Layer) | OS/Permissions -> App State | `lib/services/storage_service.dart` | Moyenne |
| `lib/viewmodels/scanner_viewmodel.dart` | ViewModel (Logic Layer) | Entrées UI -> Service -> Notification Vue | Aucun (Guidé par la skill `flutter-apply-architecture-best-practices`) | N/A |
| `lib/screens/scanner_overlay_painter.dart` | UI Helper (CustomPainter) | Dimensions et boite -> Dessin overlay sur canvas | Aucun | N/A |
| `lib/screens/scanner_screen.dart` | View (Presentation Layer) | Caméra preview / Contrôles -> Observe le ViewModel | `lib/screens/scanner_screen.dart` (existant) | Élevée |
| `lib/navigation/app_router.dart` | Configuration Routage | Charge l'écran initial de l'application | `lib/navigation/app_router.dart` (existant) | Élevée |
| `pubspec.yaml` | Configuration Dépendances | Déclare les packages utilisés dans l'application | `pubspec.yaml` (existant) | Élevée |
| `ios/Runner/Info.plist` | Configuration OS | Déclaratif (Autorisation matérielle iOS) | `ios/Runner/Info.plist` (existant) | Élevée |
| `android/app/src/main/AndroidManifest.xml` | Configuration OS | Déclaratif (Permissions matérielles Android) | `android/app/src/main/AndroidManifest.xml` (existant) | Élevée |
| `test/viewmodels/scanner_viewmodel_test.dart` | Test Unitaire (Logic) | Teste la logique métier et transition d'état | `test/models/scan_record_test.dart` | Moyenne |
| `test/screens/scanner_screen_test.dart` | Test de Widget (UI) | Teste le comportement visuel et cycle de vie | `test/screens/navigation_test.dart` | Élevée |

## Pattern Assignments

### `lib/services/permission_service.dart`
**Analog:** `lib/services/storage_service.dart`
- **Imports pattern:** Importations de packages tiers et de composants internes séparés par un saut de ligne.
  ```dart
  import 'package:permission_handler/permission_handler.dart';
  ```
- **Auth pattern:** Non applicable (Aucune authentification dans cette phase).
- **State Management pattern:** Non applicable (Service sans état exposé).
- **Responsive Layout pattern:** Non applicable.
- **Widget Preview pattern:** Non applicable.
- **Widget Test pattern:** Les méthodes de service sont mockées dans les tests de widget et de ViewModel à l'aide de la bibliothèque `mocktail` en implémentant l'interface abstraite.

### `lib/viewmodels/scanner_viewmodel.dart`
**Analog:** Aucun (Modèle d'architecture issu de la compétence `flutter-apply-architecture-best-practices`).
- **Imports pattern:**
  ```dart
  import 'package:flutter/foundation.dart';
  import '../services/permission_service.dart';
  ```
- **Auth pattern:** Non applicable (Aucune authentification dans cette phase).
- **State Management pattern:** Utilisation de `ChangeNotifier` pour notifier l'UI lors de la mise à jour des états réactifs (`hasPermission`, `isCheckingPermission`, `isScanningLocked`). Les variables privées avec accesseurs en lecture seule (`get`) protègent l'état contre les mutations directes par la vue.
  ```dart
  class ScannerViewModel extends ChangeNotifier {
    bool _isScanningLocked = false;
    bool get isScanningLocked => _isScanningLocked;
    
    // Modification d'état...
    notifyListeners();
  }
  ```
- **Responsive Layout pattern:** Non applicable.
- **Widget Preview pattern:** Non applicable.
- **Widget Test pattern:** Tests unitaires isolés simulant le comportement de `PermissionService` avec `mocktail`.

### `lib/screens/scanner_overlay_painter.dart`
**Analog:** Aucun (Premier CustomPainter du projet).
- **Imports pattern:**
  ```dart
  import 'package:flutter/material.dart';
  ```
- **Auth pattern:** Non applicable.
- **State Management pattern:** Reçoit les paramètres immuables via son constructeur (`scanWindow`, `cornerColor`). Redessine uniquement si ces derniers changent (`shouldRepaint`).
- **Responsive Layout pattern:** Les dimensions de `scanWindow` sont transmises depuis l'UI responsive (calculées à partir de `LayoutBuilder` de la vue parente).
- **Widget Preview pattern:** Intégré dans l'aperçu de `ScannerScreen`.
- **Widget Test pattern:** Testé via le test de widget de `ScannerScreen` en vérifiant la présence du widget `CustomPaint` contenant ce painter.

### `lib/screens/scanner_screen.dart`
**Analog:** `lib/screens/scanner_screen.dart` (version initiale squelette)
- **Imports pattern:**
  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';
  import 'package:flutter/widget_previews.dart';
  import 'package:go_router/go_router.dart';
  import 'package:mobile_scanner/mobile_scanner.dart';
  import '../viewmodels/scanner_viewmodel.dart';
  import '../theme/app_theme.dart';
  import 'scanner_overlay_painter.dart';
  ```
- **Auth pattern:** Non applicable.
- **State Management pattern:** `StatefulWidget` gérant localement le cycle de vie du `MobileScannerController` (initialisation, démarrage/arrêt réactifs, et libération via `dispose`). L'observation des états du `ScannerViewModel` se fait via un `ListenableBuilder` pour éviter les reconstructions inutiles de tout l'arbre de widgets.
- **Responsive Layout pattern:** Utilisation de `LayoutBuilder` pour adapter dynamiquement la boîte de visée (`scanWindow`) : 70% de la largeur disponible, avec contrainte de taille `[200.0, 320.0]` dp.
  ```dart
  final double rawSize = width * 0.70;
  final double scanWindowSize = rawSize.clamp(200.0, 320.0);
  ```
- **Widget Preview pattern:** Utilisation de l'annotation `@Preview` de la compétence `flutter-add-widget-preview`. Pour la caméra, une injection de dépendance (Mock ou contrôleur réel) est utilisée.
  ```dart
  @Preview(name: 'Scanner Screen', group: 'Screens')
  Widget scannerPreview() {
    return MaterialApp(
      theme: buildLightTheme(),
      home: ScannerScreen(
        viewModel: ScannerViewModel(
          permissionService: SystemPermissionService(),
        ),
      ),
    );
  }
  ```
- **Widget Test pattern:** Test de widget via `WidgetTester` vérifiant le rendu réactif, le comportement du toggle de la torche, et l'affichage des SnackBars.

### `lib/navigation/app_router.dart`
**Analog:** `lib/navigation/app_router.dart` (existant)
- **Imports pattern:**
  ```dart
  import 'package:flutter/material.dart';
  import 'package:go_router/go_router.dart';
  import '../screens/scanner_screen.dart';
  ```
- **Auth pattern:** Non applicable.
- **State Management pattern:** `GoRouter` et `StatefulShellRoute.indexedStack`.
- **Responsive Layout pattern:** Utilise l'adaptation par défaut de `Scaffold` et `NavigationBar`.
- **Widget Preview pattern:** Non applicable pour le routeur global.
- **Widget Test pattern:** Les tests vérifient les redirections et la sélection d'onglets (comme dans `test/screens/navigation_test.dart`).

### `test/viewmodels/scanner_viewmodel_test.dart`
**Analog:** `test/models/scan_record_test.dart`
- **Imports pattern:**
  ```dart
  import 'package:flutter_test/flutter_test.dart';
  import 'package:mocktail/mocktail.dart';
  import 'package:qr_scanner/services/permission_service.dart';
  import 'package:qr_scanner/viewmodels/scanner_viewmodel.dart';
  ```
- **Auth pattern:** Non applicable.
- **State Management pattern:** Non applicable.
- **Responsive Layout pattern:** Non applicable.
- **Widget Preview pattern:** Non applicable.
- **Widget Test pattern:** Structure standard de tests unitaires utilisant des groupes (`group`) et des assertions (`expect`). Utilisation de `mocktail` pour mocker `PermissionService`.
  ```dart
  class MockPermissionService extends Mock implements PermissionService {}
  ```

### `test/screens/scanner_screen_test.dart`
**Analog:** `test/screens/navigation_test.dart` / `test/screens/responsive_test.dart`
- **Imports pattern:**
  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';
  import 'package:flutter_test/flutter_test.dart';
  import 'package:mocktail/mocktail.dart';
  import 'package:mobile_scanner/mobile_scanner.dart';
  import 'package:qr_scanner/screens/scanner_screen.dart';
  import 'package:qr_scanner/viewmodels/scanner_viewmodel.dart';
  import 'package:qr_scanner/services/permission_service.dart';
  ```
- **Auth pattern:** Non applicable.
- **State Management pattern:** Non applicable.
- **Responsive Layout pattern:** Modification de la taille physique de l'appareil dans les tests pour simuler les différents terminaux (phone/tablet) via `tester.view.physicalSize`.
  ```dart
  tester.view.physicalSize = const Size(360, 640);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  ```
- **Widget Preview pattern:** Non applicable.
- **Widget Test pattern:** Utilisation de `testWidgets` et `WidgetTester`. Mocks pour les dépendances matérielles/système pour éviter les blocages natifs.

## Shared Patterns

### Gestion MVVM Réactive
L'interface utilisateur s'abonne réactivement aux changements d'état du ViewModel via un widget `ListenableBuilder`, conformément à la compétence `flutter-apply-architecture-best-practices`. Les éléments de style et de design se conforment à `AppTheme`.

### Mocks de Périphériques pour les Tests
Tous les composants qui interagissent avec du matériel physique ou des services natifs (`MobileScannerController`, `PermissionService`) doivent exposer des interfaces d'injection de dépendances (dans le constructeur) permettant d'injecter des versions bouchonnées ou simulées dans l'environnement de test headless de Flutter.

### Calcul de Layout Centré Responsive
L'adaptation de la taille des composants est gérée en pourcentage de la largeur et hauteur maximales obtenues de `LayoutBuilder`, contraintes par des valeurs absolues via un appel `.clamp()`.

## No Analog Found

1. **`ScannerOverlayPainter` (CustomPainter) :** C'est le premier peintre personnalisé de l'application. Il n'a aucun analogue direct dans le code existant. Le pattern sera défini ici et servira de référence pour les futures interfaces de dessin personnalisé.
2. **`ScannerViewModel` (ViewModel) :** Il s'agit du premier composant ViewModel. Il introduit le pattern de gestion d'état centralisé par écran avec `ChangeNotifier`, remplaçant la logique d'état local de Flutter dans les écrans d'onglets simples.

## Metadata
*   **Phase :** 02 - camera-scanner
*   **Date de génération :** 28 juin 2026
*   **Ambiguïté résolue :** 0.03
