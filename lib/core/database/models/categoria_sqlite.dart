import '../../../model/categoria.dart';
import '../base_entity.dart';

class SqliteCategoria extends SqliteEntity {
  final String nombre;
  final String? descripcion;
  final bool activo;

  const SqliteCategoria({
    required super.id,
    required this.nombre,
    this.descripcion,
    required this.activo,
    super.isSynced = true,
    super.syncAction = 'none',
    super.remoteId,
  });

  factory SqliteCategoria.fromDomain(
    Categoria c, {
    bool isSynced = true,
    String syncAction = 'none',
    int? remoteId,
  }) {
    return SqliteCategoria(
      id: c.id,
      nombre: c.nombre,
      descripcion: c.descripcion,
      activo: c.activo,
      isSynced: isSynced,
      syncAction: syncAction,
      remoteId: remoteId,
    );
  }

  Categoria toDomain() {
    return Categoria(
      id: remoteId ?? id,
      nombre: nombre,
      descripcion: descripcion,
      activo: activo,
    );
  }

  factory SqliteCategoria.fromMap(Map<String, Object?> map) {
    return SqliteCategoria(
      id: map['id'] as int,
      nombre: (map['nombre'] ?? '') as String,
      descripcion: map['descripcion'] as String?,
      activo: (map['activo'] as int? ?? 1) == 1,
      isSynced: (map['is_synced'] as int? ?? 1) == 1,
      syncAction: (map['sync_action'] ?? 'none') as String,
      remoteId: map['remote_id'] as int?,
    );
  }

  @override
  Map<String, Object?> toMap() => {
    'id': id,
    'nombre': nombre,
    'descripcion': descripcion,
    'activo': activo ? 1 : 0,
    'is_synced': isSynced ? 1 : 0,
    'sync_action': syncAction,
    'remote_id': remoteId,
  };
}
