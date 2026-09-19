import '../model/categoria.dart';
import '../model/cliente.dart';
import '../model/compra.dart';
import '../model/detalle_compra.dart';
import '../model/detalle_venta.dart';
import '../model/estado_compra.dart';
import '../model/estado_venta.dart';
import '../model/metodo_pago.dart';
import '../model/movimiento_inventario.dart';
import '../model/pago.dart';
import '../model/producto.dart';
import '../model/proveedor.dart';
import '../model/tipo_movimiento.dart';
import '../model/unidad_medida.dart';
import '../model/venta.dart';

/// Define las constantes de nombres de tablas y sentencias DDL para SQLite.
abstract class SqliteTables {
  static const String categorias = 'local_categorias';
  static const String clientes = 'local_clientes';
  static const String proveedores = 'local_proveedores';
  static const String productos = 'local_productos';
  static const String estadosCompra = 'local_estados_compra';
  static const String estadosVenta = 'local_estados_venta';
  static const String metodosPago = 'local_metodos_pago';
  static const String tiposMovimiento = 'local_tipos_movimiento';
  static const String unidadesMedida = 'local_unidades_medida';
  static const String ventas = 'local_ventas';
  static const String detallesVenta = 'local_detalles_venta';
  static const String compras = 'local_compras';
  static const String detallesCompra = 'local_detalles_compra';
  static const String movimientosInventario = 'local_movimientos_inventario';
  static const String pagos = 'local_pagos';

  static const List<String> allCreateStatements = [
    createCategoriasTable,
    createClientesTable,
    createProveedoresTable,
    createProductosTable,
    createEstadosCompraTable,
    createEstadosVentaTable,
    createMetodosPagoTable,
    createTiposMovimientoTable,
    createUnidadesMedidaTable,
    createVentasTable,
    createDetallesVentaTable,
    createComprasTable,
    createDetallesCompraTable,
    createMovimientosInventarioTable,
    createPagosTable,
  ];

  static const String createCategoriasTable = '''
    CREATE TABLE IF NOT EXISTS $categorias (
      id INTEGER PRIMARY KEY,
      nombre TEXT NOT NULL,
      descripcion TEXT,
      activo INTEGER NOT NULL DEFAULT 1,
      is_synced INTEGER NOT NULL DEFAULT 1,
      sync_action TEXT NOT NULL DEFAULT 'none',
      remote_id INTEGER
    )
  ''';

  static const String createClientesTable = '''
    CREATE TABLE IF NOT EXISTS $clientes (
      id INTEGER PRIMARY KEY,
      nombre TEXT NOT NULL,
      apellido TEXT,
      telefono TEXT,
      email TEXT,
      direccion TEXT,
      is_synced INTEGER NOT NULL DEFAULT 1,
      sync_action TEXT NOT NULL DEFAULT 'none',
      remote_id INTEGER
    )
  ''';

  static const String createProveedoresTable = '''
    CREATE TABLE IF NOT EXISTS $proveedores (
      id INTEGER PRIMARY KEY,
      nombre TEXT NOT NULL,
      contacto TEXT,
      telefono TEXT,
      email TEXT,
      direccion TEXT,
      activo INTEGER NOT NULL DEFAULT 1,
      is_synced INTEGER NOT NULL DEFAULT 1,
      sync_action TEXT NOT NULL DEFAULT 'none',
      remote_id INTEGER
    )
  ''';

  static const String createProductosTable = '''
    CREATE TABLE IF NOT EXISTS $productos (
      id INTEGER PRIMARY KEY,
      categoria_id INTEGER NOT NULL DEFAULT 1,
      unidad_medida_id INTEGER NOT NULL DEFAULT 1,
      nombre TEXT NOT NULL,
      precio REAL NOT NULL,
      is_synced INTEGER NOT NULL DEFAULT 1,
      sync_action TEXT NOT NULL DEFAULT 'none',
      remote_id INTEGER
    )
  ''';

