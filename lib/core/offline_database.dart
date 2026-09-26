import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'sqlite_models.dart';
import 'web_storage.dart';

class PendingOperation {
  final int id;
  final String method;
  final String path;
  final String? body;
  final int? localId;
  final int attempts;
  final String? lastError;

  const PendingOperation({
    required this.id,
    required this.method,
    required this.path,
    required this.body,
    required this.localId,
    required this.attempts,
    required this.lastError,
  });

  factory PendingOperation.fromRow(Map<String, Object?> row) {
    return PendingOperation(
      id: row['id'] as int,
      method: row['method'] as String,
      path: row['path'] as String,
      body: row['body'] as String?,
      localId: row['local_id'] as int?,
      attempts: row['attempts'] as int,
      lastError: row['last_error'] as String?,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'method': method,
    'path': path,
    'body': body,
    'local_id': localId,
    'attempts': attempts,
    'last_error': lastError,
  };
}

class OfflineDatabase {
  OfflineDatabase._();

  static final OfflineDatabase instance = OfflineDatabase._();

  Database? _database;

  // Web in-memory / localStorage cache
  final Map<String, List<Map<String, Object?>>> _webTables = {};
  final Map<String, String> _webResponseCache = {};
  List<PendingOperation> _webPendingOps = [];
  int _webPendingIdCounter = 1;
  bool _webInitialized = false;

  void _initWeb() {
    if (_webInitialized) return;
    _webInitialized = true;
    try {
      final opsJson = webGetItem('tienda_pending_operations');
      if (opsJson != null) {
        final list = jsonDecode(opsJson) as List;
        _webPendingOps = list
            .map((e) => PendingOperation.fromRow(Map<String, Object?>.from(e as Map)))
            .toList();
        if (_webPendingOps.isNotEmpty) {
          _webPendingIdCounter = _webPendingOps.map((o) => o.id).reduce((a, b) => a > b ? a : b) + 1;
        }
      }
    } catch (_) {}
  }

  void _persistWebPendingOps() {
    try {
      final list = _webPendingOps.map((o) => o.toMap()).toList();
      webSetItem('tienda_pending_operations', jsonEncode(list));
    } catch (_) {}
  }

  List<Map<String, Object?>> _getWebTable(String table) {
    _initWeb();
    if (!_webTables.containsKey(table)) {
      final jsonStr = webGetItem('tienda_tbl_$table');
      if (jsonStr != null) {
        try {
          final list = jsonDecode(jsonStr) as List;
          _webTables[table] = list
              .map((e) => Map<String, Object?>.from(e as Map))
              .toList();
        } catch (_) {
          _webTables[table] = [];
        }
      } else {
        _webTables[table] = [];
      }
    }
    return _webTables[table]!;
  }

  void _persistWebTable(String table) {
    try {
      final list = _webTables[table] ?? [];
      webSetItem('tienda_tbl_$table', jsonEncode(list));
    } catch (_) {}
  }

  Future<Database> get _db async {
    final current = _database;
    if (current != null) return current;

    final dbPath = await getDatabasesPath();
    final fullPath = path.join(dbPath, 'tienda_offline.db');
    final database = await openDatabase(
      fullPath,
      version: 2,
      onCreate: (db, _) async {
        await _createCoreTables(db);
        await _createModelTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createModelTables(db);
        }
      },
    );
    _database = database;
    return database;
  }

