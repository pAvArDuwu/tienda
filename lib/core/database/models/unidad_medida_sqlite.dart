import '../../../model/unidad_medida.dart';
import '../base_entity.dart';

class SqliteUnidadMedida extends SqliteEntity {
  final String nombre;
  final String? abreviatura;

  const SqliteUnidadMedida({
    required super.id,
    required this.nombre,
    this.abreviatura,
    super.isSynced = true,
    super.syncAction = 'none',
    super.remoteId,
  });

  factory SqliteUnidadMedida.fromDomain(
    UnidadMedida u, {
    bool isSynced = true,
    String syncAction = 'none',
    int? remoteId,
  }) {
    return SqliteUnidadMedida(
      id: u.id,
      nombre: u.nombre,
      abreviatura: u.abreviatura,
      isSynced: isSynced,
      syncAction: syncAction,
      remoteId: remoteId,
    );
  }

  UnidadMedida toDomain() {
    return UnidadMedida(
      id: remoteId ?? id,
      nombre: nombre,
      abreviatura: abreviatura,
    );
  }

  factory SqliteUnidadMedida.fromMap(Map<String, Object?> map) {
    return SqliteUnidadMedida(
      id: map['id'] as int,
      nombre: (map['nombre'] ?? '') as String,
      abreviatura: map['abreviatura'] as String?,
      isSynced: (map['is_synced'] as int? ?? 1) == 1,
      syncAction: (map['sync_action'] ?? 'none') as String,
      remoteId: map['remote_id'] as int?,
    );
  }

  @override
  Map<String, Object?> toMap() => {
    'id': id,
    'nombre': nombre,
    'abreviatura': abreviatura,
    'is_synced': isSynced ? 1 : 0,
    'sync_action': syncAction,
    'remote_id': remoteId,
  };
}