  static const String createEstadosCompraTable = '''
    CREATE TABLE IF NOT EXISTS $estadosCompra (
      id INTEGER PRIMARY KEY,
      nombre TEXT NOT NULL,
      descripcion TEXT,
      is_synced INTEGER NOT NULL DEFAULT 1,
      sync_action TEXT NOT NULL DEFAULT 'none',
      remote_id INTEGER
    )
  ''';

  static const String createEstadosVentaTable = '''
    CREATE TABLE IF NOT EXISTS $estadosVenta (
      id INTEGER PRIMARY KEY,
      nombre TEXT NOT NULL,
      descripcion TEXT,
      is_synced INTEGER NOT NULL DEFAULT 1,
      sync_action TEXT NOT NULL DEFAULT 'none',
      remote_id INTEGER
    )
  ''';

  static const String createMetodosPagoTable = '''
    CREATE TABLE IF NOT EXISTS $metodosPago (
      id INTEGER PRIMARY KEY,
      nombre TEXT NOT NULL,
      descripcion TEXT,
      activo INTEGER NOT NULL DEFAULT 1,
      is_synced INTEGER NOT NULL DEFAULT 1,
      sync_action TEXT NOT NULL DEFAULT 'none',
      remote_id INTEGER
    )
  ''';

  static const String createTiposMovimientoTable = '''
    CREATE TABLE IF NOT EXISTS $tiposMovimiento (
      id INTEGER PRIMARY KEY,
      nombre TEXT NOT NULL,
      descripcion TEXT,
      signo INTEGER NOT NULL DEFAULT 1,
      activo INTEGER NOT NULL DEFAULT 1,
      is_synced INTEGER NOT NULL DEFAULT 1,
      sync_action TEXT NOT NULL DEFAULT 'none',
      remote_id INTEGER
    )
  ''';

  static const String createUnidadesMedidaTable = '''
    CREATE TABLE IF NOT EXISTS $unidadesMedida (
      id INTEGER PRIMARY KEY,
      nombre TEXT NOT NULL,
      abreviatura TEXT,
      is_synced INTEGER NOT NULL DEFAULT 1,
      sync_action TEXT NOT NULL DEFAULT 'none',
      remote_id INTEGER
    )
  ''';

  static const String createVentasTable = '''
    CREATE TABLE IF NOT EXISTS $ventas (
      id INTEGER PRIMARY KEY,
      cliente_id INTEGER NOT NULL,
      estado_venta_id INTEGER NOT NULL,
      fecha TEXT,
      total REAL NOT NULL,
      is_synced INTEGER NOT NULL DEFAULT 1,
      sync_action TEXT NOT NULL DEFAULT 'none',
      remote_id INTEGER
    )
  ''';

  static const String createDetallesVentaTable = '''
    CREATE TABLE IF NOT EXISTS $detallesVenta (
      id INTEGER PRIMARY KEY,
      venta_id INTEGER NOT NULL,
      producto_id INTEGER NOT NULL,
      cantidad INTEGER NOT NULL,
      precio_unitario REAL NOT NULL,
      subtotal REAL NOT NULL,
      is_synced INTEGER NOT NULL DEFAULT 1,
      sync_action TEXT NOT NULL DEFAULT 'none',
      remote_id INTEGER
    )
  ''';

  static const String createComprasTable = '''
    CREATE TABLE IF NOT EXISTS $compras (
      id INTEGER PRIMARY KEY,
      proveedor_id INTEGER NOT NULL,
      estado_compra_id INTEGER NOT NULL,
      fecha TEXT,
      total REAL NOT NULL,
      is_synced INTEGER NOT NULL DEFAULT 1,
      sync_action TEXT NOT NULL DEFAULT 'none',
      remote_id INTEGER
    )
  ''';

