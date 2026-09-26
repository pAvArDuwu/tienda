import '../../../model/tipo_movimiento.dart';
import '../base_entity.dart';

class SqliteTipoMovimiento extends SqliteEntity {
  final String nombre;
  final String? descripcion;
  final int signo;
  final bool activo;

  const SqliteTipoMovimiento({
    required super.id,
    required this.nombre,
    this.descripcion,
    required this.signo,
    required this.activo,
    super.isSynced = true,
    super.syncAction = 'none',
    super.remoteId,
  });

  factory SqliteTipoMovimiento.fromDomain(
    TipoMovimiento t, {
    bool isSynced = true,
    String syncAction = 'none',
    int? remoteId,
  }) {
    return SqliteTipoMovimiento(
      id: t.id,
      nombre: t.nombre,
      descripcion: t.descripcion,
      signo: t.signo,
      activo: t.activo,
      isSynced: isSynced,
      syncAction: syncAction,
      remoteId: remoteId,
    );
  }

  TipoMovimiento toDomain() {
    return TipoMovimiento(
      id: remoteId ?? id,
      nombre: nombre,
      descripcion: descripcion,
      signo: signo,
      activo: activo,
    );
  }

  factory SqliteTipoMovimiento.fromMap(Map<String, Object?> map) {
    return SqliteTipoMovimiento(
      id: map['id'] as int,
      nombre: (map['nombre'] ?? '') as String,
      descripcion: map['descripcion'] as String?,
      signo: map['signo'] as int? ?? 1,
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
    'signo': signo,
    'activo': activo ? 1 : 0,
    'is_synced': isSynced ? 1 : 0,
    'sync_action': syncAction,
    'remote_id': remoteId,
  };
}
