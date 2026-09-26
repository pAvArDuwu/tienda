import '../../../model/cliente.dart';
import '../base_entity.dart';

class SqliteCliente extends SqliteEntity {
  final String nombre;
  final String? apellido;
  final String? telefono;
  final String? email;
  final String? direccion;

  const SqliteCliente({
    required super.id,
    required this.nombre,
    this.apellido,
    this.telefono,
    this.email,
    this.direccion,
    super.isSynced = true,
    super.syncAction = 'none',
    super.remoteId,
  });

  factory SqliteCliente.fromDomain(
    Cliente c, {
    bool isSynced = true,
    String syncAction = 'none',
    int? remoteId,
  }) {
    return SqliteCliente(
      id: c.id,
      nombre: c.nombre,
      apellido: c.apellido,
      telefono: c.telefono,
      email: c.email,
      direccion: c.direccion,
      isSynced: isSynced,
      syncAction: syncAction,
      remoteId: remoteId,
    );
  }

  Cliente toDomain() {
    return Cliente(
      id: remoteId ?? id,
      nombre: nombre,
      apellido: apellido,
      telefono: telefono,
      email: email,
      direccion: direccion,
    );
  }

  factory SqliteCliente.fromMap(Map<String, Object?> map) {
    return SqliteCliente(
      id: map['id'] as int,
      nombre: (map['nombre'] ?? '') as String,
      apellido: map['apellido'] as String?,
      telefono: map['telefono'] as String?,
      email: map['email'] as String?,
      direccion: map['direccion'] as String?,
      isSynced: (map['is_synced'] as int? ?? 1) == 1,
      syncAction: (map['sync_action'] ?? 'none') as String,
      remoteId: map['remote_id'] as int?,
    );
  }

  @override
  Map<String, Object?> toMap() => {
    'id': id,
    'nombre': nombre,
    'apellido': apellido,
    'telefono': telefono,
    'email': email,
    'direccion': direccion,
    'is_synced': isSynced ? 1 : 0,
    'sync_action': syncAction,
    'remote_id': remoteId,
  };
}
