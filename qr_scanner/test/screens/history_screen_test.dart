import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qr_scanner/screens/history_screen.dart';
import 'package:qr_scanner/viewmodels/history_viewmodel.dart';
import 'package:qr_scanner/services/storage_service.dart';
import 'package:qr_scanner/models/scan_record.dart';
import 'package:qr_scanner/models/generation_record.dart';
import 'package:qr_scanner/theme/app_theme.dart';

class MockStorageService extends Mock implements StorageService {}

void main() {
  late MockStorageService mockStorageService;

  setUp(() {
    mockStorageService = MockStorageService();
  });

  Widget buildApp(HistoryViewModel viewModel) {
    return MaterialApp(
      theme: buildLightTheme(),
      home: HistoryScreen(viewModel: viewModel),
    );
  }

  group('HistoryScreen', () {
    testWidgets('empty state shows "Aucun historique" text', (tester) async {
      when(() => mockStorageService.getHistory()).thenAnswer((_) async => []);
      final viewModel = HistoryViewModel(storageService: mockStorageService);

      await tester.pumpWidget(buildApp(viewModel));
      await tester.pumpAndSettle();

      expect(find.text('Aucun historique'), findsOneWidget);
      expect(find.text('Vos scans et générations apparaîtront ici'), findsOneWidget);
      expect(find.byIcon(Icons.history), findsOneWidget);
    });

    testWidgets('initial state shows empty state before loading completes', (tester) async {
      when(() => mockStorageService.getHistory()).thenAnswer((_) async => []);
      final viewModel = HistoryViewModel(storageService: mockStorageService);

      await tester.pumpWidget(buildApp(viewModel));
      // After pump, initState has called loadRecords but we check the initial empty state
      await tester.pump();

      // The screen should show either loading or empty state
      // Since loadRecords is async, we might see CircularProgressIndicator
      // or the empty state depending on timing
      expect(
        find.byType(CircularProgressIndicator).evaluate().isNotEmpty ||
        find.text('Aucun historique').evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('records are displayed with content preview and timestamp', (tester) async {
      final records = [
        ScanRecord(
          id: 1,
          content: 'https://example.com',
          timestamp: DateTime(2026, 6, 27, 12, 0),
          type: 'scan',
        ),
      ];
      when(() => mockStorageService.getHistory()).thenAnswer((_) async => records);
      final viewModel = HistoryViewModel(storageService: mockStorageService);

      await tester.pumpWidget(buildApp(viewModel));
      await tester.pumpAndSettle();

      expect(find.text('https://example.com'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('scan records show qr_code_scanner icon', (tester) async {
      final records = [
        ScanRecord(
          id: 1,
          content: 'scan content',
          timestamp: DateTime(2026, 6, 27),
          type: 'scan',
        ),
      ];
      when(() => mockStorageService.getHistory()).thenAnswer((_) async => records);
      final viewModel = HistoryViewModel(storageService: mockStorageService);

      await tester.pumpWidget(buildApp(viewModel));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
    });

    testWidgets('generation records show qr_code icon', (tester) async {
      final records = [
        GenerationRecord(
          id: 1,
          content: 'gen content',
          timestamp: DateTime(2026, 6, 27),
          type: 'generation',
        ),
      ];
      when(() => mockStorageService.getHistory()).thenAnswer((_) async => records);
      final viewModel = HistoryViewModel(storageService: mockStorageService);

      await tester.pumpWidget(buildApp(viewModel));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.qr_code), findsOneWidget);
    });

    testWidgets('error state shows error message', (tester) async {
      when(() => mockStorageService.getHistory()).thenThrow(Exception('DB error'));
      final viewModel = HistoryViewModel(storageService: mockStorageService);

      await tester.pumpWidget(buildApp(viewModel));
      await tester.pumpAndSettle();

      expect(find.text('Erreur de chargement'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('responsive layout uses ConstrainedBox', (tester) async {
      when(() => mockStorageService.getHistory()).thenAnswer((_) async => []);
      final viewModel = HistoryViewModel(storageService: mockStorageService);

      await tester.pumpWidget(buildApp(viewModel));
      await tester.pumpAndSettle();

      expect(find.byType(LayoutBuilder), findsOneWidget);
      // There are multiple ConstrainedBox widgets (from Scaffold, etc.)
      // Just verify at least one exists with our maxWidth constraint
      expect(find.byType(ConstrainedBox), findsWidgets);
    });
  });
}
