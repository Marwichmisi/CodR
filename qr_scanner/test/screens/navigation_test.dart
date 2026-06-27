import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_scanner/navigation/app_router.dart';

void main() {
  group('Navigation', () {
    testWidgets('app launches on Scanner screen', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: appRouter));
      await tester.pumpAndSettle();
      expect(find.text('Scanner'), findsWidgets);
    });

    testWidgets('bottom nav has 3 tabs with correct labels',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: appRouter));
      await tester.pumpAndSettle();
      expect(find.text('Scanner'), findsWidgets);
      expect(find.text('Générateur'), findsOneWidget);
      expect(find.text('Historique'), findsOneWidget);
    });

    testWidgets('tapping Generator tab shows Generator screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: appRouter));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Générateur'));
      await tester.pumpAndSettle();
      expect(find.text('Créez un QR code à partir de texte'), findsOneWidget);
    });

    testWidgets('tapping History tab shows History screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: appRouter));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Historique'));
      await tester.pumpAndSettle();
      expect(find.text('Vos scans et générations récents'), findsOneWidget);
    });

    testWidgets('tapping Scanner tab returns to Scanner screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: appRouter));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Générateur'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Scanner'));
      await tester.pumpAndSettle();
      expect(find.text('Pointez votre caméra vers un QR code'), findsOneWidget);
    });
  });
}
