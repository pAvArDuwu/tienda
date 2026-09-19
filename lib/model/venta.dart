class Venta {
  final int id;
  final int clienteId;
  final int estadoVentaId;
  final String? fecha;
  final double total;

  const Venta({
    required this.id,
    required this.clienteId,
    required this.estadoVentaId,
    this.fecha,
    required this.total,
  });

  String get estado {
    switch (estadoVentaId) {
      case 2:
        return 'pagada';
      case 3:
        return 'cancelada';
      case 1:
      default:
        return 'pendiente';
    }
  }

  factory Venta.fromJson(Map<String, dynamic> json) => Venta(
        id: int.parse(json['id'].toString()),
        clienteId: int.parse(json['cliente_id'].toString()),
        estadoVentaId: int.tryParse(json['estado_venta_id']?.toString() ?? '') ??
            (json['estado'] == 'pagada' ? 2 : json['estado'] == 'cancelada' ? 3 : 1),
        fecha: json['fecha']?.toString(),
        total: double.parse(json['total'].toString()),
      );

  Map<String, dynamic> toJson() => {
        'cliente_id': clienteId,
        'estado_venta_id': estadoVentaId,
        'total': total,
      };
}

class DetalleVentaInput {
  final int productoId;
  final int cantidad;
  const DetalleVentaInput({required this.productoId, required this.cantidad});
  Map<String, dynamic> toJson() => {'producto_id': productoId, 'cantidad': cantidad};
}
