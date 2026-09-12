class Pago {
  final int id;
  final int ventaId;
  final int metodoPagoId;
  final double monto;
  final String? fecha;
  final String? referencia;
  const Pago({required this.id, required this.ventaId, required this.metodoPagoId, required this.monto, this.fecha, this.referencia});
  factory Pago.fromJson(Map<String, dynamic> json) => Pago(
        id: int.parse(json['id'].toString()), ventaId: int.parse(json['venta_id'].toString()),
        metodoPagoId: int.parse(json['metodo_pago_id'].toString()), monto: double.parse(json['monto'].toString()),
        fecha: json['fecha']?.toString(), referencia: json['referencia']?.toString());
  Map<String, dynamic> toJson() => {'venta_id': ventaId, 'metodo_pago_id': metodoPagoId, 'monto': monto, 'referencia': referencia};
}
