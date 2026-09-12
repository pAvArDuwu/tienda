class Proveedor {
  final int id;
  final String nombre;
  final String? contacto;
  final String? telefono;
  final String? email;
  final String? direccion;
  const Proveedor({required this.id, required this.nombre, this.contacto, this.telefono, this.email, this.direccion});
  factory Proveedor.fromJson(Map<String, dynamic> json) => Proveedor(
        id: int.parse(json['id'].toString()), nombre: json['nombre']?.toString() ?? '',
        contacto: json['contacto']?.toString(), telefono: json['telefono']?.toString(),
        email: json['email']?.toString(), direccion: json['direccion']?.toString());
  Map<String, dynamic> toJson() => {'nombre': nombre, 'contacto': contacto, 'telefono': telefono, 'email': email, 'direccion': direccion};
}
