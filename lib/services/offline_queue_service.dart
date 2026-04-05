import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import 'api_service.dart';

class OfflineQueueService {
  OfflineQueueService._();

  static final OfflineQueueService instance = OfflineQueueService._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    final dbPath = await getDatabasesPath();
    _database = await openDatabase(
      path.join(dbPath, 'coconut_erp_queue.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE queued_worklogs(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            payload TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
    return _database!;
  }

  Future<void> enqueueWorkLog(Map<String, dynamic> payload) async {
    final db = await database;
    await db.insert(
      'queued_worklogs',
      <String, Object?>{
        'payload': jsonEncode(payload),
        'created_at': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<int> getQueuedCount() async {
    final db = await database;
    return Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM queued_worklogs'),
        ) ??
        0;
  }

  Future<void> syncQueuedWorkLogs({
    required ApiService apiService,
    required String token,
  }) async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      return;
    }

    final db = await database;
    final items = await db.query('queued_worklogs', orderBy: 'created_at ASC');

    for (final item in items) {
      final payload =
          jsonDecode(item['payload']! as String) as Map<String, dynamic>;
      try {
        await apiService.createWorkLog(
          token: token,
          workDate: payload['workDate'] as String,
          landId: payload['landId'] as String,
          coconutCount: payload['coconutCount'] as int,
          bagCount: payload['bagCount'] as int,
          workerIds: (payload['workerIds'] as List<dynamic>).cast<String>(),
          supervisorId: payload['supervisorId'] as String?,
          vehicleId: payload['vehicleId'] as String?,
          latitude: (payload['latitude'] as num?)?.toDouble(),
          longitude: (payload['longitude'] as num?)?.toDouble(),
          notes: payload['notes'] as String?,
        );
        await db.delete(
          'queued_worklogs',
          where: 'id = ?',
          whereArgs: <Object?>[item['id']],
        );
      } catch (_) {
        // Keep the entry queued and stop the batch if the server still fails.
        break;
      }
    }
  }
}
