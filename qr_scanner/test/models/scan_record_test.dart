import 'package:flutter_test/flutter_test.dart';
import 'package:qr_scanner/models/scan_record.dart';

void main() {
  group('ScanRecord', () {
    test('serializes to JSON and back without data loss', () {
      final record = ScanRecord(
        id: 1,
        content: 'https://example.com',
        timestamp: DateTime(2026, 6, 27, 12, 0),
        type: 'scan',
      );
      final json = record.toJson();
      final restored = ScanRecord.fromJson(json);
      expect(restored.id, record.id);
      expect(restored.content, record.content);
      expect(restored.timestamp, record.timestamp);
      expect(restored.type, record.type);
    });

    test('throws FormatException on invalid JSON', () {
      expect(
        () => ScanRecord.fromJson({'id': 'not_an_int'}),
        throwsA(anything),
      );
    });
  });
}
