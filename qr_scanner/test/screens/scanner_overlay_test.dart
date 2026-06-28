import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_scanner/screens/scanner_overlay_painter.dart';

void main() {
  testWidgets('ScannerOverlayPainter renders without crashing', (tester) async {
    const scanWindow = Rect.fromLTWH(50, 50, 200, 200);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomPaint(
            painter: ScannerOverlayPainter(
              scanWindow: scanWindow,
              cornerColor: Colors.blue,
            ),
            child: const SizedBox(
              width: 300,
              height: 300,
            ),
          ),
        ),
      ),
    );

    expect(find.byWidgetPredicate((widget) => widget is CustomPaint && widget.painter is ScannerOverlayPainter), findsOneWidget);
  });
}
