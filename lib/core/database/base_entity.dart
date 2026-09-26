/// Clase base para modelos SQLite con soporte de sincronización
abstract class SqliteEntity {
  final int id;
  final bool isSynced;
  final String syncAction; // 'none', 'insert', 'update', 'delete'
  final int? remoteId;

  const SqliteEntity({
    required this.id,
    this.isSynced = true,
    this.syncAction = 'none',
    this.remoteId,
  });

  Map<String, Object?> toMap();
}
