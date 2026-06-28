import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';
import '../viewmodels/scanner_viewmodel.dart';
import '../services/permission_service.dart';
import '../theme/app_theme.dart';
import 'scanner_overlay_painter.dart';

class ScannerScreen extends StatefulWidget {
  final ScannerViewModel viewModel;
  final MobileScannerController? mockController; // Permet d'injecter un mock en test

  const ScannerScreen({
    required this.viewModel,
    this.mockController,
    super.key,
  });

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with WidgetsBindingObserver {
  late MobileScannerController _controller;
  bool _isControllerInitialized = false;

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
  void dispose() {
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
      _controller.start();
    } else {
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
            actions: [
              ValueListenableBuilder(
                valueListenable: _controller,
                builder: (context, state, child) {
                  final isTorchOn = state.torchState == TorchState.on;
                  return IconButton(
                    icon: Icon(isTorchOn ? Icons.flash_on : Icons.flash_off),
                    color: isTorchOn ? Theme.of(context).colorScheme.primary : null,
                    tooltip: isTorchOn ? 'Éteindre la lampe' : 'Allumer la lampe',
                    onPressed: () => _controller.toggleTorch(),
                  );
                },
              ),
            ],
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
                        cornerColor: Colors.blue, // Using a basic blue instead of seedColor directly
                      ),
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
                          color: Colors.black.withOpacity(0.6),
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
    ScaffoldMessenger.of(context).clearSnackBars();
    
    final isUrl = Uri.tryParse(content)?.hasAbsolutePath ?? false;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Code QR scanné : $content'),
        action: SnackBarAction(
          label: isUrl ? 'Ouvrir le lien' : 'Fermer',
          onPressed: () {
            if (isUrl) {
              // Action pré-câblée (sera gérée en Phase 3)
            }
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );
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
}

class _MockDeniedPermissionService implements PermissionService {
  @override
  Future<bool> hasCameraPermission() async => false;
  @override
  Future<bool> requestCameraPermission() async => false;
  @override
  Future<bool> openSettings() async => true;
}

@Preview(name: 'Scanner Screen - Granted', group: 'Screens')
Widget scannerGrantedPreview() {
  return MaterialApp(
    theme: buildLightTheme(),
    home: ScannerScreen(
      viewModel: ScannerViewModel(permissionService: _MockGrantedPermissionService()),
    ),
  );
}

@Preview(name: 'Scanner Screen - Denied', group: 'Screens')
Widget scannerDeniedPreview() {
  return MaterialApp(
    theme: buildLightTheme(),
    home: ScannerScreen(
      viewModel: ScannerViewModel(permissionService: _MockDeniedPermissionService()),
    ),
  );
}
