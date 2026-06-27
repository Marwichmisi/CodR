import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/scan_record.dart';
import '../models/generation_record.dart';

class StorageService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'qr_scanner.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE scan_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE generation_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');
  }

  // Generic CRUD methods

  Future<void> insertRecord(String table, Map<String, dynamic> data) async {
    final db = await database;
    // Remove 'id' key if value is 0 (autoincrement placeholder)
    final insertData = Map<String, dynamic>.from(data);
    if (insertData['id'] == 0) {
      insertData.remove('id');
    }
    await db.insert(table, insertData);
  }

  Future<List<Map<String, dynamic>>> getAll(String table) async {
    final db = await database;
    return await db.query(table, orderBy: 'timestamp DESC');
  }

  Future<Map<String, dynamic>?> getById(String table, int id) async {
    final db = await database;
    final results = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> delete(String table, int id) async {
    final db = await database;
    await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Model-specific helpers

  Future<void> insertScanRecord(ScanRecord record) async {
    await insertRecord('scan_records', record.toJson());
  }

  Future<void> insertGenerationRecord(GenerationRecord record) async {
    await insertRecord('generation_records', record.toJson());
  }

  Future<List<ScanRecord>> getAllScanRecords() async {
    final rows = await getAll('scan_records');
    return rows.map((row) => ScanRecord.fromJson(row)).toList();
  }

  Future<List<GenerationRecord>> getAllGenerationRecords() async {
    final rows = await getAll('generation_records');
    return rows.map((row) => GenerationRecord.fromJson(row)).toList();
  }
}
