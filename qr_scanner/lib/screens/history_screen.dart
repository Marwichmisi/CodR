import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../theme/app_theme.dart';
import '../viewmodels/history_viewmodel.dart';
import '../services/storage_service.dart';
import '../models/scan_record.dart';
import '../models/generation_record.dart';
import '../models/record_base.dart';
import 'package:sqflite/sqflite.dart';

class HistoryScreen extends StatefulWidget {
  final HistoryViewModel viewModel;

  const HistoryScreen({required this.viewModel, super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadRecords();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth =
            constraints.maxWidth > 600 ? 480.0 : constraints.maxWidth;
        return Scaffold(
          appBar: AppBar(title: const Text('Historique')),
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: ListenableBuilder(
                listenable: widget.viewModel,
                builder: (context, _) {
                  if (widget.viewModel.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (widget.viewModel.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Erreur de chargement',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.viewModel.error!,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  if (widget.viewModel.filteredRecords.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Aucun historique',
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Vos scans et générations apparaîtront ici',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: widget.viewModel.filteredRecords.length,
                    itemBuilder: (context, index) {
                      final record = widget.viewModel.filteredRecords[index];
                      final isScan = record.type == 'scan';
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: Icon(
                            isScan ? Icons.qr_code_scanner : Icons.qr_code,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          title: Text(
                            record.content,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            _formatTimestamp(record.timestamp),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inHours < 48) {
      // Use simple relative time for recent records
      if (difference.inMinutes < 1) return 'À l\'instant';
      if (difference.inMinutes < 60) return 'Il y a ${difference.inMinutes} min';
      if (difference.inHours < 24) return 'Il y a ${difference.inHours}h';
      return 'Hier';
    }
    // Use formatted date for older records
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

@Preview(name: 'History Screen', group: 'Screens')
Widget historyPreview() {
  // Mock StorageService for preview
  final mockStorageService = _MockStorageService();
  return MaterialApp(
    theme: buildLightTheme(),
    home: HistoryScreen(
      viewModel: HistoryViewModel(storageService: mockStorageService),
    ),
  );
}

class _MockStorageService implements StorageService {
  @override
  Future<Database> get database async => throw UnimplementedError();
  @override
  Future<void> insertRecord(String table, Map<String, dynamic> data) async {}
  @override
  Future<List<Map<String, dynamic>>> getAll(String table) async => [];
  @override
  Future<Map<String, dynamic>?> getById(String table, int id) async => null;
  @override
  Future<void> delete(String table, int id) async {}
  @override
  Future<void> insertScanRecord(ScanRecord record) async {}
  @override
  Future<void> insertGenerationRecord(GenerationRecord record) async {}
  @override
  Future<List<ScanRecord>> getAllScanRecords() async => [];
  @override
  Future<List<GenerationRecord>> getAllGenerationRecords() async => [];
  @override
  Future<List<RecordBase>> getHistory() async => [];
}
