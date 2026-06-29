import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/scanner_viewmodel.dart';
import '../viewmodels/result_viewmodel.dart';
import '../services/permission_service.dart';
import '../theme/app_theme.dart';
import '../widgets/scan_result_bottom_sheet.dart';
import 'scanner_overlay_painter.dart';

class ScannerScreen extends StatefulWidget {
  final ScannerViewModel viewModel;
  final ResultViewModel resultViewModel;
  final MobileScannerController? mockController; // Permet d'injecter un mock en test

  const ScannerScreen({
    required this.viewModel,
    required this.resultViewModel,
    this.mockController,
    super.key,
  });

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with WidgetsBindingObserver {
  late MobileScannerController _controller;
  bool _isControllerInitialized = false;

  GoRouter? _router;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Initialisation du contrôleur (mocké ou réel)
    _controller = widget.mockController ?? MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      autoStart: false,
    );
    
    widget.viewModel.checkPermission();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Subscribe to router changes for tab visibility
    try {
      final router = GoRouter.of(context);
      if (_router != router) {
        _router?.routerDelegate.removeListener(_onRouteChanged);
        _router = router;
        _router?.routerDelegate.addListener(_onRouteChanged);
      }
    } catch (_) {
      // In tests, GoRouter might not be present in the tree
    }
  }

  void _onRouteChanged() {
    if (!mounted || !_isControllerInitialized || !widget.viewModel.hasPermission) return;
    
    final location = _router?.routerDelegate.currentConfiguration.uri.toString() ?? '';
    final isActiveTab = location.startsWith('/scanner');
    
    if (isActiveTab) {
      _controller.start();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _router?.routerDelegate.removeListener(_onRouteChanged);
    WidgetsBinding.instance.removeObserver(this);
    // Libération des ressources de caméra
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isControllerInitialized || !widget.viewModel.hasPermission) return;

    // Coupe la caméra si l'application passe en arrière-plan
    if (state == AppLifecycleState.resumed) {
      final location = _router?.routerDelegate.currentConfiguration.uri.toString() ?? '';
      final isActiveTab = location.isEmpty || location.startsWith('/scanner');
      if (isActiveTab) {
        _controller.start();
      }
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        if (widget.viewModel.isCheckingPermission) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!widget.viewModel.hasPermission) {
          return _buildPermissionErrorScreen();
        }

        // Démarrage tardif lors de l'accès initial
        if (!_isControllerInitialized) {
          _isControllerInitialized = true;
          _controller.start();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Scanner'),
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;

              // Rendu responsive du cadre de visée : 70% largeur, [200, 320] dp
              final double rawSize = width * 0.70;
              final double scanWindowSize = rawSize.clamp(200.0, 320.0);

              final double left = (width - scanWindowSize) / 2;
              final double top = (height - scanWindowSize) / 2;

              final scanWindow = Rect.fromLTWH(left, top, scanWindowSize, scanWindowSize);

              return Stack(
                children: [
                  MobileScanner(
                    controller: _controller,
                    scanWindow: scanWindow,
                    onDetect: (capture) async {
                      final barcodes = capture.barcodes;
                      if (barcodes.isNotEmpty) {
                        final code = barcodes.first.rawValue ?? '';
                        final isAccepted = await widget.viewModel.handleQrCodeDetected(code);
                        if (isAccepted) {
                          HapticFeedback.vibrate();
                          _showScanResult(code);
                        }
                      }
                    },
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: ScannerOverlayPainter(
                        scanWindow: scanWindow,
                        cornerColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: ValueListenableBuilder(
                      valueListenable: _controller,
                      builder: (context, state, child) {
                        final isTorchOn = state.torchState == TorchState.on;
                        final isReady = state.isInitialized;
                        return FloatingActionButton(
                          mini: true,
                          elevation: 2,
                          backgroundColor: isTorchOn ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
                          tooltip: isTorchOn ? 'Éteindre la lampe' : 'Allumer la lampe',
                          onPressed: isReady ? () => _controller.toggleTorch() : null,
                          child: Icon(
                            isTorchOn ? Icons.flash_on : Icons.flash_off,
                            color: isTorchOn ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 32,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Text(
                          'Placez le code QR dans la zone de visée',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPermissionErrorScreen() {
    return Scaffold(
      appBar: AppBar(title: const Text('Accès à l\'appareil photo requis')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt, size: 64, color: Colors.red),
              const SizedBox(height: 24),
              const Text(
                'Accès à l\'appareil photo requis',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'L\'application a besoin d\'accéder à votre appareil photo pour pouvoir scanner des codes QR. Veuillez autoriser l\'accès dans les paramètres.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => widget.viewModel.requestPermission(),
                child: const Text('Autoriser l\'accès'),
              ),
              TextButton(
                onPressed: () => widget.viewModel.openSettings(),
                child: const Text('Ouvrir les paramètres'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showScanResult(String content) {
    // D-09 : Pause immédiate de la caméra
    if (_isControllerInitialized) {
      _controller.stop();
    }

    // Save scan record to history
    widget.viewModel.saveScanRecord(content);

    // Détecter le type de contenu
    widget.resultViewModel.detectContentType(content);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true, // D-04 : Poignée de glissement Material 3
      builder: (context) {
        return ScanResultBottomSheet(
          content: content,
          viewModel: widget.resultViewModel,
          onRetry: () {
            // Fermer le bottom sheet et relancer le scan
          },
          onClose: () {
            // Fermer le bottom sheet simplement
          },
        );
      },
    ).whenComplete(() {
      // D-10 : Reprendre la caméra quel que soit le mode de fermeture
      if (_isControllerInitialized) {
        _controller.start();
      }
      // D-12 : Debounce — court délai avant d'accepter de nouveaux scans
      Future.delayed(const Duration(seconds: 1), () {
        // Prêt pour le prochain scan
      });
    });
  }
}

// Previews
class _MockGrantedPermissionService implements PermissionService {
  @override
  Future<bool> hasCameraPermission() async => true;
  @override
  Future<bool> requestCameraPermission() async => true;
  @override
  Future<bool> openSettings() async => true;
  @override
  Future<bool> hasGalleryPermission() async => true;
  @override
  Future<bool> requestGalleryPermission() async => true;
}

class _MockDeniedPermissionService implements PermissionService {
  @override
  Future<bool> hasCameraPermission() async => false;
  @override
  Future<bool> requestCameraPermission() async => false;
  @override
  Future<bool> openSettings() async => true;
  @override
  Future<bool> hasGalleryPermission() async => false;
  @override
  Future<bool> requestGalleryPermission() async => false;
}

@Preview(name: 'Scanner Screen - Granted', group: 'Screens')
Widget scannerGrantedPreview() {
  return MaterialApp(
    theme: buildLightTheme(),
    home: ScannerScreen(
      viewModel: ScannerViewModel(permissionService: _MockGrantedPermissionService()),
      resultViewModel: ResultViewModel(),
    ),
  );
}

@Preview(name: 'Scanner Screen - Denied', group: 'Screens')
Widget scannerDeniedPreview() {
  return MaterialApp(
    theme: buildLightTheme(),
    home: ScannerScreen(
      viewModel: ScannerViewModel(permissionService: _MockDeniedPermissionService()),
      resultViewModel: ResultViewModel(),
    ),
  );
}

@Preview(name: 'SnackBar - Text', group: 'Screens')
Widget scannerSnackbarTextPreview() {
  return MaterialApp(
    theme: buildLightTheme(),
    home: Scaffold(
      body: Builder(
        builder: (context) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Code QR scanné : Hello World'),
                action: SnackBarAction(label: 'Fermer', onPressed: () {}),
              ),
            );
          });
          return const Center(child: Text('Prévisualisation SnackBar Texte'));
        },
      ),
    ),
  );
}

@Preview(name: 'SnackBar - URL', group: 'Screens')
Widget scannerSnackbarUrlPreview() {
  return MaterialApp(
    theme: buildLightTheme(),
    home: Scaffold(
      body: Builder(
        builder: (context) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Code QR scanné : https://flutter.dev'),
                action: SnackBarAction(label: 'Ouvrir le lien', onPressed: () {}),
              ),
            );
          });
          return const Center(child: Text('Prévisualisation SnackBar URL'));
        },
      ),
    ),
  );
}
