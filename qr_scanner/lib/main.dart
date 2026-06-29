import 'package:flutter/material.dart';

import 'navigation/app_router.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QRScannerApp());
}

class QRScannerApp extends StatelessWidget {
  const QRScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storageService = StorageService();
    final appRouter = createAppRouter(storageService: storageService);
    return MaterialApp.router(
      title: 'QR Scanner',
      theme: buildLightTheme(),
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
