import 'package:flutter_test/flutter_test.dart';
import 'package:qr_scanner/models/record_base.dart';
import 'package:qr_scanner/models/scan_record.dart';
import 'package:qr_scanner/models/generation_record.dart';

void main() {
  group('RecordBase', () {
    test('ScanRecord is a subtype of RecordBase', () {
      final record = ScanRecord(
        id: 1,
        content: 'test',
        timestamp: DateTime(2026, 6, 27),
        type: 'scan',
      );
      expect(record, isA<RecordBase>());
    });

    test('GenerationRecord is a subtype of RecordBase', () {
      final record = GenerationRecord(
        id: 1,
        content: 'test',
        timestamp: DateTime(2026, 6, 27),
        type: 'generation',
      );
      expect(record, isA<RecordBase>());
    });

    test('RecordBase.fromJson returns ScanRecord when type is scan', () {
      final json = {
        'id': 1,
        'content': 'https://example.com',
        'timestamp': '2026-06-27T12:00:00.000',
        'type': 'scan',
      };
      final record = RecordBase.fromJson(json);
      expect(record, isA<ScanRecord>());
      expect(record.id, 1);
      expect(record.content, 'https://example.com');
      expect(record.type, 'scan');
    });

    test('RecordBase.fromJson returns GenerationRecord when type is generation', () {
      final json = {
        'id': 2,
        'content': 'Hello World',
        'timestamp': '2026-06-27T14:30:00.000',
        'type': 'generation',
      };
      final record = RecordBase.fromJson(json);
      expect(record, isA<GenerationRecord>());
      expect(record.id, 2);
      expect(record.content, 'Hello World');
      expect(record.type, 'generation');
    });

    test('shared getters work on both subtypes via RecordBase reference', () {
      final scanRecord = ScanRecord(
        id: 1,
        content: 'scan content',
        timestamp: DateTime(2026, 6, 27, 10, 0),
        type: 'scan',
      );
      final genRecord = GenerationRecord(
        id: 2,
        content: 'gen content',
        timestamp: DateTime(2026, 6, 27, 12, 0),
        type: 'generation',
      );

      // Use as RecordBase references
      RecordBase baseScan = scanRecord;
      RecordBase baseGen = genRecord;

      expect(baseScan.id, 1);
      expect(baseScan.content, 'scan content');
      expect(baseScan.type, 'scan');

      expect(baseGen.id, 2);
      expect(baseGen.content, 'gen content');
      expect(baseGen.type, 'generation');
    });
  });
}
