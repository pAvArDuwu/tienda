import '../../../model/pago.dart';
import '../base_entity.dart';

class SqlitePago extends SqliteEntity {
  final int ventaId;
  final int metodoPagoId;
  final double monto;
  final String? fecha;
  final String? referencia;

  const SqlitePago({
    required super.id,
    required this.ventaId,
    required this.metodoPagoId,
    required this.monto,
    this.fecha,
    this.referencia,
    super.isSynced = true,
    super.syncAction = 'none',
    super.remoteId,
  });

  factory SqlitePago.fromDomain(
    Pago p, {
    bool isSynced = true,
    String syncAction = 'none',
    int? remoteId,
  }) {
    return SqlitePago(
      id: p.id,
      ventaId: p.ventaId,
      metodoPagoId: p.metodoPagoId,
      monto: p.monto,
      fecha: p.fecha,
      referencia: p.referencia,
      isSynced: isSynced,
      syncAction: syncAction,
      remoteId: remoteId,
    );
  }

  Pago toDomain() {
    return Pago(
      id: remoteId ?? id,
      ventaId: ventaId,
      metodoPagoId: metodoPagoId,
      monto: monto,
      fecha: fecha,
      referencia: referencia,
    );
  }

  factory SqlitePago.fromMap(Map<String, Object?> map) {
    return SqlitePago(
      id: map['id'] as int,
      ventaId: map['venta_id'] as int? ?? 0,
      metodoPagoId: map['metodo_pago_id'] as int? ?? 1,
      monto: (map['monto'] as num?)?.toDouble() ?? 0.0,
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
    'venta_id': ventaId,
    'metodo_pago_id': metodoPagoId,
    'monto': monto,
    'fecha': fecha,
    'referencia': referencia,
    'is_synced': isSynced ? 1 : 0,
    'sync_action': syncAction,
    'remote_id': remoteId,
  };
}
