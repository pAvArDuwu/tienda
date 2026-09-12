class Categoria {
  final int id;
  final String nombre;
  final String? descripcion;
  final bool activo;

  const Categoria({required this.id, required this.nombre, this.descripcion, required this.activo});

  factory Categoria.fromJson(Map<String, dynamic> json) => Categoria(
        id: int.parse(json['id'].toString()),
        nombre: json['nombre']?.toString() ?? '',
        descripcion: json['descripcion']?.toString(),
        activo: json['activo'].toString() == '1' || json['activo'] == true,
      );

  Map<String, dynamic> toJson() => {'nombre': nombre, 'descripcion': descripcion, 'activo': activo};
}