  static Future<void> _createCoreTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS response_cache (
        path TEXT PRIMARY KEY,
        body TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS pending_operations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        method TEXT NOT NULL,
        path TEXT NOT NULL,
        body TEXT,
        local_id INTEGER,
        created_at INTEGER NOT NULL,
        attempts INTEGER NOT NULL DEFAULT 0,
        last_error TEXT
      )
    ''');
  }

  static Future<void> _createModelTables(Database db) async {
    for (final sql in SqliteTables.allCreateStatements) {
      await db.execute(sql);
    }
  }

  // ---------------------------------------------------------------------------
  // Operaciones estructuradas por modelo en SQLite / Web
  // ---------------------------------------------------------------------------

  Future<void> saveEntitiesFromApi(
    String table,
    List<Map<String, dynamic>> items,
  ) async {
    if (kIsWeb) {
      final list = _getWebTable(table);
      for (final item in items) {
        final sqliteMap = EndpointTableRegistry.apiJsonToSqliteMap(
          table,
          item,
          isSynced: true,
          syncAction: 'none',
        );
        final id = sqliteMap['id'];
        list.removeWhere((e) => e['id'] == id);
        list.add(sqliteMap);
      }
      _persistWebTable(table);
      return;
    }

    final db = await _db;
    final batch = db.batch();
    for (final item in items) {
      final sqliteMap = EndpointTableRegistry.apiJsonToSqliteMap(
        table,
        item,
        isSynced: true,
        syncAction: 'none',
      );
      batch.insert(
        table,
        sqliteMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, Object?>>> getAllEntities(String table) async {
    if (kIsWeb) {
      final list = _getWebTable(table);
      final result = list.where((e) => e['sync_action'] != 'delete').toList();
      result.sort((a, b) => ((a['id'] as num?) ?? 0).compareTo((b['id'] as num?) ?? 0));
      return result;
    }

    final db = await _db;
    return db.query(
      table,
      where: "sync_action != 'delete'",
      orderBy: 'id ASC',
    );
  }

  Future<Map<String, Object?>?> getEntityById(String table, int id) async {
    if (kIsWeb) {
      final list = _getWebTable(table);
      try {
        return list.firstWhere((e) => e['id'] == id && e['sync_action'] != 'delete');
      } catch (_) {
        return null;
      }
    }

    final db = await _db;
    final rows = await db.query(
      table,
      where: "id = ? AND sync_action != 'delete'",
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<int> insertEntity(String table, Map<String, Object?> row) async {
    if (kIsWeb) {
      final list = _getWebTable(table);
      final id = row['id'];
      list.removeWhere((e) => e['id'] == id);
      list.add(Map<String, Object?>.from(row));
      _persistWebTable(table);
      return 1;
    }

    final db = await _db;
    return db.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateEntity(
    String table,
    int id,
    Map<String, Object?> row,
  ) async {
    if (kIsWeb) {
      final list = _getWebTable(table);
      final index = list.indexWhere((e) => e['id'] == id);
      if (index != -1) {
        list[index] = {...list[index], ...row};
        _persistWebTable(table);
        return 1;
      }
      return 0;
    }

    final db = await _db;
    return db.update(table, row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteEntity(String table, int id, {bool softDelete = false}) async {
    if (kIsWeb) {
      final list = _getWebTable(table);
      if (softDelete && id > 0) {
        final index = list.indexWhere((e) => e['id'] == id);
        if (index != -1) {
          list[index]['sync_action'] = 'delete';
          list[index]['is_synced'] = 0;
          _persistWebTable(table);
          return 1;
        }
      } else {
        list.removeWhere((e) => e['id'] == id);
        _persistWebTable(table);
        return 1;
      }
      return 0;
    }

    final db = await _db;
    if (softDelete && id > 0) {
      return db.update(
        table,
        {'sync_action': 'delete', 'is_synced': 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
    return db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markEntitySynced(
    String table,
    int localId,
    int? remoteId,
  ) async {
    if (kIsWeb) {
      final list = _getWebTable(table);
      final index = list.indexWhere((e) => e['id'] == localId);
      if (index != -1) {
        final item = Map<String, Object?>.from(list[index]);
        if (remoteId != null && remoteId != localId) {
          item['id'] = remoteId;
          item['remote_id'] = remoteId;
        }
        item['is_synced'] = 1;
        item['sync_action'] = 'none';
        list[index] = item;
        _persistWebTable(table);
      }
      return;
    }

    final db = await _db;
    if (remoteId != null && remoteId != localId) {
      final rows = await db.query(table, where: 'id = ?', whereArgs: [localId]);
      if (rows.isNotEmpty) {
        final updated = Map<String, Object?>.from(rows.first);
        updated['id'] = remoteId;
        updated['remote_id'] = remoteId;
        updated['is_synced'] = 1;
        updated['sync_action'] = 'none';

        await db.delete(table, where: 'id = ?', whereArgs: [localId]);
        await db.insert(
          table,
          updated,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } else {
      await db.update(
        table,
        {'is_synced': 1, 'sync_action': 'none', 'remote_id': remoteId ?? localId},
        where: 'id = ?',
        whereArgs: [localId],
      );
    }
  }

  Future<void> updateForeignKeyReference({
    required String table,
    required String foreignKeyColumn,
    required int oldId,
    required int newId,
  }) async {
    if (kIsWeb) {
      final list = _getWebTable(table);
      for (final item in list) {
        if (item[foreignKeyColumn] == oldId) {
          item[foreignKeyColumn] = newId;
        }
      }
      _persistWebTable(table);
      return;
    }

    final db = await _db;
    await db.update(
      table,
      {foreignKeyColumn: newId},
      where: '$foreignKeyColumn = ?',
      whereArgs: [oldId],
    );
  }

  Future<List<Map<String, Object?>>> getUnsyncedEntities(String table) async {
    if (kIsWeb) {
      final list = _getWebTable(table);
      return list.where((e) => e['is_synced'] == 0).toList();
    }

    final db = await _db;
    return db.query(
      table,
      where: 'is_synced = 0',
      orderBy: 'id ASC',
    );
  }

  // ---------------------------------------------------------------------------
  // Cache de respuestas raw y cola de operaciones pendientes
  // ---------------------------------------------------------------------------

  Future<String?> cachedResponse(String requestPath) async {
    if (kIsWeb) {
      _initWeb();
      return _webResponseCache[requestPath] ?? webGetItem('tienda_cache_$requestPath');
    }

    final db = await _db;
    final rows = await db.query(
      'response_cache',
      columns: const ['body'],
      where: 'path = ?',
      whereArgs: [requestPath],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['body'] as String;
  }

  Future<void> saveResponse(String requestPath, String body) async {
    if (kIsWeb) {
      _initWeb();
      _webResponseCache[requestPath] = body;
      webSetItem('tienda_cache_$requestPath', body);
      return;
    }

    final db = await _db;
    await db.insert('response_cache', {
      'path': requestPath,
      'body': body,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> enqueueOperation({
    required String method,
    required String requestPath,
    required String? body,
    int? localId,
  }) async {
    if (kIsWeb) {
      _initWeb();
      final id = _webPendingIdCounter++;
      final op = PendingOperation(
        id: id,
        method: method,
        path: requestPath,
        body: body,
        localId: localId,
        attempts: 0,
        lastError: null,
      );
      _webPendingOps.add(op);
      _persistWebPendingOps();
      return id;
    }

    final db = await _db;
    return db.insert('pending_operations', {
      'method': method,
      'path': requestPath,
      'body': body,
      'local_id': localId,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'attempts': 0,
      'last_error': null,
    });
  }

  Future<void> setOperationLocalId(int id, int localId) async {
    if (kIsWeb) {
      _initWeb();
      final index = _webPendingOps.indexWhere((o) => o.id == id);
      if (index != -1) {
        final o = _webPendingOps[index];
        _webPendingOps[index] = PendingOperation(
          id: o.id,
          method: o.method,
          path: o.path,
          body: o.body,
          localId: localId,
          attempts: o.attempts,
          lastError: o.lastError,
        );
        _persistWebPendingOps();
      }
      return;
    }

    final db = await _db;
    await db.update(
      'pending_operations',
      {'local_id': localId},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<PendingOperation>> pendingOperations() async {
    if (kIsWeb) {
      _initWeb();
      return List.unmodifiable(_webPendingOps);
    }

    final db = await _db;
    final rows = await db.query('pending_operations', orderBy: 'id ASC');
    return rows.map(PendingOperation.fromRow).toList();
  }

  Future<int> pendingCount() async {
    if (kIsWeb) {
      _initWeb();
      return _webPendingOps.length;
    }

    final db = await _db;
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM pending_operations',
    );
    return Sqflite.firstIntValue(rows) ?? 0;
  }

  Future<void> deleteOperation(int id) async {
    if (kIsWeb) {
      _initWeb();
      _webPendingOps.removeWhere((o) => o.id == id);
      _persistWebPendingOps();
      return;
    }

    final db = await _db;
    await db.delete('pending_operations', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markOperationFailed(int id, String error) async {
    if (kIsWeb) {
      _initWeb();
      final index = _webPendingOps.indexWhere((o) => o.id == id);
      if (index != -1) {
        final o = _webPendingOps[index];
        _webPendingOps[index] = PendingOperation(
          id: o.id,
          method: o.method,
          path: o.path,
          body: o.body,
          localId: o.localId,
          attempts: o.attempts + 1,
          lastError: error,
        );
        _persistWebPendingOps();
      }
      return;
    }

    final db = await _db;
    await db.rawUpdate(
      '''
      UPDATE pending_operations
      SET attempts = attempts + 1, last_error = ?
      WHERE id = ?
      ''',
      [error, id],
    );
  }
}
