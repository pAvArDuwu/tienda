class Proveedor {
  final int id;
  final String nombre;
  final String? contacto;
  final String? telefono;
  final String? email;
  final String? direccion;
  final bool activo;

  const Proveedor({
    required this.id,
    required this.nombre,
    this.contacto,
    this.telefono,
    this.email,
    this.direccion,
    this.activo = true,
  });

  factory Proveedor.fromJson(Map<String, dynamic> json) => Proveedor(
        id: int.parse(json['id'].toString()),
        nombre: json['nombre']?.toString() ?? '',
        contacto: json['contacto']?.toString(),
        telefono: json['telefono']?.toString(),
        email: json['email']?.toString(),
        direccion: json['direccion']?.toString(),
        activo: json['activo'] != false && json['activo'].toString() != '0',
      );

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'telefono': telefono,
        'email': email,
        'direccion': direccion,
        'activo': activo,
      };
}