  static const String createDetallesCompraTable = '''
    CREATE TABLE IF NOT EXISTS $detallesCompra (
      id INTEGER PRIMARY KEY,
      compra_id INTEGER NOT NULL,
      producto_id INTEGER NOT NULL,
      cantidad INTEGER NOT NULL,
      precio_unitario REAL NOT NULL,
      subtotal REAL NOT NULL,
      is_synced INTEGER NOT NULL DEFAULT 1,
      sync_action TEXT NOT NULL DEFAULT 'none',
      remote_id INTEGER
    )
  ''';

  static const String createMovimientosInventarioTable = '''
    CREATE TABLE IF NOT EXISTS $movimientosInventario (
      id INTEGER PRIMARY KEY,
      producto_id INTEGER NOT NULL,
      tipo_movimiento_id INTEGER NOT NULL,
      cantidad REAL NOT NULL,
      fecha TEXT,
      referencia TEXT,
      is_synced INTEGER NOT NULL DEFAULT 1,
      sync_action TEXT NOT NULL DEFAULT 'none',
      remote_id INTEGER
    )
  ''';

  static const String createPagosTable = '''
    CREATE TABLE IF NOT EXISTS $pagos (
      id INTEGER PRIMARY KEY,
      venta_id INTEGER NOT NULL,
      metodo_pago_id INTEGER NOT NULL,
      monto REAL NOT NULL,
      fecha TEXT,
      referencia TEXT,
      is_synced INTEGER NOT NULL DEFAULT 1,
      sync_action TEXT NOT NULL DEFAULT 'none',
      remote_id INTEGER
    )
  ''';
}

/// Clase base para modelos SQLite con soporte de sincronización
abstract class SqliteEntity {
  final int id;
  final bool isSynced;
  final String syncAction; // 'none', 'insert', 'update', 'delete'
  final int? remoteId;

  const SqliteEntity({
    required this.id,
    this.isSynced = true,
    this.syncAction = 'none',
    this.remoteId,
  });

  Map<String, Object?> toMap();
}

// -----------------------------------------------------------------------------
// 1. Categoria SQLite
// -----------------------------------------------------------------------------
class SqliteCategoria extends SqliteEntity {
  final String nombre;
  final String? descripcion;
  final bool activo;

  const SqliteCategoria({
    required super.id,
    required this.nombre,
    this.descripcion,
    required this.activo,
    super.isSynced = true,
    super.syncAction = 'none',
    super.remoteId,
  });

  factory SqliteCategoria.fromDomain(
    Categoria c, {
    bool isSynced = true,
    String syncAction = 'none',
    int? remoteId,
  }) {
    return SqliteCategoria(
      id: c.id,
      nombre: c.nombre,
      descripcion: c.descripcion,
      activo: c.activo,
      isSynced: isSynced,
      syncAction: syncAction,
      remoteId: remoteId,
    );
  }

  Categoria toDomain() {
    return Categoria(
      id: remoteId ?? id,
      nombre: nombre,
      descripcion: descripcion,
      activo: activo,
    );
  }

  factory SqliteCategoria.fromMap(Map<String, Object?> map) {
    return SqliteCategoria(
      id: map['id'] as int,
      nombre: (map['nombre'] ?? '') as String,
      descripcion: map['descripcion'] as String?,
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
    'descripcion': descripcion,
    'activo': activo ? 1 : 0,
    'is_synced': isSynced ? 1 : 0,
    'sync_action': syncAction,
    'remote_id': remoteId,
  };
}

// -----------------------------------------------------------------------------
// 2. Cliente SQLite
// -----------------------------------------------------------------------------
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

// -----------------------------------------------------------------------------
// 3. Proveedor SQLite
// -----------------------------------------------------------------------------
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

// -----------------------------------------------------------------------------
// 4. Producto SQLite
// -----------------------------------------------------------------------------
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

// -----------------------------------------------------------------------------
// 5. EstadoCompra SQLite
// -----------------------------------------------------------------------------
class SqliteEstadoCompra extends SqliteEntity {
  final String nombre;
  final String? descripcion;

