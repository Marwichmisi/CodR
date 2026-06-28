import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qr_scanner/models/content_type.dart';
import 'package:qr_scanner/viewmodels/result_viewmodel.dart';
import 'package:qr_scanner/widgets/scan_result_bottom_sheet.dart';
import 'package:qr_scanner/theme/app_theme.dart';

class MockResultViewModel extends Mock implements ResultViewModel {}

/// Helper pour construire le widget dans un MaterialApp avec thème.
Widget buildApp({
  String content = 'Hello World',
  ResultViewModel? viewModel,
  VoidCallback? onRetry,
  VoidCallback? onClose,
}) {
  final vm = viewModel ?? ResultViewModel();
  vm.detectContentType(content);
  return MaterialApp(
    theme: buildLightTheme(),
    home: Scaffold(
      body: ScanResultBottomSheet(
        content: content,
        viewModel: vm,
        onRetry: onRetry,
        onClose: onClose,
      ),
    ),
  );
}

void main() {
  group('Content Display', () {
    testWidgets('displays scanned content for plain text', (tester) async {
      await tester.pumpWidget(buildApp(content: 'Hello World'));
      await tester.pumpAndSettle();

      expect(find.text('Hello World'), findsOneWidget);
      expect(find.text('Texte'), findsOneWidget); // ContentType.displayName
      expect(find.text('Copier le texte'), findsOneWidget);
      expect(find.text('Partager le contenu'), findsOneWidget);
    });

    testWidgets('displays "Ouvrir le lien" for URL (D-01)', (tester) async {
      await tester.pumpWidget(buildApp(content: 'https://flutter.dev'));
      await tester.pumpAndSettle();

      expect(find.text('https://flutter.dev'), findsOneWidget);
      expect(find.text('URL'), findsOneWidget);
      expect(find.text('Ouvrir le lien'), findsOneWidget);
      expect(find.byIcon(Icons.open_in_browser), findsOneWidget);
    });

    testWidgets('displays "Envoyer l\'e-mail" for email', (tester) async {
      await tester.pumpWidget(buildApp(content: 'user@example.com'));
      await tester.pumpAndSettle();

      expect(find.text('user@example.com'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text("Envoyer l'e-mail"), findsOneWidget);
      expect(find.byIcon(Icons.email), findsOneWidget);
    });

    testWidgets('displays "Appeler le numéro" for phone', (tester) async {
      await tester.pumpWidget(buildApp(content: '+33612345678'));
      await tester.pumpAndSettle();

      expect(find.text('+33612345678'), findsOneWidget);
      expect(find.text('Téléphone'), findsOneWidget);
      expect(find.text('Appeler le numéro'), findsOneWidget);
      expect(find.byIcon(Icons.phone), findsOneWidget);
    });

    testWidgets('displays Copy and Share for all content types', (tester) async {
      // URL
      await tester.pumpWidget(buildApp(content: 'https://flutter.dev'));
      await tester.pumpAndSettle();
      expect(find.text('Copier le texte'), findsOneWidget);
      expect(find.text('Partager le contenu'), findsOneWidget);

      // Email
      await tester.pumpWidget(buildApp(content: 'user@example.com'));
      await tester.pumpAndSettle();
      expect(find.text('Copier le texte'), findsOneWidget);
      expect(find.text('Partager le contenu'), findsOneWidget);

      // Phone
      await tester.pumpWidget(buildApp(content: '+33612345678'));
      await tester.pumpAndSettle();
      expect(find.text('Copier le texte'), findsOneWidget);
      expect(find.text('Partager le contenu'), findsOneWidget);
    });

    testWidgets('no contextual button for plain text', (tester) async {
      await tester.pumpWidget(buildApp(content: 'Hello World'));
      await tester.pumpAndSettle();

      expect(find.text('Ouvrir le lien'), findsNothing);
      expect(find.text("Envoyer l'e-mail"), findsNothing);
      expect(find.text('Appeler le numéro'), findsNothing);
    });
  });

  group('Error State', () {
    testWidgets('error state shows warning icon, message, Retry and Close buttons (D-13)', (tester) async {
      final viewModel = ResultViewModel();
      viewModel.detectContentType('');

      await tester.pumpWidget(MaterialApp(
        theme: buildLightTheme(),
        home: Scaffold(
          body: ScanResultBottomSheet(
            content: '',
            viewModel: viewModel,
            onRetry: () {},
            onClose: () {},
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.warning), findsOneWidget);
      expect(find.text('Code QR vide ou invalide'), findsOneWidget);
      expect(find.text('Réessayer'), findsOneWidget);
      expect(find.text('Fermer'), findsOneWidget);
    });

    testWidgets('Copy and Share buttons hidden in error state (D-16)', (tester) async {
      final viewModel = ResultViewModel();
      viewModel.detectContentType('');

      await tester.pumpWidget(MaterialApp(
        theme: buildLightTheme(),
        home: Scaffold(
          body: ScanResultBottomSheet(
            content: '',
            viewModel: viewModel,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Copier le texte'), findsNothing);
      expect(find.text('Partager le contenu'), findsNothing);
    });

    testWidgets('whitespace-only content shows error state (D-15)', (tester) async {
      final viewModel = ResultViewModel();
      viewModel.detectContentType('   ');

      await tester.pumpWidget(MaterialApp(
        theme: buildLightTheme(),
        home: Scaffold(
          body: ScanResultBottomSheet(
            content: '   ',
            viewModel: viewModel,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.warning), findsOneWidget);
      expect(find.text('Code QR vide ou invalide'), findsOneWidget);
      expect(find.text('Réessayer'), findsOneWidget);
      expect(find.text('Fermer'), findsOneWidget);
    });
  });

  group('Responsive Layout', () {
    testWidgets('uses LayoutBuilder and renders correctly', (tester) async {
      await tester.pumpWidget(buildApp(content: 'Test'));
      await tester.pumpAndSettle();

      // Verify the widget tree contains the expected structure
      expect(find.byType(ScanResultBottomSheet), findsOneWidget);
      expect(find.byType(LayoutBuilder), findsOneWidget);
    });
  });

  group('Actions', () {
    testWidgets('tap on Copy calls copyToClipboard on viewModel', (tester) async {
      final mockViewModel = MockResultViewModel();
      when(() => mockViewModel.contentType).thenReturn(ContentType.text);
      when(() => mockViewModel.hasError).thenReturn(false);
      when(() => mockViewModel.scannedContent).thenReturn('Test content');
      when(() => mockViewModel.addListener(any())).thenAnswer((_) {});
      when(() => mockViewModel.removeListener(any())).thenAnswer((_) {});
      when(() => mockViewModel.copyToClipboard('Test content')).thenAnswer((_) async {});

      await tester.pumpWidget(MaterialApp(
        theme: buildLightTheme(),
        home: Scaffold(
          body: ScanResultBottomSheet(
            content: 'Test content',
            viewModel: mockViewModel,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Copier le texte'));
      await tester.pumpAndSettle();

      verify(() => mockViewModel.copyToClipboard('Test content')).called(1);
    });

    testWidgets('tap on Share calls shareContent on viewModel', (tester) async {
      final mockViewModel = MockResultViewModel();
      when(() => mockViewModel.contentType).thenReturn(ContentType.text);
      when(() => mockViewModel.hasError).thenReturn(false);
      when(() => mockViewModel.scannedContent).thenReturn('Test content');
      when(() => mockViewModel.addListener(any())).thenAnswer((_) {});
      when(() => mockViewModel.removeListener(any())).thenAnswer((_) {});
      when(() => mockViewModel.shareContent('Test content')).thenAnswer((_) async {});

      await tester.pumpWidget(MaterialApp(
        theme: buildLightTheme(),
        home: Scaffold(
          body: ScanResultBottomSheet(
            content: 'Test content',
            viewModel: mockViewModel,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Partager le contenu'));
      await tester.pumpAndSettle();

      verify(() => mockViewModel.shareContent('Test content')).called(1);
    });
  });
}
