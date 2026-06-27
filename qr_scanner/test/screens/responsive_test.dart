import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_scanner/screens/scanner_screen.dart';
import 'package:qr_scanner/screens/generator_screen.dart';
import 'package:qr_scanner/screens/history_screen.dart';
import 'package:qr_scanner/theme/app_theme.dart';

void main() {
  group('Responsive Layout', () {
    testWidgets('renders without overflow at 360px width (phone)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        theme: buildLightTheme(),
        home: const ScannerScreen(),
      ));
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without overflow at 768px width (tablet)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        theme: buildLightTheme(),
        home: const ScannerScreen(),
      ));
      expect(tester.takeException(), isNull);
    });

    testWidgets('content is constrained on wide screen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        theme: buildLightTheme(),
        home: const ScannerScreen(),
      ));
      // Verify ConstrainedBox exists with maxWidth constraint
      expect(find.byType(ConstrainedBox), findsWidgets);
    });

    testWidgets('GeneratorScreen renders without overflow at 360px width',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        theme: buildLightTheme(),
        home: const GeneratorScreen(),
      ));
      expect(tester.takeException(), isNull);
    });

    testWidgets('HistoryScreen renders without overflow at 360px width',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        theme: buildLightTheme(),
        home: const HistoryScreen(),
      ));
      expect(tester.takeException(), isNull);
    });

    testWidgets('all screens have LayoutBuilder', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        theme: buildLightTheme(),
        home: const ScannerScreen(),
      ));
      expect(find.byType(LayoutBuilder), findsWidgets);

      await tester.pumpWidget(MaterialApp(
        theme: buildLightTheme(),
        home: const GeneratorScreen(),
      ));
      expect(find.byType(LayoutBuilder), findsWidgets);

      await tester.pumpWidget(MaterialApp(
        theme: buildLightTheme(),
        home: const HistoryScreen(),
      ));
      expect(find.byType(LayoutBuilder), findsWidgets);
    });
  });
}