  const SqliteEstadoCompra({
    required super.id,
    required this.nombre,
    this.descripcion,
    super.isSynced = true,
    super.syncAction = 'none',
    super.remoteId,
  });

  factory SqliteEstadoCompra.fromDomain(
    EstadoCompra e, {
    bool isSynced = true,
    String syncAction = 'none',
    int? remoteId,
  }) {
    return SqliteEstadoCompra(
      id: e.id,
      nombre: e.nombre,
      descripcion: e.descripcion,
      isSynced: isSynced,
      syncAction: syncAction,
      remoteId: remoteId,
    );
  }

  EstadoCompra toDomain() {
    return EstadoCompra(
      id: remoteId ?? id,
      nombre: nombre,
      descripcion: descripcion,
    );
  }

  factory SqliteEstadoCompra.fromMap(Map<String, Object?> map) {
    return SqliteEstadoCompra(
      id: map['id'] as int,
      nombre: (map['nombre'] ?? '') as String,
      descripcion: map['descripcion'] as String?,
      isSynced: (map['is_synced'] as int? ?? 1) == 1,
      syncAction: (map['sync_action'] ?? 'none') as String,
      remoteId: map['remote_id'] as int?,
    );
  }

  @override
  Map<String, Object?> toMap() => {
    'id': id,
    'nombre': nombre,
    'descripcion': descripcion,
    'is_synced': isSynced ? 1 : 0,
    'sync_action': syncAction,
    'remote_id': remoteId,
  };
}

// -----------------------------------------------------------------------------
// 6. EstadoVenta SQLite
// -----------------------------------------------------------------------------
class SqliteEstadoVenta extends SqliteEntity {
  final String nombre;
  final String? descripcion;

  const SqliteEstadoVenta({
    required super.id,
    required this.nombre,
    this.descripcion,
    super.isSynced = true,
    super.syncAction = 'none',
    super.remoteId,
  });

  factory SqliteEstadoVenta.fromDomain(
    EstadoVenta e, {
    bool isSynced = true,
    String syncAction = 'none',
    int? remoteId,
  }) {
    return SqliteEstadoVenta(
      id: e.id,
      nombre: e.nombre,
      descripcion: e.descripcion,
      isSynced: isSynced,
      syncAction: syncAction,
      remoteId: remoteId,
    );
  }

  EstadoVenta toDomain() {
    return EstadoVenta(
      id: remoteId ?? id,
      nombre: nombre,
      descripcion: descripcion,
    );
  }

  factory SqliteEstadoVenta.fromMap(Map<String, Object?> map) {
    return SqliteEstadoVenta(
      id: map['id'] as int,
      nombre: (map['nombre'] ?? '') as String,
      descripcion: map['descripcion'] as String?,
      isSynced: (map['is_synced'] as int? ?? 1) == 1,
      syncAction: (map['sync_action'] ?? 'none') as String,
      remoteId: map['remote_id'] as int?,
    );
  }

  @override
  Map<String, Object?> toMap() => {
    'id': id,
    'nombre': nombre,
    'descripcion': descripcion,
    'is_synced': isSynced ? 1 : 0,
    'sync_action': syncAction,
    'remote_id': remoteId,
  };
}

// -----------------------------------------------------------------------------
// 7. MetodoPago SQLite
// -----------------------------------------------------------------------------
class SqliteMetodoPago extends SqliteEntity {
  final String nombre;
  final String? descripcion;
  final bool activo;

  const SqliteMetodoPago({
    required super.id,
    required this.nombre,
    this.descripcion,
    required this.activo,
    super.isSynced = true,
    super.syncAction = 'none',
    super.remoteId,
  });

  factory SqliteMetodoPago.fromDomain(
    MetodoPago m, {
    bool isSynced = true,
    String syncAction = 'none',
    int? remoteId,
  }) {
    return SqliteMetodoPago(
      id: m.id,
      nombre: m.nombre,
      descripcion: m.descripcion,
      activo: m.activo,
      isSynced: isSynced,
      syncAction: syncAction,
      remoteId: remoteId,
    );
  }

