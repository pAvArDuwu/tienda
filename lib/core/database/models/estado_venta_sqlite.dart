import '../../../model/estado_venta.dart';
import '../base_entity.dart';

class SqliteEstadoVenta extends SqliteEntity {
  final String nombre;
  final String? descripcion;

  const SqliteEstadoVenta({
    required super.id,
    required this.nombre,
    this.descripcion,
    super.isSynced = true,
    super.syncAction = 'none',
    super.remoteId,
  });

  factory SqliteEstadoVenta.fromDomain(
    EstadoVenta e, {
    bool isSynced = true,
    String syncAction = 'none',
    int? remoteId,
  }) {
    return SqliteEstadoVenta(
      id: e.id,
      nombre: e.nombre,
      descripcion: e.descripcion,
      isSynced: isSynced,
      syncAction: syncAction,
      remoteId: remoteId,
    );
  }

  EstadoVenta toDomain() {
    return EstadoVenta(
      id: remoteId ?? id,
      nombre: nombre,
      descripcion: descripcion,
    );
  }

  factory SqliteEstadoVenta.fromMap(Map<String, Object?> map) {
    return SqliteEstadoVenta(
      id: map['id'] as int,
      nombre: (map['nombre'] ?? '') as String,
      descripcion: map['descripcion'] as String?,
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
    'is_synced': isSynced ? 1 : 0,
    'sync_action': syncAction,
    'remote_id': remoteId,
  };
}
