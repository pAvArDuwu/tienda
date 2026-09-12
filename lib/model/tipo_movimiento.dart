class TipoMovimiento {
  final int id;
  final String nombre;
  final String tipo;
  const TipoMovimiento({required this.id, required this.nombre, required this.tipo});
  factory TipoMovimiento.fromJson(Map<String, dynamic> json) => TipoMovimiento(
        id: int.parse(json['id'].toString()), nombre: json['nombre']?.toString() ?? '',
        tipo: json['tipo']?.toString() ?? 'entrada');
  Map<String, dynamic> toJson() => {'nombre': nombre, 'tipo': tipo};
}