  MetodoPago toDomain() {
    return MetodoPago(
      id: remoteId ?? id,
      nombre: nombre,
      descripcion: descripcion,
      activo: activo,
    );
  }

  factory SqliteMetodoPago.fromMap(Map<String, Object?> map) {
    return SqliteMetodoPago(
      id: map['id'] as int,
      nombre: (map['nombre'] ?? '') as String,
      descripcion: map['descripcion'] as String?,
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
    'descripcion': descripcion,
    'activo': activo ? 1 : 0,
    'is_synced': isSynced ? 1 : 0,
    'sync_action': syncAction,
    'remote_id': remoteId,
  };
}

// -----------------------------------------------------------------------------
// 8. TipoMovimiento SQLite
// -----------------------------------------------------------------------------
class SqliteTipoMovimiento extends SqliteEntity {
  final String nombre;
  final String? descripcion;
  final int signo;
  final bool activo;

  const SqliteTipoMovimiento({
    required super.id,
    required this.nombre,
    this.descripcion,
    required this.signo,
    required this.activo,
    super.isSynced = true,
    super.syncAction = 'none',
    super.remoteId,
  });

  factory SqliteTipoMovimiento.fromDomain(
    TipoMovimiento t, {
    bool isSynced = true,
    String syncAction = 'none',
    int? remoteId,
  }) {
    return SqliteTipoMovimiento(
      id: t.id,
      nombre: t.nombre,
      descripcion: t.descripcion,
      signo: t.signo,
      activo: t.activo,
      isSynced: isSynced,
      syncAction: syncAction,
      remoteId: remoteId,
    );
  }

  TipoMovimiento toDomain() {
    return TipoMovimiento(
      id: remoteId ?? id,
      nombre: nombre,
      descripcion: descripcion,
      signo: signo,
      activo: activo,
    );
  }

  factory SqliteTipoMovimiento.fromMap(Map<String, Object?> map) {
    return SqliteTipoMovimiento(
      id: map['id'] as int,
      nombre: (map['nombre'] ?? '') as String,
      descripcion: map['descripcion'] as String?,
      signo: map['signo'] as int? ?? 1,
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
    'descripcion': descripcion,
    'signo': signo,
    'activo': activo ? 1 : 0,
    'is_synced': isSynced ? 1 : 0,
    'sync_action': syncAction,
    'remote_id': remoteId,
  };
}

// -----------------------------------------------------------------------------
// 9. UnidadMedida SQLite
// -----------------------------------------------------------------------------
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

// -----------------------------------------------------------------------------
// 10. Venta SQLite
// -----------------------------------------------------------------------------
class SqliteVenta extends SqliteEntity {
  final int clienteId;
  final int estadoVentaId;
  final String? fecha;
  final double total;

  const SqliteVenta({
    required super.id,
    required this.clienteId,
    required this.estadoVentaId,
    this.fecha,
    required this.total,
    super.isSynced = true,
    super.syncAction = 'none',
    super.remoteId,
  });

  factory SqliteVenta.fromDomain(
    Venta v, {
    bool isSynced = true,
    String syncAction = 'none',
    int? remoteId,
  }) {
    return SqliteVenta(
      id: v.id,
      clienteId: v.clienteId,
      estadoVentaId: v.estadoVentaId,
      fecha: v.fecha,
      total: v.total,
      isSynced: isSynced,
      syncAction: syncAction,
      remoteId: remoteId,
    );
  }

  Venta toDomain() {
    return Venta(
      id: remoteId ?? id,
      clienteId: clienteId,
      estadoVentaId: estadoVentaId,
      fecha: fecha,
      total: total,
    );
  }

