import 'package:permission_handler/permission_handler.dart';

abstract class PermissionService {
  Future<bool> hasCameraPermission();
  Future<bool> requestCameraPermission();
  Future<bool> openSettings();
  Future<bool> hasGalleryPermission();
  Future<bool> requestGalleryPermission();
}

class SystemPermissionService implements PermissionService {
  @override
  Future<bool> hasCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  @override
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  @override
  Future<bool> openSettings() async {
    return await openAppSettings();
  }

  @override
  Future<bool> hasGalleryPermission() async {
    // Check Permission.photos first (iOS), fall back to Permission.storage (Android)
    final photosStatus = await Permission.photos.status;
    if (photosStatus.isGranted) return true;

    final storageStatus = await Permission.storage.status;
    return storageStatus.isGranted;
  }

  @override
  Future<bool> requestGalleryPermission() async {
    // Request Permission.photos first (iOS), fall back to Permission.storage (Android)
    final photosStatus = await Permission.photos.request();
    if (photosStatus.isGranted) return true;

    final storageStatus = await Permission.storage.request();
    return storageStatus.isGranted;
  }
}
