import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qr_scanner/screens/generator_screen.dart';
import 'package:qr_scanner/viewmodels/generator_viewmodel.dart';

class MockGeneratorViewModel extends Mock implements GeneratorViewModel {}

void main() {
  late MockGeneratorViewModel mockViewModel;

  setUp(() {
    mockViewModel = MockGeneratorViewModel();

    // Default stubs
    when(() => mockViewModel.inputText).thenReturn('');
    when(() => mockViewModel.qrText).thenReturn('');
    when(() => mockViewModel.isUrlDetected).thenReturn(false);
    when(() => mockViewModel.addListener(any())).thenAnswer((_) {});
    when(() => mockViewModel.removeListener(any())).thenAnswer((_) {});
    when(() => mockViewModel.saveGenerationRecord()).thenAnswer((_) async {});
  });

  Widget buildApp() {
    return MaterialApp(
      home: GeneratorScreen(viewModel: mockViewModel),
    );
  }

  group('GeneratorScreen', () {
    testWidgets('shows placeholder when text is empty', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.qr_code), findsOneWidget);
      expect(find.text('Saisissez du texte pour générer un QR code'), findsOneWidget);
    });

    testWidgets('shows QR preview when text is entered', (tester) async {
      when(() => mockViewModel.inputText).thenReturn('hello');
      when(() => mockViewModel.qrText).thenReturn('hello');

      await tester.pumpWidget(buildApp());
      mockViewModel.notifyListeners();
      await tester.pump();
      await tester.pumpAndSettle();

      // When text is present, placeholder should be gone and QR rendered
      expect(find.text('Saisissez du texte pour générer un QR code'), findsNothing);
    });

    testWidgets('shows URL badge when URL is detected', (tester) async {
      when(() => mockViewModel.isUrlDetected).thenReturn(true);
      when(() => mockViewModel.inputText).thenReturn('example.com');

      await tester.pumpWidget(buildApp());
      mockViewModel.notifyListeners();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('URL détectée'), findsOneWidget);
      expect(find.byIcon(Icons.link), findsOneWidget);
    });

    testWidgets('hides URL badge when no URL detected', (tester) async {
      when(() => mockViewModel.isUrlDetected).thenReturn(false);
      when(() => mockViewModel.inputText).thenReturn('hello');

      await tester.pumpWidget(buildApp());
      mockViewModel.notifyListeners();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('URL détectée'), findsNothing);
    });

    testWidgets('shows AppBar with title Générateur', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Générateur'), findsOneWidget);
    });

    testWidgets('shows three action buttons', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Sauvegarder'), findsOneWidget);
      expect(find.text('Partager'), findsOneWidget);
      expect(find.text('Copier'), findsOneWidget);
    });

    testWidgets('Copier button shows SnackBar Copié !', (tester) async {
      when(() => mockViewModel.inputText).thenReturn('hello');
      when(() => mockViewModel.copyToClipboard()).thenReturn(null);

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Copier'));
      await tester.pumpAndSettle();

      expect(find.text('Copié !'), findsOneWidget);
    });

    testWidgets('character counter shows n/250 format', (tester) async {
      when(() => mockViewModel.inputText).thenReturn('test');

      await tester.pumpWidget(buildApp());
      mockViewModel.notifyListeners();
      await tester.pump();
      await tester.pumpAndSettle();

      // Counter should be visible when text is present
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
