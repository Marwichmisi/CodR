import 'package:flutter/foundation.dart';
import '../models/record_base.dart';
import '../services/storage_service.dart';

enum RecordType { scan, generation }

/// ViewModel for the history screen.
/// Loads records from StorageService and manages filtering.
class HistoryViewModel extends ChangeNotifier {
  final StorageService storageService;

  HistoryViewModel({required this.storageService});

  List<RecordBase> _allRecords = [];
  List<RecordBase> get allRecords => _allRecords;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  RecordType? _selectedType;
  RecordType? get selectedType => _selectedType;

  /// Loads all records from storage.
  Future<void> loadRecords() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _allRecords = await storageService.getHistory();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Deletes a record and reloads the list.
  Future<void> deleteRecord(RecordBase record) async {
    final table = record.type == 'scan' ? 'scan_records' : 'generation_records';
    await storageService.delete(table, record.id);
    await loadRecords();
  }

  /// Sets the type filter.
  void setFilter(RecordType? type) {
    _selectedType = type;
    notifyListeners();
  }

  /// Returns filtered records based on selected type.
  List<RecordBase> get filteredRecords {
    if (_selectedType == null) return _allRecords;
    return _allRecords.where((r) => r.type == _selectedType!.name).toList();
  }
}