  factory SqliteVenta.fromMap(Map<String, Object?> map) {
    return SqliteVenta(
      id: map['id'] as int,
      clienteId: map['cliente_id'] as int? ?? 1,
      estadoVentaId: map['estado_venta_id'] as int? ?? 1,
      fecha: map['fecha'] as String?,
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      isSynced: (map['is_synced'] as int? ?? 1) == 1,
      syncAction: (map['sync_action'] ?? 'none') as String,
      remoteId: map['remote_id'] as int?,
    );
  }

  @override
  Map<String, Object?> toMap() => {
    'id': id,
    'cliente_id': clienteId,
    'estado_venta_id': estadoVentaId,
    'fecha': fecha,
    'total': total,
    'is_synced': isSynced ? 1 : 0,
    'sync_action': syncAction,
    'remote_id': remoteId,
  };
}

// -----------------------------------------------------------------------------
// 11. DetalleVenta SQLite
// -----------------------------------------------------------------------------
class SqliteDetalleVenta extends SqliteEntity {
  final int ventaId;
  final int productoId;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;

  const SqliteDetalleVenta({
    required super.id,
    required this.ventaId,
    required this.productoId,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
    super.isSynced = true,
    super.syncAction = 'none',
    super.remoteId,
  });

  factory SqliteDetalleVenta.fromDomain(
    DetalleVenta d, {
    bool isSynced = true,
    String syncAction = 'none',
    int? remoteId,
  }) {
    return SqliteDetalleVenta(
      id: d.id,
      ventaId: d.ventaId,
      productoId: d.productoId,
      cantidad: d.cantidad,
      precioUnitario: d.precioUnitario,
      subtotal: d.subtotal,
      isSynced: isSynced,
      syncAction: syncAction,
      remoteId: remoteId,
    );
  }

  DetalleVenta toDomain() {
    return DetalleVenta(
      id: remoteId ?? id,
      ventaId: ventaId,
      productoId: productoId,
      cantidad: cantidad,
      precioUnitario: precioUnitario,
      subtotal: subtotal,
    );
  }

  factory SqliteDetalleVenta.fromMap(Map<String, Object?> map) {
    return SqliteDetalleVenta(
      id: map['id'] as int,
      ventaId: map['venta_id'] as int? ?? 0,
      productoId: map['producto_id'] as int? ?? 0,
      cantidad: map['cantidad'] as int? ?? 1,
      precioUnitario: (map['precio_unitario'] as num?)?.toDouble() ?? 0.0,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      isSynced: (map['is_synced'] as int? ?? 1) == 1,
      syncAction: (map['sync_action'] ?? 'none') as String,
      remoteId: map['remote_id'] as int?,
    );
  }

  @override
  Map<String, Object?> toMap() => {
    'id': id,
    'venta_id': ventaId,
    'producto_id': productoId,
    'cantidad': cantidad,
    'precio_unitario': precioUnitario,
    'subtotal': subtotal,
    'is_synced': isSynced ? 1 : 0,
    'sync_action': syncAction,
    'remote_id': remoteId,
  };
}

// -----------------------------------------------------------------------------
// 12. Compra SQLite
// -----------------------------------------------------------------------------
class SqliteCompra extends SqliteEntity {
  final int proveedorId;
  final int estadoCompraId;
  final String? fecha;
  final double total;

  const SqliteCompra({
    required super.id,
    required this.proveedorId,
    required this.estadoCompraId,
    this.fecha,
    required this.total,
    super.isSynced = true,
    super.syncAction = 'none',
    super.remoteId,
  });

  factory SqliteCompra.fromDomain(
    Compra c, {
    bool isSynced = true,
    String syncAction = 'none',
    int? remoteId,
  }) {
    return SqliteCompra(
      id: c.id,
      proveedorId: c.proveedorId,
      estadoCompraId: c.estadoCompraId,
      fecha: c.fecha,
      total: c.total,
      isSynced: isSynced,
      syncAction: syncAction,
      remoteId: remoteId,
    );
  }

