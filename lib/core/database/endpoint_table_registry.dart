import 'tables.dart';

/// Registro de mapeo entre rutas de endpoints de API y nombres de tablas SQLite.
class EndpointTableRegistry {
  static const Map<String, String> _endpointToTable = {
    '/api/categorias': SqliteTables.categorias,
    '/api/clientes': SqliteTables.clientes,
    '/api/proveedores': SqliteTables.proveedores,
    '/api/productos': SqliteTables.productos,
    '/api/estados-compra': SqliteTables.estadosCompra,
    '/api/estados-venta': SqliteTables.estadosVenta,
    '/api/metodos-pago': SqliteTables.metodosPago,
    '/api/tipos-movimiento': SqliteTables.tiposMovimiento,
    '/api/unidades-medida': SqliteTables.unidadesMedida,
    '/api/ventas': SqliteTables.ventas,
    '/api/detalles-venta': SqliteTables.detallesVenta,
    '/api/compras': SqliteTables.compras,
    '/api/detalles-compra': SqliteTables.detallesCompra,
    '/api/movimientos-inventario': SqliteTables.movimientosInventario,
    '/api/pagos': SqliteTables.pagos,
  };

  static String? getTableForEndpoint(String endpoint) {
    // Busca coincidencia exacta o base del endpoint
    for (final entry in _endpointToTable.entries) {
      if (endpoint == entry.key || endpoint.startsWith('${entry.key}/')) {
        return entry.value;
      }
    }
    return null;
  }

  /// Convierte un mapa recibido de la API a formato SQLite según la tabla
  static Map<String, Object?> apiJsonToSqliteMap(
    String table,
    Map<String, dynamic> json, {
    int? localId,
    bool isSynced = true,
    String syncAction = 'none',
  }) {
    final map = Map<String, Object?>.from(json);

    // Normalizar ID
    if (localId != null) {
      map['id'] = localId;
    } else if (map.containsKey('id')) {
      map['id'] = int.tryParse(map['id'].toString()) ?? 0;
    }

    // Normalizar booleanos a int para SQLite
    if (map.containsKey('activo')) {
      final val = map['activo'];
      map['activo'] =
          (val == true ||
              val == 1 ||
              val.toString() == '1' ||
              val.toString() == 'true')
          ? 1
          : 0;
    }

    // Normalizar numéricos
    if (map.containsKey('precio')) {
      map['precio'] = (map['precio'] as num?)?.toDouble() ?? 0.0;
    }
    if (map.containsKey('total')) {
      map['total'] = (map['total'] as num?)?.toDouble() ?? 0.0;
    }
    if (map.containsKey('cantidad')) {
      if (table == SqliteTables.movimientosInventario) {
        map['cantidad'] = (map['cantidad'] as num?)?.toDouble() ?? 0.0;
      } else {
        map['cantidad'] = int.tryParse(map['cantidad'].toString()) ?? 1;
      }
    }
    if (map.containsKey('precio_unitario')) {
      map['precio_unitario'] =
          (map['precio_unitario'] as num?)?.toDouble() ?? 0.0;
    }
    if (map.containsKey('subtotal')) {
      map['subtotal'] = (map['subtotal'] as num?)?.toDouble() ?? 0.0;
    }
    if (map.containsKey('monto')) {
      map['monto'] = (map['monto'] as num?)?.toDouble() ?? 0.0;
    }

    // Flags de sincronización
    map['is_synced'] = isSynced ? 1 : 0;
    map['sync_action'] = syncAction;
    map['remote_id'] =
        json['id'] != null ? int.tryParse(json['id'].toString()) : null;

    return map;
  }

  /// Convierte un registro SQLite a formato JSON para enviar a la API REST
  static Map<String, dynamic> sqliteMapToApiJson(
    String table,
    Map<String, Object?> map,
  ) {
    final json = Map<String, dynamic>.from(map);

    // Remover campos internos de SQLite y sincronización
    json.remove('is_synced');
    json.remove('sync_action');
    json.remove('remote_id');

    // Si el ID es negativo (ID temporal offline), no se envía en el POST al servidor
    final id = json['id'];
    if (id is int && id < 0) {
      json.remove('id');
    }

    // Convertir int de SQLite a bool si aplica
    if (json.containsKey('activo')) {
      json['activo'] = json['activo'] == 1;
    }

    return json;
  }
}
