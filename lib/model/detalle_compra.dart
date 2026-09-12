class DetalleCompra {
  final int id;
  final int compraId;
  final int productoId;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;
  const DetalleCompra({required this.id, required this.compraId, required this.productoId, required this.cantidad, required this.precioUnitario, required this.subtotal});
  factory DetalleCompra.fromJson(Map<String, dynamic> json) => DetalleCompra(
        id: int.parse(json['id'].toString()), compraId: int.parse(json['compra_id'].toString()),
        productoId: int.parse(json['producto_id'].toString()), cantidad: int.parse(json['cantidad'].toString()),
        precioUnitario: double.parse(json['precio_unitario'].toString()), subtotal: double.parse(json['subtotal'].toString()));
  Map<String, dynamic> toJson() => {'compra_id': compraId, 'producto_id': productoId, 'cantidad': cantidad, 'precio_unitario': precioUnitario, 'subtotal': subtotal};
}
