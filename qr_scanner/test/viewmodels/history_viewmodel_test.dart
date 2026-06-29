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
        // Simulate async delay
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
  });
}
