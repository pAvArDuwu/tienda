import '../../../model/producto.dart';
import '../base_entity.dart';

class SqliteProducto extends SqliteEntity {
  final int categoriaId;
  final int unidadMedidaId;
  final String nombre;
  final double precio;

  const SqliteProducto({
    required super.id,
    required this.categoriaId,
    required this.unidadMedidaId,
    required this.nombre,
    required this.precio,
    super.isSynced = true,
    super.syncAction = 'none',
    super.remoteId,
  });

  factory SqliteProducto.fromDomain(
    Producto p, {
    bool isSynced = true,
    String syncAction = 'none',
    int? remoteId,
  }) {
    return SqliteProducto(
      id: p.id,
      categoriaId: p.categoriaId,
      unidadMedidaId: p.unidadMedidaId,
      nombre: p.nombre,
      precio: p.precio,
      isSynced: isSynced,
      syncAction: syncAction,
      remoteId: remoteId,
    );
  }

  Producto toDomain() {
    return Producto(
      id: remoteId ?? id,
      categoriaId: categoriaId,
      unidadMedidaId: unidadMedidaId,
      nombre: nombre,
      precio: precio,
    );
  }

  factory SqliteProducto.fromMap(Map<String, Object?> map) {
    return SqliteProducto(
      id: map['id'] as int,
      categoriaId: map['categoria_id'] as int? ?? 1,
      unidadMedidaId: map['unidad_medida_id'] as int? ?? 1,
      nombre: (map['nombre'] ?? '') as String,
      precio: (map['precio'] as num?)?.toDouble() ?? 0.0,
      isSynced: (map['is_synced'] as int? ?? 1) == 1,
      syncAction: (map['sync_action'] ?? 'none') as String,
      remoteId: map['remote_id'] as int?,
    );
  }

  @override
  Map<String, Object?> toMap() => {
    'id': id,
    'categoria_id': categoriaId,
    'unidad_medida_id': unidadMedidaId,
    'nombre': nombre,
    'precio': precio,
    'is_synced': isSynced ? 1 : 0,
    'sync_action': syncAction,
    'remote_id': remoteId,
  };
}
