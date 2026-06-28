import 'package:permission_handler/permission_handler.dart';

abstract class PermissionService {
  Future<bool> hasCameraPermission();
  Future<bool> requestCameraPermission();
  Future<bool> openSettings();
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
}
