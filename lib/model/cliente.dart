class Cliente {
  final int id;
  final String nombre;
  final String? apellido;
  final String? telefono;
  final String? email;
  final String? direccion;

  const Cliente({required this.id, required this.nombre, this.apellido, this.telefono, this.email, this.direccion});

  factory Cliente.fromJson(Map<String, dynamic> json) => Cliente(
        id: int.parse(json['id'].toString()),
        nombre: json['nombre']?.toString() ?? '',
        apellido: json['apellido']?.toString(),
        telefono: json['telefono']?.toString(),
        email: json['email']?.toString(),
        direccion: json['direccion']?.toString(),
      );

  Map<String, dynamic> toJson() => {'nombre': nombre, 'apellido': apellido, 'telefono': telefono, 'email': email, 'direccion': direccion};

  String get nombreCompleto => apellido != null ? '$nombre $apellido' : nombre;
}
