class Compra {
  final int id;
  final int proveedorId;
  final int estadoCompraId;
  final String? fecha;
  final double total;
  const Compra({required this.id, required this.proveedorId, required this.estadoCompraId, this.fecha, required this.total});
  factory Compra.fromJson(Map<String, dynamic> json) => Compra(
        id: int.parse(json['id'].toString()), proveedorId: int.parse(json['proveedor_id'].toString()),
        estadoCompraId: int.parse(json['estado_compra_id'].toString()),
        fecha: json['fecha']?.toString(), total: double.parse(json['total'].toString()));
  Map<String, dynamic> toJson() => {'proveedor_id': proveedorId, 'estado_compra_id': estadoCompraId, 'total': total};
}
