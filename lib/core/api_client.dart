import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'app_constants.dart';
import 'offline_database.dart';
import 'sqlite_models.dart';

class ApiClient {
  static const Duration _requestTimeout = Duration(seconds: 6);
  static final OfflineDatabase _offlineDb = OfflineDatabase.instance;
  static final ValueNotifier<OfflineSyncStatus> syncStatus = ValueNotifier(
    const OfflineSyncStatus(),
  );

  static bool _syncing = false;
  static Timer? _syncTimer;

  static bool get _supportsOfflineStorage => !kIsWeb;

  static String get _base => AppConstants.baseUrl;

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<void> initialize() async {
    if (!_supportsOfflineStorage) return;

    await _updateStatus(clearMessage: true);
    _syncTimer ??= Timer.periodic(
      const Duration(seconds: 30),
      (_) => unawaited(syncPendingOperations()),
    );
    unawaited(syncPendingOperations());
  }

  static Future<dynamic> get(String path) async {
    await syncPendingOperations();

    late http.Response response;
    try {
      response = await _sendNetwork('GET', path, null);
    } catch (error) {
      return _cachedGetOrThrow(path, error);
    }

    _checkStatus(response);
    final decoded = _decodeBody(response.body);
    if (_supportsOfflineStorage) {
      await _offlineDb.saveResponse(path, response.body);
      final table = EndpointTableRegistry.getTableForEndpoint(path);
      if (table != null && decoded is List) {
        final items = decoded.whereType<Map<String, dynamic>>().toList();
        if (items.isNotEmpty) {
          await _offlineDb.saveEntitiesFromApi(table, items);
        }
      }
      await _updateStatus(
        online: true,
        usingOfflineData: false,
        clearMessage: true,
      );
    }
    return decoded;
  }

  static Future<dynamic> post(String path, Map<String, dynamic> body) async {
    return _mutate('POST', path, body);
  }

  static Future<dynamic> put(String path, Map<String, dynamic> body) async {
    return _mutate('PUT', path, body);
  }

  static Future<void> delete(String path) async {
    await _mutate('DELETE', path, null);
  }

  static Future<void> syncPendingOperations() async {
    if (!_supportsOfflineStorage) return;
    if (_syncing) return;
    _syncing = true;
    await _updateStatus(syncing: true);

    try {
      final operations = await _offlineDb.pendingOperations();
      for (final operation in operations) {
        final body = _mapFromJson(operation.body);
        late http.Response response;

        try {
          response = await _sendNetwork(operation.method, operation.path, body);
          _checkStatus(response);
        } on ApiException catch (error) {
          await _offlineDb.markOperationFailed(operation.id, error.message);
          await _updateStatus(
            online: true,
            syncing: false,
            message: 'Hay cambios pendientes con error del servidor.',
          );
          return;
        } catch (error) {
          await _offlineDb.markOperationFailed(operation.id, error.toString());
          await _updateStatus(
            online: false,
            syncing: false,
            message: 'Sin conexion para sincronizar cambios.',
          );
          return;
        }

        final decoded = _decodeBody(response.body);
        await _applySyncedMutation(operation, decoded);
        await _offlineDb.deleteOperation(operation.id);
      }

      await _updateStatus(
        online: true,
        syncing: false,
        usingOfflineData: false,
        clearMessage: true,
      );
    } finally {
      _syncing = false;
      await _updateStatus(syncing: false);
    }
  }

  static Future<dynamic> _mutate(
    String method,
    String path,
    Map<String, dynamic>? body,
  ) async {
    await syncPendingOperations();

    late http.Response response;
    try {
      response = await _sendNetwork(method, path, body);
    } catch (_) {
      if (!_supportsOfflineStorage) {
        throw const ApiException('Sin conexion.', 0);
      }
      return _queueOfflineMutation(method, path, body);
    }

    _checkStatus(response);
    final decoded = _decodeBody(response.body);
    await _applyOnlineMutation(method, path, body, decoded);
    await _updateStatus(
      online: true,
      usingOfflineData: false,
      clearMessage: true,
    );
    return decoded;
  }

