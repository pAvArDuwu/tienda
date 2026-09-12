class UnidadMedida {
  final int id;
  final String nombre;
  final String? abreviatura;
  const UnidadMedida({required this.id, required this.nombre, this.abreviatura});
  factory UnidadMedida.fromJson(Map<String, dynamic> json) => UnidadMedida(
        id: int.parse(json['id'].toString()), nombre: json['nombre']?.toString() ?? '',
        abreviatura: json['abreviatura']?.toString());
  Map<String, dynamic> toJson() => {'nombre': nombre, 'abreviatura': abreviatura};
}
