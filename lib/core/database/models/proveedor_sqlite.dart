import '../../../model/proveedor.dart';
import '../base_entity.dart';

class SqliteProveedor extends SqliteEntity {
  final String nombre;
  final String? contacto;
  final String? telefono;
  final String? email;
  final String? direccion;
  final bool activo;

  const SqliteProveedor({
    required super.id,
    required this.nombre,
    this.contacto,
    this.telefono,
    this.email,
    this.direccion,
    required this.activo,
    super.isSynced = true,
    super.syncAction = 'none',
    super.remoteId,
  });

  factory SqliteProveedor.fromDomain(
    Proveedor p, {
    bool isSynced = true,
    String syncAction = 'none',
    int? remoteId,
  }) {
    return SqliteProveedor(
      id: p.id,
      nombre: p.nombre,
      contacto: p.contacto,
      telefono: p.telefono,
      email: p.email,
      direccion: p.direccion,
      activo: p.activo,
      isSynced: isSynced,
      syncAction: syncAction,
      remoteId: remoteId,
    );
  }

  Proveedor toDomain() {
    return Proveedor(
      id: remoteId ?? id,
      nombre: nombre,
      contacto: contacto,
      telefono: telefono,
      email: email,
      direccion: direccion,
      activo: activo,
    );
  }

  factory SqliteProveedor.fromMap(Map<String, Object?> map) {
    return SqliteProveedor(
      id: map['id'] as int,
      nombre: (map['nombre'] ?? '') as String,
      contacto: map['contacto'] as String?,
      telefono: map['telefono'] as String?,
      email: map['email'] as String?,
      direccion: map['direccion'] as String?,
      activo: (map['activo'] as int? ?? 1) == 1,
      isSynced: (map['is_synced'] as int? ?? 1) == 1,
      syncAction: (map['sync_action'] ?? 'none') as String,
      remoteId: map['remote_id'] as int?,
    );
  }

  @override
  Map<String, Object?> toMap() => {
    'id': id,
    'nombre': nombre,
    'contacto': contacto,
    'telefono': telefono,
    'email': email,
    'direccion': direccion,
    'activo': activo ? 1 : 0,
    'is_synced': isSynced ? 1 : 0,
    'sync_action': syncAction,
    'remote_id': remoteId,
  };
}
