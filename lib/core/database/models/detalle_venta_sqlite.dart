import '../../../model/detalle_venta.dart';
import '../base_entity.dart';

class SqliteDetalleVenta extends SqliteEntity {
  final int ventaId;
  final int productoId;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;

  const SqliteDetalleVenta({
    required super.id,
    required this.ventaId,
    required this.productoId,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
    super.isSynced = true,
    super.syncAction = 'none',
    super.remoteId,
  });

  factory SqliteDetalleVenta.fromDomain(
    DetalleVenta d, {
    bool isSynced = true,
    String syncAction = 'none',
    int? remoteId,
  }) {
    return SqliteDetalleVenta(
      id: d.id,
      ventaId: d.ventaId,
      productoId: d.productoId,
      cantidad: d.cantidad,
      precioUnitario: d.precioUnitario,
      subtotal: d.subtotal,
      isSynced: isSynced,
      syncAction: syncAction,
      remoteId: remoteId,
    );
  }

  DetalleVenta toDomain() {
    return DetalleVenta(
      id: remoteId ?? id,
      ventaId: ventaId,
      productoId: productoId,
      cantidad: cantidad,
      precioUnitario: precioUnitario,
      subtotal: subtotal,
    );
  }

  factory SqliteDetalleVenta.fromMap(Map<String, Object?> map) {
    return SqliteDetalleVenta(
      id: map['id'] as int,
      ventaId: map['venta_id'] as int? ?? 0,
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
    'venta_id': ventaId,
    'producto_id': productoId,
    'cantidad': cantidad,
    'precio_unitario': precioUnitario,
    'subtotal': subtotal,
    'is_synced': isSynced ? 1 : 0,
    'sync_action': syncAction,
    'remote_id': remoteId,
  };
}
