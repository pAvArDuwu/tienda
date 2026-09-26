import '../../../model/metodo_pago.dart';
import '../base_entity.dart';

class SqliteMetodoPago extends SqliteEntity {
  final String nombre;
  final String? descripcion;
  final bool activo;

  const SqliteMetodoPago({
    required super.id,
    required this.nombre,
    this.descripcion,
    required this.activo,
    super.isSynced = true,
    super.syncAction = 'none',
    super.remoteId,
  });

  factory SqliteMetodoPago.fromDomain(
    MetodoPago m, {
    bool isSynced = true,
    String syncAction = 'none',
    int? remoteId,
  }) {
    return SqliteMetodoPago(
      id: m.id,
      nombre: m.nombre,
      descripcion: m.descripcion,
      activo: m.activo,
      isSynced: isSynced,
      syncAction: syncAction,
      remoteId: remoteId,
    );
  }

  MetodoPago toDomain() {
    return MetodoPago(
      id: remoteId ?? id,
      nombre: nombre,
      descripcion: descripcion,
      activo: activo,
    );
  }

  factory SqliteMetodoPago.fromMap(Map<String, Object?> map) {
    return SqliteMetodoPago(
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
