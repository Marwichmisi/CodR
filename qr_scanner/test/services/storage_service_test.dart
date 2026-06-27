import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:qr_scanner/services/storage_service.dart';
import 'package:qr_scanner/models/scan_record.dart';
import 'package:qr_scanner/models/generation_record.dart';

void main() {
  late StorageService storageService;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    storageService = StorageService();
    // Reset database for each test
    final db = await storageService.database;
    await db.delete('scan_records');
    await db.delete('generation_records');
  });

  group('StorageService', () {
    test('database initializes without error', () async {
      final db = await storageService.database;
      expect(db, isNotNull);
    });

    test('insert and retrieve ScanRecord', () async {
      final record = ScanRecord(
        id: 0, // autoincrement
        content: 'https://example.com',
        timestamp: DateTime(2026, 6, 27),
        type: 'scan',
      );
      await storageService.insertScanRecord(record);
      final records = await storageService.getAllScanRecords();
      expect(records.length, 1);
      expect(records.first.content, 'https://example.com');
      expect(records.first.type, 'scan');
    });

    test('insert and retrieve GenerationRecord', () async {
      final record = GenerationRecord(
        id: 0,
        content: 'Hello World',
        timestamp: DateTime(2026, 6, 27),
        type: 'generation',
      );
      await storageService.insertGenerationRecord(record);
      final records = await storageService.getAllGenerationRecords();
      expect(records.length, 1);
      expect(records.first.content, 'Hello World');
      expect(records.first.type, 'generation');
    });

    test('getAll returns records ordered by timestamp DESC', () async {
      final record1 = ScanRecord(
        id: 0,
        content: 'first',
        timestamp: DateTime(2026, 6, 27, 10, 0),
        type: 'scan',
      );
      final record2 = ScanRecord(
        id: 0,
        content: 'second',
        timestamp: DateTime(2026, 6, 27, 12, 0),
        type: 'scan',
      );
      await storageService.insertScanRecord(record1);
      await storageService.insertScanRecord(record2);
      final records = await storageService.getAllScanRecords();
      expect(records.length, 2);
      // Most recent first (DESC order)
      expect(records.first.content, 'second');
      expect(records.last.content, 'first');
    });

    test('getById returns correct record', () async {
      final record = ScanRecord(
        id: 0,
        content: 'test content',
        timestamp: DateTime(2026, 6, 27),
        type: 'scan',
      );
      await storageService.insertScanRecord(record);
      final records = await storageService.getAllScanRecords();
      final insertedId = records.first.id;
      final retrieved = await storageService.getById('scan_records', insertedId);
      expect(retrieved, isNotNull);
      expect(retrieved!['content'], 'test content');
    });

    test('delete removes record from database', () async {
      final record = ScanRecord(
        id: 0,
        content: 'to delete',
        timestamp: DateTime(2026, 6, 27),
        type: 'scan',
      );
      await storageService.insertScanRecord(record);
      final records = await storageService.getAllScanRecords();
      final insertedId = records.first.id;
      await storageService.delete('scan_records', insertedId);
      final remaining = await storageService.getAllScanRecords();
      expect(remaining.length, 0);
    });

    test('single database file handles both models', () async {
      final scanRecord = ScanRecord(
        id: 0,
        content: 'scan data',
        timestamp: DateTime(2026, 6, 27),
        type: 'scan',
      );
      final genRecord = GenerationRecord(
        id: 0,
        content: 'gen data',
        timestamp: DateTime(2026, 6, 27),
        type: 'generation',
      );
      await storageService.insertScanRecord(scanRecord);
      await storageService.insertGenerationRecord(genRecord);
      final scans = await storageService.getAllScanRecords();
      final gens = await storageService.getAllGenerationRecords();
      expect(scans.length, 1);
      expect(gens.length, 1);
      // Both tables in same database
      final db = await storageService.database;
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      );
      final tableNames = tables.map((t) => t['name'] as String).toSet();
      expect(tableNames, containsAll(['scan_records', 'generation_records']));
    });

    test('DateTime stored as ISO 8601 and parsed back correctly', () async {
      final timestamp = DateTime(2026, 6, 27, 14, 30, 45);
      final record = ScanRecord(
        id: 0,
        content: 'date test',
        timestamp: timestamp,
        type: 'scan',
      );
      await storageService.insertScanRecord(record);
      final records = await storageService.getAllScanRecords();
      expect(records.first.timestamp, timestamp);
    });
  });
}
