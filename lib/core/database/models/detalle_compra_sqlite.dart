import '../../../model/detalle_compra.dart';
import '../base_entity.dart';

class SqliteDetalleCompra extends SqliteEntity {
  final int compraId;
  final int productoId;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;

  const SqliteDetalleCompra({
    required super.id,
    required this.compraId,
    required this.productoId,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
    super.isSynced = true,
    super.syncAction = 'none',
    super.remoteId,
  });

  factory SqliteDetalleCompra.fromDomain(
    DetalleCompra d, {
    bool isSynced = true,
    String syncAction = 'none',
    int? remoteId,
  }) {
    return SqliteDetalleCompra(
      id: d.id,
      compraId: d.compraId,
      productoId: d.productoId,
      cantidad: d.cantidad,
      precioUnitario: d.precioUnitario,
      subtotal: d.subtotal,
      isSynced: isSynced,
      syncAction: syncAction,
      remoteId: remoteId,
    );
  }

  DetalleCompra toDomain() {
    return DetalleCompra(
      id: remoteId ?? id,
      compraId: compraId,
      productoId: productoId,
      cantidad: cantidad,
      precioUnitario: precioUnitario,
      subtotal: subtotal,
    );
  }

  factory SqliteDetalleCompra.fromMap(Map<String, Object?> map) {
    return SqliteDetalleCompra(
      id: map['id'] as int,
      compraId: map['compra_id'] as int? ?? 0,
      productoId: map['producto_id'] as int? ?? 0,
      cantidad: map['cantidad'] as int? ?? 1,
      precioUnitario: (map['precio_unitario'] as num?)?.toDouble() ?? 0.0,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      isSynced: (map['is_synced'] as int? ?? 1) == 1,
      syncAction: (map['sync_action'] ?? 'none') as String,
      remoteId: map['remote_id'] as int?,
    );
  }

  @override
  Map<String, Object?> toMap() => {
    'id': id,
    'compra_id': compraId,
    'producto_id': productoId,
    'cantidad': cantidad,
    'precio_unitario': precioUnitario,
    'subtotal': subtotal,
    'is_synced': isSynced ? 1 : 0,
    'sync_action': syncAction,
    'remote_id': remoteId,
  };
}