  Compra toDomain() {
    return Compra(
      id: remoteId ?? id,
      proveedorId: proveedorId,
      estadoCompraId: estadoCompraId,
      fecha: fecha,
      total: total,
    );
  }

  factory SqliteCompra.fromMap(Map<String, Object?> map) {
    return SqliteCompra(
      id: map['id'] as int,
      proveedorId: map['proveedor_id'] as int? ?? 1,
      estadoCompraId: map['estado_compra_id'] as int? ?? 1,
      fecha: map['fecha'] as String?,
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      isSynced: (map['is_synced'] as int? ?? 1) == 1,
      syncAction: (map['sync_action'] ?? 'none') as String,
      remoteId: map['remote_id'] as int?,
    );
  }

  @override
  Map<String, Object?> toMap() => {
    'id': id,
    'proveedor_id': proveedorId,
    'estado_compra_id': estadoCompraId,
    'fecha': fecha,
    'total': total,
    'is_synced': isSynced ? 1 : 0,
    'sync_action': syncAction,
    'remote_id': remoteId,
  };
}

// -----------------------------------------------------------------------------
// 13. DetalleCompra SQLite
// -----------------------------------------------------------------------------
class SqliteDetalleCompra extends SqliteEntity {
  final int compraId;
  final int productoId;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;

  const SqliteDetalleCompra({
    required super.id,
    required this.compraId,
    required this.productoId,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
    super.isSynced = true,
    super.syncAction = 'none',
    super.remoteId,
  });

  factory SqliteDetalleCompra.fromDomain(
    DetalleCompra d, {
    bool isSynced = true,
    String syncAction = 'none',
    int? remoteId,
  }) {
    return SqliteDetalleCompra(
      id: d.id,
      compraId: d.compraId,
      productoId: d.productoId,
      cantidad: d.cantidad,
      precioUnitario: d.precioUnitario,
      subtotal: d.subtotal,
      isSynced: isSynced,
      syncAction: syncAction,
      remoteId: remoteId,
    );
  }

  DetalleCompra toDomain() {
    return DetalleCompra(
      id: remoteId ?? id,
      compraId: compraId,
      productoId: productoId,
      cantidad: cantidad,
      precioUnitario: precioUnitario,
      subtotal: subtotal,
    );
  }

  factory SqliteDetalleCompra.fromMap(Map<String, Object?> map) {
    return SqliteDetalleCompra(
      id: map['id'] as int,
      compraId: map['compra_id'] as int? ?? 0,
      productoId: map['producto_id'] as int? ?? 0,
      cantidad: map['cantidad'] as int? ?? 1,
      precioUnitario: (map['precio_unitario'] as num?)?.toDouble() ?? 0.0,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      isSynced: (map['is_synced'] as int? ?? 1) == 1,
      syncAction: (map['sync_action'] ?? 'none') as String,
      remoteId: map['remote_id'] as int?,
    );
  }

  @override
  Map<String, Object?> toMap() => {
    'id': id,
    'compra_id': compraId,
    'producto_id': productoId,
    'cantidad': cantidad,
    'precio_unitario': precioUnitario,
    'subtotal': subtotal,
    'is_synced': isSynced ? 1 : 0,
    'sync_action': syncAction,
    'remote_id': remoteId,
  };
}

// -----------------------------------------------------------------------------
// 14. MovimientoInventario SQLite
// -----------------------------------------------------------------------------
class SqliteMovimientoInventario extends SqliteEntity {
  final int productoId;
  final int tipoMovimientoId;
  final double cantidad;
  final String? fecha;
  final String? referencia;

  const SqliteMovimientoInventario({
    required super.id,
    required this.productoId,
    required this.tipoMovimientoId,
    required this.cantidad,
    this.fecha,
    this.referencia,
    super.isSynced = true,
    super.syncAction = 'none',
    super.remoteId,
  });

