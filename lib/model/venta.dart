class Venta {
  final int id;
  final int clienteId;
  final String? fecha;
  final double total;
  final String estado;
  const Venta({required this.id, required this.clienteId, this.fecha, required this.total, required this.estado});
  factory Venta.fromJson(Map<String, dynamic> json) => Venta(
        id: int.parse(json['id'].toString()), clienteId: int.parse(json['cliente_id'].toString()),
        fecha: json['fecha']?.toString(), total: double.parse(json['total'].toString()),
        estado: json['estado']?.toString() ?? 'pendiente');
  Map<String, dynamic> toJson() => {'cliente_id': clienteId, 'total': total, 'estado': estado};
}
class DetalleVentaInput {
  final int productoId;
  final int cantidad;
  const DetalleVentaInput({required this.productoId, required this.cantidad});
  Map<String, dynamic> toJson() => {'producto_id': productoId, 'cantidad': cantidad};
}
