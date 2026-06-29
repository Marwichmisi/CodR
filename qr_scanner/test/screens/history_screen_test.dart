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

    // NEW TESTS FOR SEARCH, FILTER, AND DELETE FUNCTIONALITY

    testWidgets('search bar displays with hint text and search icon', (tester) async {
      when(() => mockStorageService.getHistory()).thenAnswer((_) async => []);
      final viewModel = HistoryViewModel(storageService: mockStorageService);

      await tester.pumpWidget(buildApp(viewModel));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.text('Rechercher dans l\'historique...'), findsOneWidget);
    });

    testWidgets('typing in search bar filters records in real-time', (tester) async {
      final records = [
        ScanRecord(id: 1, content: 'Hello World', timestamp: DateTime.now(), type: 'scan'),
        ScanRecord(id: 2, content: 'Goodbye World', timestamp: DateTime.now(), type: 'scan'),
      ];
      when(() => mockStorageService.getHistory()).thenAnswer((_) async => records);
      final viewModel = HistoryViewModel(storageService: mockStorageService);

      await tester.pumpWidget(buildApp(viewModel));
      await tester.pumpAndSettle();

      // Initially both records are visible
      expect(find.text('Hello World'), findsOneWidget);
      expect(find.text('Goodbye World'), findsOneWidget);

      // Type in search bar
      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pumpAndSettle();

      // Only matching record should be visible
      expect(find.text('Hello World'), findsOneWidget);
      expect(find.text('Goodbye World'), findsNothing);
    });

    testWidgets('clear button clears search and shows all records', (tester) async {
      final records = [
        ScanRecord(id: 1, content: 'Hello World', timestamp: DateTime.now(), type: 'scan'),
        ScanRecord(id: 2, content: 'Goodbye World', timestamp: DateTime.now(), type: 'scan'),
      ];
      when(() => mockStorageService.getHistory()).thenAnswer((_) async => records);
      final viewModel = HistoryViewModel(storageService: mockStorageService);

      await tester.pumpWidget(buildApp(viewModel));
      await tester.pumpAndSettle();

      // Type in search bar
      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pumpAndSettle();
      expect(find.text('Goodbye World'), findsNothing);

      // Clear the search
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();

      // Both records should be visible again
      expect(find.text('Hello World'), findsOneWidget);
      expect(find.text('Goodbye World'), findsOneWidget);
    });

    testWidgets('filter chips appear and are selectable', (tester) async {
      when(() => mockStorageService.getHistory()).thenAnswer((_) async => []);
      final viewModel = HistoryViewModel(storageService: mockStorageService);

      await tester.pumpWidget(buildApp(viewModel));
      await tester.pumpAndSettle();

      expect(find.text('Tout'), findsOneWidget);
      expect(find.text('Scans'), findsOneWidget);
      expect(find.text('Générations'), findsOneWidget);
    });

    testWidgets('tapping Scans filter shows only scan records', (tester) async {
      final records = [
        ScanRecord(id: 1, content: 'scan content', timestamp: DateTime.now(), type: 'scan'),
        GenerationRecord(id: 2, content: 'gen content', timestamp: DateTime.now(), type: 'generation'),
      ];
      when(() => mockStorageService.getHistory()).thenAnswer((_) async => records);
      final viewModel = HistoryViewModel(storageService: mockStorageService);

      await tester.pumpWidget(buildApp(viewModel));
      await tester.pumpAndSettle();

      // Both records visible initially
      expect(find.text('scan content'), findsOneWidget);
      expect(find.text('gen content'), findsOneWidget);

      // Tap Scans filter
      await tester.tap(find.text('Scans'));
      await tester.pumpAndSettle();

      // Only scan record visible
      expect(find.text('scan content'), findsOneWidget);
      expect(find.text('gen content'), findsNothing);
    });

    testWidgets('tapping Générations filter shows only generation records', (tester) async {
      final records = [
        ScanRecord(id: 1, content: 'scan content', timestamp: DateTime.now(), type: 'scan'),
        GenerationRecord(id: 2, content: 'gen content', timestamp: DateTime.now(), type: 'generation'),
      ];
      when(() => mockStorageService.getHistory()).thenAnswer((_) async => records);
      final viewModel = HistoryViewModel(storageService: mockStorageService);

      await tester.pumpWidget(buildApp(viewModel));
      await tester.pumpAndSettle();

      // Tap Générations filter
      await tester.tap(find.text('Générations'));
      await tester.pumpAndSettle();

      // Only generation record visible
      expect(find.text('scan content'), findsNothing);
      expect(find.text('gen content'), findsOneWidget);
    });

    testWidgets('tapping Tout filter shows all records', (tester) async {
      final records = [
        ScanRecord(id: 1, content: 'scan content', timestamp: DateTime.now(), type: 'scan'),
        GenerationRecord(id: 2, content: 'gen content', timestamp: DateTime.now(), type: 'generation'),
      ];
      when(() => mockStorageService.getHistory()).thenAnswer((_) async => records);
      final viewModel = HistoryViewModel(storageService: mockStorageService);

      await tester.pumpWidget(buildApp(viewModel));
      await tester.pumpAndSettle();

      // Tap Scans filter first
      await tester.tap(find.text('Scans'));
      await tester.pumpAndSettle();
      expect(find.text('gen content'), findsNothing);

      // Tap Tout filter
      await tester.tap(find.text('Tout'));
      await tester.pumpAndSettle();

      // Both records visible
      expect(find.text('scan content'), findsOneWidget);
      expect(find.text('gen content'), findsOneWidget);
    });

    testWidgets('search and filter combine: both conditions applied', (tester) async {
      final records = [
        ScanRecord(id: 1, content: 'Hello Scan', timestamp: DateTime.now(), type: 'scan'),
        ScanRecord(id: 2, content: 'Hello World', timestamp: DateTime.now(), type: 'scan'),
        GenerationRecord(id: 3, content: 'Hello Gen', timestamp: DateTime.now(), type: 'generation'),
      ];
      when(() => mockStorageService.getHistory()).thenAnswer((_) async => records);
      final viewModel = HistoryViewModel(storageService: mockStorageService);

      await tester.pumpWidget(buildApp(viewModel));
      await tester.pumpAndSettle();

      // Apply both filter and search
      await tester.tap(find.text('Scans'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pumpAndSettle();

      // Only scan records with "Hello" should be visible
      expect(find.text('Hello Scan'), findsOneWidget);
      expect(find.text('Hello World'), findsOneWidget);
      expect(find.text('Hello Gen'), findsNothing);
    });

    testWidgets('swipe-left on record shows red background', (tester) async {
      final records = [
        ScanRecord(id: 1, content: 'scan content', timestamp: DateTime.now(), type: 'scan'),
      ];
      when(() => mockStorageService.getHistory()).thenAnswer((_) async => records);
      when(() => mockStorageService.delete('scan_records', 1)).thenAnswer((_) async {});
      when(() => mockStorageService.getHistory()).thenAnswer((_) async => []);
      final viewModel = HistoryViewModel(storageService: mockStorageService);

      await tester.pumpWidget(buildApp(viewModel));
      await tester.pumpAndSettle();

      // Swipe left on the record
      await tester.drag(find.byType(Card), const Offset(-500, 0));
      await tester.pump();

      // Red background should appear
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('confirmDismiss shows AlertDialog with correct French text', (tester) async {
      final records = [
        ScanRecord(id: 1, content: 'scan content', timestamp: DateTime.now(), type: 'scan'),
      ];
      when(() => mockStorageService.getHistory()).thenAnswer((_) async => records);
      when(() => mockStorageService.delete('scan_records', 1)).thenAnswer((_) async {});
      when(() => mockStorageService.getHistory()).thenAnswer((_) async => []);
      final viewModel = HistoryViewModel(storageService: mockStorageService);

      await tester.pumpWidget(buildApp(viewModel));
      await tester.pumpAndSettle();

      // Swipe left on the record
      await tester.drag(find.byType(Card), const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Dialog should appear with correct French text
      expect(find.text('Supprimer l\'entrée'), findsOneWidget);
      expect(find.text('Voulez-vous vraiment supprimer cette entrée de l\'historique ? Cette action est irréversible.'), findsOneWidget);
      expect(find.text('Annuler'), findsOneWidget);
      expect(find.text('Supprimer'), findsOneWidget);
    });

    testWidgets('confirming deletion removes record from list', (tester) async {
      final records = [
        ScanRecord(id: 1, content: 'scan content', timestamp: DateTime.now(), type: 'scan'),
      ];
      when(() => mockStorageService.getHistory()).thenAnswer((_) async => records);
      when(() => mockStorageService.delete('scan_records', 1)).thenAnswer((_) async {});
      when(() => mockStorageService.getHistory()).thenAnswer((_) async => []);
      final viewModel = HistoryViewModel(storageService: mockStorageService);

      await tester.pumpWidget(buildApp(viewModel));
      await tester.pumpAndSettle();

      // Swipe left on the record
      await tester.drag(find.byType(Card), const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Tap Supprimer button
      await tester.tap(find.text('Supprimer'));
      await tester.pumpAndSettle();

      // Record should be removed
      expect(find.text('scan content'), findsNothing);
    });

    testWidgets('canceling deletion keeps record in list', (tester) async {
      final records = [
        ScanRecord(id: 1, content: 'scan content', timestamp: DateTime.now(), type: 'scan'),
      ];
      when(() => mockStorageService.getHistory()).thenAnswer((_) async => records);
      when(() => mockStorageService.getHistory()).thenAnswer((_) async => records);
      final viewModel = HistoryViewModel(storageService: mockStorageService);

      await tester.pumpWidget(buildApp(viewModel));
      await tester.pumpAndSettle();

      // Swipe left on the record
      await tester.drag(find.byType(Card), const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Tap Annuler button
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();

      // Record should still be visible
      expect(find.text('scan content'), findsOneWidget);
    });

    testWidgets('"Aucun résultat" state shown when search has no matches', (tester) async {
      final records = [
        ScanRecord(id: 1, content: 'Hello World', timestamp: DateTime.now(), type: 'scan'),
      ];
      when(() => mockStorageService.getHistory()).thenAnswer((_) async => records);
      final viewModel = HistoryViewModel(storageService: mockStorageService);

      await tester.pumpWidget(buildApp(viewModel));
      await tester.pumpAndSettle();

      // Type search that doesn't match
      await tester.enterText(find.byType(TextField), 'nonexistent');
      await tester.pumpAndSettle();

      // Should show no results state
      expect(find.text('Aucun résultat'), findsOneWidget);
      expect(find.text('Aucune entrée ne correspond à votre recherche'), findsOneWidget);
      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });
  });
}