  static Future<dynamic> _cachedGetOrThrow(String path, Object error) async {
    if (!_supportsOfflineStorage) {
      throw const ApiException('Sin conexion.', 0);
    }

    final table = EndpointTableRegistry.getTableForEndpoint(path);
    if (table != null) {
      final id = _idFromPath(path);
      if (id != null) {
        final entity = await _offlineDb.getEntityById(table, id);
        if (entity != null) {
          await _updateStatus(
            online: false,
            usingOfflineData: true,
            message: 'Mostrando datos locales (SQLite).',
          );
          return EndpointTableRegistry.sqliteMapToApiJson(table, entity);
        }
      } else {
        final localEntities = await _offlineDb.getAllEntities(table);
        if (localEntities.isNotEmpty) {
          final apiItems = localEntities
              .map((row) => EndpointTableRegistry.sqliteMapToApiJson(table, row))
              .toList();
          await _updateStatus(
            online: false,
            usingOfflineData: true,
            message: 'Mostrando datos locales (SQLite).',
          );
          return apiItems;
        }
      }
    }

    final cached = await _offlineDb.cachedResponse(path);
    if (cached != null) {
      await _updateStatus(
        online: false,
        usingOfflineData: true,
        message: 'Mostrando datos locales.',
      );
      return _decodeBody(cached);
    }

    await _updateStatus(
      online: false,
      usingOfflineData: false,
      message: 'Sin conexion y sin datos locales.',
    );
    throw ApiException(
      'Sin conexion y sin datos locales para esta pantalla.',
      0,
    );
  }

  static Future<dynamic> _queueOfflineMutation(
    String method,
    String path,
    Map<String, dynamic>? body,
  ) async {
    final encodedBody = body == null ? null : jsonEncode(body);
    final operationId = await _offlineDb.enqueueOperation(
      method: method,
      requestPath: path,
      body: encodedBody,
    );

    int? localId;
    if (method == 'POST') {
      localId = -operationId;
      await _offlineDb.setOperationLocalId(operationId, localId);
    } else {
      localId = _idFromPath(path);
    }

    final table = EndpointTableRegistry.getTableForEndpoint(path);
    if (table != null) {
      if (method == 'POST' && body != null && localId != null) {
        final sqliteRow = EndpointTableRegistry.apiJsonToSqliteMap(
          table,
          body,
          localId: localId,
          isSynced: false,
          syncAction: 'insert',
        );
        await _offlineDb.insertEntity(table, sqliteRow);
      } else if (method == 'PUT' && body != null && localId != null) {
        final sqliteRow = EndpointTableRegistry.apiJsonToSqliteMap(
          table,
          body,
          localId: localId,
          isSynced: false,
          syncAction: 'update',
        );
        await _offlineDb.updateEntity(table, localId, sqliteRow);
      } else if (method == 'DELETE' && localId != null) {
        await _offlineDb.deleteEntity(table, localId, softDelete: true);
      }
    }

    await _applyOptimisticMutation(method, path, body, localId);
    await _updateStatus(
      online: false,
      usingOfflineData: true,
      message: 'Cambio guardado localmente.',
    );

    if (method == 'POST') {
      return _localEntityFor(path, body ?? <String, dynamic>{}, localId!);
    }
    return null;
  }

  static Future<http.Response> _sendNetwork(
    String method,
    String path,
    Map<String, dynamic>? body,
  ) {
    final uri = Uri.parse('$_base$path');
    switch (method) {
      case 'GET':
        return http.get(uri, headers: _headers).timeout(_requestTimeout);
      case 'POST':
        return http
            .post(uri, headers: _headers, body: jsonEncode(body))
            .timeout(_requestTimeout);
      case 'PUT':
        return http
            .put(uri, headers: _headers, body: jsonEncode(body))
            .timeout(_requestTimeout);
      case 'DELETE':
        return http.delete(uri, headers: _headers).timeout(_requestTimeout);
      default:
        throw ApiException('Metodo HTTP no soportado: $method', 0);
    }
  }

