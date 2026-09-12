class Producto {
  final int id;
  final String nombre;
  final double precio;
  const Producto({required this.id, required this.nombre, required this.precio});
  factory Producto.fromJson(Map<String, dynamic> json) => Producto(
        id: int.parse(json['id'].toString()), nombre: json['nombre']?.toString() ?? '',
        precio: double.parse(json['precio'].toString()));
  Map<String, dynamic> toJson() => {'nombre': nombre, 'precio': precio};
}
