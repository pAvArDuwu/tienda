class EstadoVenta {
  final int id;
  final String nombre;
  final String? descripcion;
  const EstadoVenta({required this.id, required this.nombre, this.descripcion});
  factory EstadoVenta.fromJson(Map<String, dynamic> json) => EstadoVenta(
        id: int.parse(json['id'].toString()), nombre: json['nombre']?.toString() ?? '',
        descripcion: json['descripcion']?.toString());
  Map<String, dynamic> toJson() => {'nombre': nombre, 'descripcion': descripcion};
}