  static Future<void> _applyOnlineMutation(
    String method,
    String path,
    Map<String, dynamic>? body,
    dynamic decoded,
  ) async {
    if (!_supportsOfflineStorage) return;

    final table = EndpointTableRegistry.getTableForEndpoint(path);
    if (table != null) {
      if (method == 'POST' && body != null) {
        final id = decoded is Map<String, dynamic> ? decoded['id'] : null;
        final intId = id != null ? int.tryParse(id.toString()) : null;
        final row = EndpointTableRegistry.apiJsonToSqliteMap(
          table,
          {...body, if (intId != null) 'id': intId},
          localId: intId,
          isSynced: true,
          syncAction: 'none',
        );
        await _offlineDb.insertEntity(table, row);
      } else if (method == 'PUT' && body != null) {
        final id = _idFromPath(path);
        if (id != null) {
          final row = EndpointTableRegistry.apiJsonToSqliteMap(
            table,
            body,
            localId: id,
            isSynced: true,
            syncAction: 'none',
          );
          await _offlineDb.updateEntity(table, id, row);
        }
      } else if (method == 'DELETE') {
        final id = _idFromPath(path);
        if (id != null) {
          await _offlineDb.deleteEntity(table, id, softDelete: false);
        }
      }
    }

    if (method == 'POST' && body != null) {
      final id = decoded is Map<String, dynamic> ? decoded['id'] : null;
      if (id == null) return;
      final entity = await _localEntityFor(
        path,
        body,
        int.parse(id.toString()),
      );
      if (decoded is Map<String, dynamic>) entity.addAll(decoded);
      await _upsertCachedEntity(path, entity);
      return;
    }

    await _applyOptimisticMutation(method, path, body, _idFromPath(path));
  }

  static Future<void> _applySyncedMutation(
    PendingOperation operation,
    dynamic decoded,
  ) async {
    final table = EndpointTableRegistry.getTableForEndpoint(operation.path);
    if (table != null) {
      if (operation.method == 'POST') {
        final remoteId = decoded is Map<String, dynamic> && decoded['id'] != null
            ? int.tryParse(decoded['id'].toString())
            : null;
        if (operation.localId != null && remoteId != null) {
          await _offlineDb.markEntitySynced(table, operation.localId!, remoteId);
          if (table == SqliteTables.ventas) {
            await _offlineDb.updateForeignKeyReference(
              table: SqliteTables.detallesVenta,
              foreignKeyColumn: 'venta_id',
              oldId: operation.localId!,
              newId: remoteId,
            );
            await _offlineDb.updateForeignKeyReference(
              table: SqliteTables.pagos,
              foreignKeyColumn: 'venta_id',
              oldId: operation.localId!,
              newId: remoteId,
            );
          } else if (table == SqliteTables.compras) {
            await _offlineDb.updateForeignKeyReference(
              table: SqliteTables.detallesCompra,
              foreignKeyColumn: 'compra_id',
              oldId: operation.localId!,
              newId: remoteId,
            );
          }
        }
      } else if (operation.method == 'PUT') {
        final id = _idFromPath(operation.path) ?? operation.localId;
        if (id != null) {
          await _offlineDb.markEntitySynced(table, id, id);
        }
      } else if (operation.method == 'DELETE') {
        final id = _idFromPath(operation.path);
        if (id != null) {
          await _offlineDb.deleteEntity(table, id, softDelete: false);
        }
      }
    }

    if (operation.method != 'POST' || operation.localId == null) return;

    final body = _mapFromJson(operation.body) ?? <String, dynamic>{};
    final entity = await _localEntityFor(
      operation.path,
      body,
      operation.localId!,
    );
    if (decoded is Map<String, dynamic>) {
      entity.addAll(decoded);
    }
    await _replaceCachedEntity(operation.path, operation.localId!, entity);
  }

