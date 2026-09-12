class EstadoCompra {
  final int id;
  final String nombre;
  final String? descripcion;
  const EstadoCompra({required this.id, required this.nombre, this.descripcion});
  factory EstadoCompra.fromJson(Map<String, dynamic> json) => EstadoCompra(
        id: int.parse(json['id'].toString()), nombre: json['nombre']?.toString() ?? '',
        descripcion: json['descripcion']?.toString());
  Map<String, dynamic> toJson() => {'nombre': nombre, 'descripcion': descripcion};
}
