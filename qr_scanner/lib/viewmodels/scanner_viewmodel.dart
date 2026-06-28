import 'package:flutter/foundation.dart';
import '../services/permission_service.dart';

class ScannerViewModel extends ChangeNotifier {
  final PermissionService _permissionService;

  ScannerViewModel({required PermissionService permissionService})
      : _permissionService = permissionService;

  bool _isCheckingPermission = true;
  bool get isCheckingPermission => _isCheckingPermission;

  bool _hasPermission = false;
  bool get hasPermission => _hasPermission;

  bool _isScanningLocked = false;
  bool get isScanningLocked => _isScanningLocked;

  Future<void> checkPermission() async {
    _isCheckingPermission = true;
    notifyListeners();
    try {
      _hasPermission = await _permissionService.hasCameraPermission();
    } finally {
      _isCheckingPermission = false;
      notifyListeners();
    }
  }

  Future<void> requestPermission() async {
    _isCheckingPermission = true;
    notifyListeners();
    try {
      _hasPermission = await _permissionService.requestCameraPermission();
    } finally {
      _isCheckingPermission = false;
      notifyListeners();
    }
  }

  Future<void> openSettings() async {
    await _permissionService.openSettings();
  }

  /// Traite la détection du code et renvoie true si le scan est accepté.
  Future<bool> handleQrCodeDetected(String code) async {
    if (_isScanningLocked || code.isEmpty) {
      return false;
    }

    _isScanningLocked = true;
    notifyListeners();

    // Libère le verrou de scan après un délai de 2 secondes (anti-rebond)
    Future.delayed(const Duration(seconds: 2), () {
      _isScanningLocked = false;
      notifyListeners();
    });

    return true;
  }
}