  static Future<void> _applyOptimisticMutation(
    String method,
    String path,
    Map<String, dynamic>? body,
    int? id,
  ) async {
    final collectionPath = _collectionPathForMutation(method, path);
    if (collectionPath == null) return;

    final cached = await _offlineDb.cachedResponse(collectionPath);
    if (cached == null && method != 'POST') return;

    final items = _listFromJson(cached) ?? <dynamic>[];

    if (method == 'POST') {
      if (id == null || body == null) return;
      items.add(await _localEntityFor(collectionPath, body, id));
      await _offlineDb.saveResponse(collectionPath, jsonEncode(items));
      return;
    }

    if (id == null) return;

    if (method == 'DELETE') {
      items.removeWhere((item) => _entityId(item) == id);
      await _offlineDb.saveResponse(collectionPath, jsonEncode(items));
      return;
    }

    if (method == 'PUT' && body != null) {
      var updated = false;
      for (var i = 0; i < items.length; i++) {
        final item = items[i];
        if (_entityId(item) != id || item is! Map) continue;
        items[i] = {...Map<String, dynamic>.from(item), ...body, 'id': id};
        updated = true;
        break;
      }
      if (!updated && path.endsWith('/estado')) {
        for (var i = 0; i < items.length; i++) {
          final item = items[i];
          if (_entityId(item) != id || item is! Map) continue;
          items[i] = {...Map<String, dynamic>.from(item), ...body, 'id': id};
          updated = true;
          break;
        }
      }
      if (updated) {
        await _offlineDb.saveResponse(collectionPath, jsonEncode(items));
      }
    }
  }

  static Future<void> _upsertCachedEntity(
    String collectionPath,
    Map<String, dynamic> entity,
  ) async {
    final cached = await _offlineDb.cachedResponse(collectionPath);
    if (cached == null) return;
    final items = _listFromJson(cached);
    if (items == null) return;

    final id = _entityId(entity);
    final index = items.indexWhere((item) => _entityId(item) == id);
    if (index >= 0) {
      items[index] = entity;
    } else {
      items.add(entity);
    }
    await _offlineDb.saveResponse(collectionPath, jsonEncode(items));
  }

  static Future<void> _replaceCachedEntity(
    String collectionPath,
    int localId,
    Map<String, dynamic> entity,
  ) async {
    final cached = await _offlineDb.cachedResponse(collectionPath);
    final items = _listFromJson(cached);
    if (items == null) return;

    final index = items.indexWhere((item) => _entityId(item) == localId);
    if (index < 0) return;

    items[index] = entity;
    await _offlineDb.saveResponse(collectionPath, jsonEncode(items));
  }

  static Future<Map<String, dynamic>> _localEntityFor(
    String path,
    Map<String, dynamic> body,
    int id,
  ) async {
    final entity = <String, dynamic>{...body, 'id': id};

    switch (path) {
      case '/api/categorias':
      case '/api/metodos-pago':
      case '/api/proveedores':
      case '/api/tipos-movimiento':
        entity.putIfAbsent('activo', () => true);
        break;
      case '/api/compras':
      case '/api/movimientos-inventario':
      case '/api/pagos':
        entity.putIfAbsent('fecha', () => DateTime.now().toIso8601String());
        break;
      case '/api/ventas':
        entity.putIfAbsent('estado_venta_id', () => 1);
        entity.putIfAbsent('fecha', () => DateTime.now().toIso8601String());
        if (!entity.containsKey('total')) {
          entity['total'] = await _estimateVentaTotal(body);
        }
        break;
    }

    return entity;
  }

  static Future<double> _estimateVentaTotal(Map<String, dynamic> body) async {
    final detalles = body['detalles'];
    if (detalles is! List) return 0;

    final cachedProducts = await _offlineDb.cachedResponse('/api/productos');
    final products = _listFromJson(cachedProducts);
    if (products == null) return 0;

    double total = 0;
    for (final detalle in detalles) {
      if (detalle is! Map) continue;
      final productoId = int.tryParse(detalle['producto_id'].toString());
      final cantidad = double.tryParse(detalle['cantidad'].toString()) ?? 0;
      if (productoId == null) continue;

      Map? product;
      for (final item in products) {
        if (_entityId(item) == productoId && item is Map) {
          product = item;
          break;
        }
      }
      if (product is! Map) continue;

      final precio = double.tryParse(product['precio'].toString()) ?? 0;
      total += precio * cantidad;
    }
    return total;
  }

