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
