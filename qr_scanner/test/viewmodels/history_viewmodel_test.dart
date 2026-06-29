import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qr_scanner/viewmodels/history_viewmodel.dart';
import 'package:qr_scanner/services/storage_service.dart';
import 'package:qr_scanner/models/scan_record.dart';
import 'package:qr_scanner/models/generation_record.dart';

class MockStorageService extends Mock implements StorageService {}

void main() {
  late MockStorageService mockStorageService;
  late HistoryViewModel viewModel;

  setUp(() {
    mockStorageService = MockStorageService();
    viewModel = HistoryViewModel(storageService: mockStorageService);
  });

  group('HistoryViewModel', () {
    test('initial state has empty records and is not loading', () {
      expect(viewModel.allRecords, isEmpty);
      expect(viewModel.isLoading, false);
      expect(viewModel.error, isNull);
      expect(viewModel.selectedType, isNull);
      expect(viewModel.searchQuery, isEmpty);
    });

    test('loadRecords calls getHistory and populates allRecords', () async {
      final records = [
        ScanRecord(
          id: 1,
          content: 'scan test',
          timestamp: DateTime(2026, 6, 27),
          type: 'scan',
        ),
        GenerationRecord(
          id: 2,
          content: 'gen test',
          timestamp: DateTime(2026, 6, 27),
          type: 'generation',
        ),
      ];
      when(() => mockStorageService.getHistory()).thenAnswer((_) async => records);

      await viewModel.loadRecords();

      expect(viewModel.allRecords.length, 2);
      expect(viewModel.isLoading, false);
      expect(viewModel.error, isNull);
      verify(() => mockStorageService.getHistory()).called(1);
    });

    test('loadRecords sets isLoading correctly', () async {
      when(() => mockStorageService.getHistory()).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 10));
        return [];
      });

      final future = viewModel.loadRecords();
      expect(viewModel.isLoading, true);

      await future;
      expect(viewModel.isLoading, false);
    });

    test('loadRecords handles errors gracefully', () async {
      when(() => mockStorageService.getHistory()).thenThrow(Exception('DB error'));

      await viewModel.loadRecords();

      expect(viewModel.allRecords, isEmpty);
      expect(viewModel.isLoading, false);
      expect(viewModel.error, isNotNull);
    });

    test('deleteRecord calls correct table based on type', () async {
      final scanRecord = ScanRecord(
        id: 1,
        content: 'scan test',
        timestamp: DateTime(2026, 6, 27),
        type: 'scan',
      );
      when(() => mockStorageService.delete('scan_records', 1)).thenAnswer((_) async {});
      when(() => mockStorageService.getHistory()).thenAnswer((_) async => []);

      await viewModel.deleteRecord(scanRecord);

      verify(() => mockStorageService.delete('scan_records', 1)).called(1);
      verify(() => mockStorageService.getHistory()).called(1);
    });

    test('deleteRecord uses generation_records for generation type', () async {
      final genRecord = GenerationRecord(
        id: 2,
        content: 'gen test',
        timestamp: DateTime(2026, 6, 27),
        type: 'generation',
      );
      when(() => mockStorageService.delete('generation_records', 2)).thenAnswer((_) async {});
      when(() => mockStorageService.getHistory()).thenAnswer((_) async => []);

      await viewModel.deleteRecord(genRecord);

      verify(() => mockStorageService.delete('generation_records', 2)).called(1);
    });

    test('setFilter updates selectedType', () {
      expect(viewModel.selectedType, isNull);

      viewModel.setFilter(RecordType.scan);
      expect(viewModel.selectedType, RecordType.scan);

      viewModel.setFilter(null);
      expect(viewModel.selectedType, isNull);
    });

    test('filteredRecords returns all records when no filter', () async {
      final records = [
        ScanRecord(id: 1, content: 'scan', timestamp: DateTime.now(), type: 'scan'),
        GenerationRecord(id: 2, content: 'gen', timestamp: DateTime.now(), type: 'generation'),
      ];
      when(() => mockStorageService.getHistory()).thenAnswer((_) async => records);

      await viewModel.loadRecords();

      expect(viewModel.filteredRecords.length, 2);
    });

    test('filteredRecords filters by type when filter is set', () async {
      final records = [
        ScanRecord(id: 1, content: 'scan', timestamp: DateTime.now(), type: 'scan'),
        GenerationRecord(id: 2, content: 'gen', timestamp: DateTime.now(), type: 'generation'),
      ];
      when(() => mockStorageService.getHistory()).thenAnswer((_) async => records);

      await viewModel.loadRecords();
      viewModel.setFilter(RecordType.scan);

      expect(viewModel.filteredRecords.length, 1);
      expect(viewModel.filteredRecords.first.type, 'scan');
    });

    // NEW TESTS FOR SEARCH FUNCTIONALITY

    test('setSearchQuery updates searchQuery and triggers notifyListeners', () {
      final listener = MockVoidCallback();
      viewModel.addListener(listener);

      viewModel.setSearchQuery('test query');

      expect(viewModel.searchQuery, 'test query');
      verify(() => listener()).called(1);
    });

    test('filteredRecords returns only records matching search query (case-insensitive)', () async {
      final records = [
        ScanRecord(id: 1, content: 'Hello World', timestamp: DateTime.now(), type: 'scan'),
        ScanRecord(id: 2, content: 'Goodbye World', timestamp: DateTime.now(), type: 'scan'),
        GenerationRecord(id: 3, content: 'Hello Flutter', timestamp: DateTime.now(), type: 'generation'),
      ];
      when(() => mockStorageService.getHistory()).thenAnswer((_) async => records);

      await viewModel.loadRecords();
      viewModel.setSearchQuery('hello');

      expect(viewModel.filteredRecords.length, 2);
      expect(viewModel.filteredRecords.every((r) => r.content.toLowerCase().contains('hello')), true);
    });

    test('filteredRecords returns only records matching selected type filter', () async {
      final records = [
        ScanRecord(id: 1, content: 'scan content', timestamp: DateTime.now(), type: 'scan'),
        GenerationRecord(id: 2, content: 'gen content', timestamp: DateTime.now(), type: 'generation'),
        ScanRecord(id: 3, content: 'another scan', timestamp: DateTime.now(), type: 'scan'),
      ];
      when(() => mockStorageService.getHistory()).thenAnswer((_) async => records);

      await viewModel.loadRecords();
      viewModel.setFilter(RecordType.generation);

      expect(viewModel.filteredRecords.length, 1);
      expect(viewModel.filteredRecords.first.type, 'generation');
    });

    test('filteredRecords applies both search and type filter simultaneously', () async {
      final records = [
        ScanRecord(id: 1, content: 'Hello Scan', timestamp: DateTime.now(), type: 'scan'),
        ScanRecord(id: 2, content: 'Hello World', timestamp: DateTime.now(), type: 'scan'),
        GenerationRecord(id: 3, content: 'Hello Gen', timestamp: DateTime.now(), type: 'generation'),
        GenerationRecord(id: 4, content: 'Goodbye Gen', timestamp: DateTime.now(), type: 'generation'),
      ];
      when(() => mockStorageService.getHistory()).thenAnswer((_) async => records);

      await viewModel.loadRecords();
      viewModel.setFilter(RecordType.scan);
      viewModel.setSearchQuery('hello');

      expect(viewModel.filteredRecords.length, 2);
      expect(viewModel.filteredRecords.every((r) => r.type == 'scan' && r.content.toLowerCase().contains('hello')), true);
    });

    test('filteredRecords returns all records when search query is empty', () async {
      final records = [
        ScanRecord(id: 1, content: 'scan content', timestamp: DateTime.now(), type: 'scan'),
        GenerationRecord(id: 2, content: 'gen content', timestamp: DateTime.now(), type: 'generation'),
      ];
      when(() => mockStorageService.getHistory()).thenAnswer((_) async => records);

      await viewModel.loadRecords();
      viewModel.setSearchQuery('');

      expect(viewModel.filteredRecords.length, 2);
    });

    test('filteredRecords returns empty list when no records match search', () async {
      final records = [
        ScanRecord(id: 1, content: 'Hello World', timestamp: DateTime.now(), type: 'scan'),
      ];
      when(() => mockStorageService.getHistory()).thenAnswer((_) async => records);

      await viewModel.loadRecords();
      viewModel.setSearchQuery('nonexistent');

      expect(viewModel.filteredRecords, isEmpty);
    });
  });
}

class MockVoidCallback extends Mock {
  void call();
}