  static String? _collectionPathForMutation(String method, String path) {
    if (method == 'POST') return path;

    if (path.endsWith('/estado')) {
      final parts = path.split('/');
      if (parts.length >= 3) {
        return parts.sublist(0, parts.length - 2).join('/');
      }
    }

    final slashIndex = path.lastIndexOf('/');
    if (slashIndex <= 0) return null;

    final lastSegment = path.substring(slashIndex + 1);
    if (int.tryParse(lastSegment) == null) return null;

    return path.substring(0, slashIndex);
  }

  static int? _idFromPath(String path) {
    final segments = path.split('/').where((segment) => segment.isNotEmpty);
    for (final segment in segments.toList().reversed) {
      final id = int.tryParse(segment);
      if (id != null) return id;
    }
    return null;
  }

  static int? _entityId(dynamic item) {
    if (item is! Map || !item.containsKey('id')) return null;
    return int.tryParse(item['id'].toString());
  }

  static Map<String, dynamic>? _mapFromJson(String? json) {
    if (json == null || json.trim().isEmpty) return null;
    final decoded = jsonDecode(json);
    if (decoded is! Map) return null;
    return Map<String, dynamic>.from(decoded);
  }

  static List<dynamic>? _listFromJson(String? json) {
    if (json == null || json.trim().isEmpty) return null;
    final decoded = jsonDecode(json);
    if (decoded is! List) return null;
    return decoded;
  }

  static dynamic _decodeBody(String body) {
    if (body.trim().isEmpty) return null;
    return jsonDecode(body);
  }

  static Future<void> _updateStatus({
    bool? online,
    bool? usingOfflineData,
    bool? syncing,
    String? message,
    bool clearMessage = false,
  }) async {
    final current = syncStatus.value;
    final pending = _supportsOfflineStorage
        ? await _offlineDb.pendingCount()
        : 0;
    syncStatus.value = OfflineSyncStatus(
      online: online ?? current.online,
      usingOfflineData: usingOfflineData ?? current.usingOfflineData,
      syncing: syncing ?? current.syncing,
      pendingOperations: pending,
      message: clearMessage ? null : message ?? current.message,
    );
  }

  static void _checkStatus(http.Response response) {
    if (response.statusCode >= 400) {
      dynamic body = {};
      try {
        body = jsonDecode(response.body);
      } catch (_) {}
      final msg = body is Map
          ? body['error'] ?? body['message'] ?? 'Error ${response.statusCode}'
          : 'Error ${response.statusCode}';
      throw ApiException(msg.toString(), response.statusCode);
    }
  }
}

class OfflineSyncStatus {
  final bool online;
  final bool usingOfflineData;
  final bool syncing;
  final int pendingOperations;
  final String? message;

  const OfflineSyncStatus({
    this.online = true,
    this.usingOfflineData = false,
    this.syncing = false,
    this.pendingOperations = 0,
    this.message,
  });

  bool get hasNotice =>
      syncing || !online || usingOfflineData || pendingOperations > 0;

  String get label {
    if (syncing && pendingOperations > 0) {
      return 'Sincronizando $pendingOperations cambios pendientes...';
    }
    if (!online && usingOfflineData) {
      return pendingOperations > 0
          ? 'Modo offline: $pendingOperations cambios pendientes'
          : 'Modo offline: usando datos locales';
    }
    if (!online) {
      return message ?? 'Sin conexion';
    }
    if (pendingOperations > 0) {
      return '$pendingOperations cambios pendientes por sincronizar';
    }
    return message ?? '';
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  const ApiException(this.message, this.statusCode);
  @override
  String toString() => 'ApiException($statusCode): $message';
}
