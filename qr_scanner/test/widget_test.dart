import 'package:flutter_test/flutter_test.dart';

import 'package:qr_scanner/main.dart';

void main() {
  testWidgets('App renders QR Scanner text', (WidgetTester tester) async {
    await tester.pumpWidget(const QRScannerApp());
    expect(find.text('QR Scanner'), findsOneWidget);
  });
}
