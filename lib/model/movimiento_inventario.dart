class MovimientoInventario {
  final int id;
  final int productoId;
  final int tipoMovimientoId;
  final double cantidad;
  final String? fecha;
  final String? referencia;

  const MovimientoInventario({
    required this.id,
    required this.productoId,
    required this.tipoMovimientoId,
    required this.cantidad,
    this.fecha,
    this.referencia,
  });

  factory MovimientoInventario.fromJson(Map<String, dynamic> json) => MovimientoInventario(
        id: int.parse(json['id'].toString()),
        productoId: int.parse(json['producto_id'].toString()),
        tipoMovimientoId: int.parse(json['tipo_movimiento_id'].toString()),
        cantidad: double.parse(json['cantidad'].toString()),
        fecha: json['fecha']?.toString(),
        referencia: json['referencia']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'producto_id': productoId,
        'tipo_movimiento_id': tipoMovimientoId,
        'cantidad': cantidad,
        'referencia': referencia,
      };
}
