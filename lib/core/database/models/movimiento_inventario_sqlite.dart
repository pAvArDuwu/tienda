import '../../../model/movimiento_inventario.dart';
import '../base_entity.dart';

class SqliteMovimientoInventario extends SqliteEntity {
  final int productoId;
  final int tipoMovimientoId;
  final double cantidad;
  final String? fecha;
  final String? referencia;

  const SqliteMovimientoInventario({
    required super.id,
    required this.productoId,
    required this.tipoMovimientoId,
    required this.cantidad,
    this.fecha,
    this.referencia,
    super.isSynced = true,
    super.syncAction = 'none',
    super.remoteId,
  });

  factory SqliteMovimientoInventario.fromDomain(
    MovimientoInventario m, {
    bool isSynced = true,
    String syncAction = 'none',
    int? remoteId,
  }) {
    return SqliteMovimientoInventario(
      id: m.id,
      productoId: m.productoId,
      tipoMovimientoId: m.tipoMovimientoId,
      cantidad: m.cantidad,
      fecha: m.fecha,
      referencia: m.referencia,
      isSynced: isSynced,
      syncAction: syncAction,
      remoteId: remoteId,
    );
  }

  MovimientoInventario toDomain() {
    return MovimientoInventario(
      id: remoteId ?? id,
      productoId: productoId,
      tipoMovimientoId: tipoMovimientoId,
      cantidad: cantidad,
      fecha: fecha,
      referencia: referencia,
    );
  }

  factory SqliteMovimientoInventario.fromMap(Map<String, Object?> map) {
    return SqliteMovimientoInventario(
      id: map['id'] as int,
      productoId: map['producto_id'] as int? ?? 1,
      tipoMovimientoId: map['tipo_movimiento_id'] as int? ?? 1,
      cantidad: (map['cantidad'] as num?)?.toDouble() ?? 0.0,
      fecha: map['fecha'] as String?,
      referencia: map['referencia'] as String?,
      isSynced: (map['is_synced'] as int? ?? 1) == 1,
      syncAction: (map['sync_action'] ?? 'none') as String,
      remoteId: map['remote_id'] as int?,
    );
  }

  @override
  Map<String, Object?> toMap() => {
    'id': id,
    'producto_id': productoId,
    'tipo_movimiento_id': tipoMovimientoId,
    'cantidad': cantidad,
    'fecha': fecha,
    'referencia': referencia,
    'is_synced': isSynced ? 1 : 0,
    'sync_action': syncAction,
    'remote_id': remoteId,
  };
}
