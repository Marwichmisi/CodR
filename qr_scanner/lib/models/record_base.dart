import 'scan_record.dart';
import 'generation_record.dart';

/// Abstract base class for all records (scan and generation).
/// Provides a unified interface for accessing record properties.
abstract class RecordBase {
  int get id;
  String get content;
  DateTime get timestamp;
  String get type;

  /// Protected constructor for subclasses.
  const RecordBase();

  /// Factory constructor that returns the correct subtype based on the type field.
  factory RecordBase.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    switch (type) {
      case 'scan':
        return ScanRecord.fromJson(json);
      case 'generation':
        return GenerationRecord.fromJson(json);
      default:
        throw ArgumentError('Unknown record type: $type');
    }
  }
}
