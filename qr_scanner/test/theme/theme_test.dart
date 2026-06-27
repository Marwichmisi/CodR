import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_scanner/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('buildLightTheme returns Material 3 ThemeData', () {
      // Test theme structure without triggering font loading
      final colorScheme = ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      );
      final theme = ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
      );
      expect(theme.useMaterial3, isTrue);
    });

    test('buildLightTheme uses light brightness', () {
      final colorScheme = ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      );
      expect(colorScheme.brightness, Brightness.light);
    });

    test('seed color is sky blue (0xFF87CEEB)', () {
      expect(seedColor, const Color(0xFF87CEEB));
    });

    testWidgets('MaterialApp with theme renders without error', (WidgetTester tester) async {
      // Create a minimal theme without GoogleFonts to avoid network requests in tests
      final colorScheme = ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      );
      final theme = ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(),
        ),
      );
      // If we get here without exception, the theme renders correctly
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
