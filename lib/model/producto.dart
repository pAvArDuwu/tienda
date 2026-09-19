class Producto {
  final int id;
  final int categoriaId;
  final int unidadMedidaId;
  final String nombre;
  final double precio;

  const Producto({
    required this.id,
    this.categoriaId = 1,
    this.unidadMedidaId = 1,
    required this.nombre,
    required this.precio,
  });

  factory Producto.fromJson(Map<String, dynamic> json) => Producto(
        id: int.parse(json['id'].toString()),
        categoriaId: int.parse((json['categoria_id'] ?? 1).toString()),
        unidadMedidaId: int.parse((json['unidad_medida_id'] ?? 1).toString()),
        nombre: json['nombre']?.toString() ?? '',
        precio: double.parse(json['precio'].toString()),
      );

  Map<String, dynamic> toJson() => {
        'categoria_id': categoriaId,
        'unidad_medida_id': unidadMedidaId,
        'nombre': nombre,
        'precio': precio,
      };
}
