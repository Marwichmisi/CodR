import 'package:flutter_test/flutter_test.dart';

import 'package:qr_scanner/main.dart';

void main() {
  testWidgets('App renders QR Scanner text', (WidgetTester tester) async {
    await tester.pumpWidget(const QRScannerApp());
    // AppBar title shows "QR Scanner"
    expect(find.text('QR Scanner'), findsOneWidget);
  });
}
