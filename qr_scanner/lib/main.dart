import 'package:flutter/material.dart';

void main() {
  runApp(const QRScannerApp());
}

class QRScannerApp extends StatelessWidget {
  const QRScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Scanner',
      home: const Scaffold(
        body: Center(
          child: Text('QR Scanner'),
        ),
      ),
    );
  }
}