  factory SqliteMovimientoInventario.fromDomain(
    MovimientoInventario m, {
    bool isSynced = true,
    String syncAction = 'none',
    int? remoteId,
  }) {
    return SqliteMovimientoInventario(
      id: m.id,
      productoId: m.productoId,
      tipoMovimientoId: m.tipoMovimientoId,
      cantidad: m.cantidad,
      fecha: m.fecha,
      referencia: m.referencia,
      isSynced: isSynced,
      syncAction: syncAction,
      remoteId: remoteId,
    );
  }

  MovimientoInventario toDomain() {
    return MovimientoInventario(
      id: remoteId ?? id,
      productoId: productoId,
      tipoMovimientoId: tipoMovimientoId,
      cantidad: cantidad,
      fecha: fecha,
      referencia: referencia,
    );
  }

  factory SqliteMovimientoInventario.fromMap(Map<String, Object?> map) {
    return SqliteMovimientoInventario(
      id: map['id'] as int,
      productoId: map['producto_id'] as int? ?? 1,
      tipoMovimientoId: map['tipo_movimiento_id'] as int? ?? 1,
      cantidad: (map['cantidad'] as num?)?.toDouble() ?? 0.0,
      fecha: map['fecha'] as String?,
      referencia: map['referencia'] as String?,
      isSynced: (map['is_synced'] as int? ?? 1) == 1,
      syncAction: (map['sync_action'] ?? 'none') as String,
      remoteId: map['remote_id'] as int?,
    );
  }

  @override
  Map<String, Object?> toMap() => {
    'id': id,
    'producto_id': productoId,
    'tipo_movimiento_id': tipoMovimientoId,
    'cantidad': cantidad,
    'fecha': fecha,
    'referencia': referencia,
    'is_synced': isSynced ? 1 : 0,
    'sync_action': syncAction,
    'remote_id': remoteId,
  };
}

// -----------------------------------------------------------------------------
// 15. Pago SQLite
// -----------------------------------------------------------------------------
class SqlitePago extends SqliteEntity {
  final int ventaId;
  final int metodoPagoId;
  final double monto;
  final String? fecha;
  final String? referencia;

  const SqlitePago({
    required super.id,
    required this.ventaId,
    required this.metodoPagoId,
    required this.monto,
    this.fecha,
    this.referencia,
    super.isSynced = true,
    super.syncAction = 'none',
    super.remoteId,
  });

  factory SqlitePago.fromDomain(
    Pago p, {
    bool isSynced = true,
    String syncAction = 'none',
    int? remoteId,
  }) {
    return SqlitePago(
      id: p.id,
      ventaId: p.ventaId,
      metodoPagoId: p.metodoPagoId,
      monto: p.monto,
      fecha: p.fecha,
      referencia: p.referencia,
      isSynced: isSynced,
      syncAction: syncAction,
      remoteId: remoteId,
    );
  }

  Pago toDomain() {
    return Pago(
      id: remoteId ?? id,
      ventaId: ventaId,
      metodoPagoId: metodoPagoId,
      monto: monto,
      fecha: fecha,
      referencia: referencia,
    );
  }

  factory SqlitePago.fromMap(Map<String, Object?> map) {
    return SqlitePago(
      id: map['id'] as int,
      ventaId: map['venta_id'] as int? ?? 0,
      metodoPagoId: map['metodo_pago_id'] as int? ?? 1,
      monto: (map['monto'] as num?)?.toDouble() ?? 0.0,
      fecha: map['fecha'] as String?,
      referencia: map['referencia'] as String?,
      isSynced: (map['is_synced'] as int? ?? 1) == 1,
      syncAction: (map['sync_action'] ?? 'none') as String,
      remoteId: map['remote_id'] as int?,
    );
  }

  @override
  Map<String, Object?> toMap() => {
    'id': id,
    'venta_id': ventaId,
    'metodo_pago_id': metodoPagoId,
    'monto': monto,
    'fecha': fecha,
    'referencia': referencia,
    'is_synced': isSynced ? 1 : 0,
    'sync_action': syncAction,
    'remote_id': remoteId,
  };
}

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
