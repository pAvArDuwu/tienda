import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'sqlite_models.dart';

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
}

class OfflineDatabase {
  OfflineDatabase._();

  static final OfflineDatabase instance = OfflineDatabase._();

  Database? _database;

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
  // Operaciones estructuradas por modelo en SQLite
  // ---------------------------------------------------------------------------

  /// Guarda una lista de registros recibidos de la API en la tabla SQLite local correspondiente.
  Future<void> saveEntitiesFromApi(
    String table,
    List<Map<String, dynamic>> items,
  ) async {
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

  /// Retorna todos los registros activos (que no estén marcados para eliminación offline)
  Future<List<Map<String, Object?>>> getAllEntities(String table) async {
    final db = await _db;
    return db.query(
      table,
      where: "sync_action != 'delete'",
      orderBy: 'id ASC',
    );
  }

  /// Retorna un registro por su ID
  Future<Map<String, Object?>?> getEntityById(String table, int id) async {
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

  /// Inserta un registro localmente
  Future<int> insertEntity(String table, Map<String, Object?> row) async {
    final db = await _db;
    return db.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Actualiza un registro localmente
  Future<int> updateEntity(
    String table,
    int id,
    Map<String, Object?> row,
  ) async {
    final db = await _db;
    return db.update(table, row, where: 'id = ?', whereArgs: [id]);
  }

  /// Elimina un registro localmente
  Future<int> deleteEntity(String table, int id, {bool softDelete = false}) async {
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

  /// Actualiza el ID temporal asignado offline con el ID remoto devuelto por el servidor
  Future<void> markEntitySynced(
    String table,
    int localId,
    int? remoteId,
  ) async {
    final db = await _db;
    if (remoteId != null && remoteId != localId) {
      // Eliminar el registro antiguo con id local temporal y volver a insertar con nuevo id
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

  /// Reemplaza referencias de clave foránea cuando se obtiene el ID remoto
  Future<void> updateForeignKeyReference({
    required String table,
    required String foreignKeyColumn,
    required int oldId,
    required int newId,
  }) async {
    final db = await _db;
    await db.update(
      table,
      {foreignKeyColumn: newId},
      where: '$foreignKeyColumn = ?',
      whereArgs: [oldId],
    );
  }

  /// Retorna los registros que aún no se han sincronizado
  Future<List<Map<String, Object?>>> getUnsyncedEntities(String table) async {
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
    final db = await _db;
    await db.update(
      'pending_operations',
      {'local_id': localId},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<PendingOperation>> pendingOperations() async {
    final db = await _db;
    final rows = await db.query('pending_operations', orderBy: 'id ASC');
    return rows.map(PendingOperation.fromRow).toList();
  }

  Future<int> pendingCount() async {
    final db = await _db;
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM pending_operations',
    );
    return Sqflite.firstIntValue(rows) ?? 0;
  }

  Future<void> deleteOperation(int id) async {
    final db = await _db;
    await db.delete('pending_operations', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markOperationFailed(int id, String error) async {
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
