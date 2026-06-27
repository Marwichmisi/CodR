import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const QRScannerApp());
}

class QRScannerApp extends StatelessWidget {
  const QRScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Scanner',
      theme: buildLightTheme(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('QR Scanner'),
        ),
        body: const Center(
          child: Text('QR Scanner'),
        ),
      ),
    );
  }
}
