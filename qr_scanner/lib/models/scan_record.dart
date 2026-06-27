class ScanRecord {
  final int id;
  final String content;
  final DateTime timestamp;
  final String type; // 'scan' or 'generation'

  const ScanRecord({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.type,
  });

  factory ScanRecord.fromJson(Map<String, dynamic> json) {
    return ScanRecord(
      id: json['id'] as int,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
    };
  }
}
