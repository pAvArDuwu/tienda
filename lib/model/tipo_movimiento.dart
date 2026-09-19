class TipoMovimiento {
  final int id;
  final String nombre;
  final String? descripcion;
  final int signo; // 1 = entrada, -1 = salida
  final bool activo;

  const TipoMovimiento({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.signo,
    this.activo = true,
  });

  String get tipo => signo >= 0 ? 'entrada' : 'salida';

  factory TipoMovimiento.fromJson(Map<String, dynamic> json) => TipoMovimiento(
        id: int.parse(json['id'].toString()),
        nombre: json['nombre']?.toString() ?? '',
        descripcion: json['descripcion']?.toString(),
        signo: int.tryParse(json['signo']?.toString() ?? '1') ?? 1,
        activo: json['activo'] != false && json['activo'].toString() != '0',
      );

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'descripcion': descripcion,
        'signo': signo,
        'activo': activo,
      };
}
