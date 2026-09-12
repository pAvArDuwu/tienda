class DetalleVenta {
  final int id;
  final int ventaId;
  final int productoId;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;
  const DetalleVenta({required this.id, required this.ventaId, required this.productoId, required this.cantidad, required this.precioUnitario, required this.subtotal});
  factory DetalleVenta.fromJson(Map<String, dynamic> json) => DetalleVenta(
        id: int.parse(json['id'].toString()), ventaId: int.parse(json['venta_id'].toString()),
        productoId: int.parse(json['producto_id'].toString()), cantidad: int.parse(json['cantidad'].toString()),
        precioUnitario: double.parse(json['precio_unitario'].toString()), subtotal: double.parse(json['subtotal'].toString()));
  Map<String, dynamic> toJson() => {'venta_id': ventaId, 'producto_id': productoId, 'cantidad': cantidad, 'precio_unitario': precioUnitario, 'subtotal': subtotal};
}
