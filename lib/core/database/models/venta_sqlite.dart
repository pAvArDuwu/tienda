import '../../../model/venta.dart';
import '../base_entity.dart';

class SqliteVenta extends SqliteEntity {
  final int clienteId;
  final int estadoVentaId;
  final String? fecha;
  final double total;

  const SqliteVenta({
    required super.id,
    required this.clienteId,
    required this.estadoVentaId,
    this.fecha,
    required this.total,
    super.isSynced = true,
    super.syncAction = 'none',
    super.remoteId,
  });

  factory SqliteVenta.fromDomain(
    Venta v, {
    bool isSynced = true,
    String syncAction = 'none',
    int? remoteId,
  }) {
    return SqliteVenta(
      id: v.id,
      clienteId: v.clienteId,
      estadoVentaId: v.estadoVentaId,
      fecha: v.fecha,
      total: v.total,
      isSynced: isSynced,
      syncAction: syncAction,
      remoteId: remoteId,
    );
  }

  Venta toDomain() {
    return Venta(
      id: remoteId ?? id,
      clienteId: clienteId,
      estadoVentaId: estadoVentaId,
      fecha: fecha,
      total: total,
    );
  }

  factory SqliteVenta.fromMap(Map<String, Object?> map) {
    return SqliteVenta(
      id: map['id'] as int,
      clienteId: map['cliente_id'] as int? ?? 1,
      estadoVentaId: map['estado_venta_id'] as int? ?? 1,
      fecha: map['fecha'] as String?,
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      isSynced: (map['is_synced'] as int? ?? 1) == 1,
      syncAction: (map['sync_action'] ?? 'none') as String,
      remoteId: map['remote_id'] as int?,
    );
  }

  @override
  Map<String, Object?> toMap() => {
    'id': id,
    'cliente_id': clienteId,
    'estado_venta_id': estadoVentaId,
    'fecha': fecha,
    'total': total,
    'is_synced': isSynced ? 1 : 0,
    'sync_action': syncAction,
    'remote_id': remoteId,
  };
}
