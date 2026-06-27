import 'package:flutter_test/flutter_test.dart';
import 'package:qr_scanner/models/generation_record.dart';

void main() {
  group('GenerationRecord', () {
    test('serializes to JSON and back without data loss', () {
      final record = GenerationRecord(
        id: 1,
        content: 'Hello World',
        timestamp: DateTime(2026, 6, 27, 14, 30),
        type: 'generation',
      );
      final json = record.toJson();
      final restored = GenerationRecord.fromJson(json);
      expect(restored.id, record.id);
      expect(restored.content, record.content);
      expect(restored.timestamp, record.timestamp);
      expect(restored.type, record.type);
    });

    test('throws FormatException on invalid JSON', () {
      expect(
        () => GenerationRecord.fromJson({'id': 'not_an_int'}),
        throwsA(anything),
      );
    });
  });
}
