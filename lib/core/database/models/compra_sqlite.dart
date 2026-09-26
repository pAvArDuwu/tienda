import '../../../model/compra.dart';
import '../base_entity.dart';

class SqliteCompra extends SqliteEntity {
  final int proveedorId;
  final int estadoCompraId;
  final String? fecha;
  final double total;

  const SqliteCompra({
    required super.id,
    required this.proveedorId,
    required this.estadoCompraId,
    this.fecha,
    required this.total,
    super.isSynced = true,
    super.syncAction = 'none',
    super.remoteId,
  });

  factory SqliteCompra.fromDomain(
    Compra c, {
    bool isSynced = true,
    String syncAction = 'none',
    int? remoteId,
  }) {
    return SqliteCompra(
      id: c.id,
      proveedorId: c.proveedorId,
      estadoCompraId: c.estadoCompraId,
      fecha: c.fecha,
      total: c.total,
      isSynced: isSynced,
      syncAction: syncAction,
      remoteId: remoteId,
    );
  }

  Compra toDomain() {
    return Compra(
      id: remoteId ?? id,
      proveedorId: proveedorId,
      estadoCompraId: estadoCompraId,
      fecha: fecha,
      total: total,
    );
  }

  factory SqliteCompra.fromMap(Map<String, Object?> map) {
    return SqliteCompra(
      id: map['id'] as int,
      proveedorId: map['proveedor_id'] as int? ?? 1,
      estadoCompraId: map['estado_compra_id'] as int? ?? 1,
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
    'proveedor_id': proveedorId,
    'estado_compra_id': estadoCompraId,
    'fecha': fecha,
    'total': total,
    'is_synced': isSynced ? 1 : 0,
    'sync_action': syncAction,
    'remote_id': remoteId,
  };
}
