import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/api_client.dart';

// Providers
import 'providers/categoria_provider.dart';
import 'providers/cliente_provider.dart';
import 'providers/proveedor_provider.dart';
import 'providers/producto_provider.dart';
import 'providers/estado_compra_provider.dart';
import 'providers/estado_venta_provider.dart';
import 'providers/metodo_pago_provider.dart';
import 'providers/tipo_movimiento_provider.dart';
import 'providers/unidad_medida_provider.dart';
import 'providers/venta_provider.dart';
import 'providers/compra_provider.dart';
import 'providers/movimiento_inventario_provider.dart';
import 'providers/pago_provider.dart';

// Screens - Parametros
import 'screens/parametros/categorias_screen.dart';
import 'screens/parametros/estados_compra_screen.dart';
import 'screens/parametros/estados_venta_screen.dart';
import 'screens/parametros/metodos_pago_screen.dart';
import 'screens/parametros/tipos_movimiento_screen.dart';
import 'screens/parametros/unidades_medida_screen.dart';

// Screens - Maestros
import 'screens/maestros/productos_screen.dart';
import 'screens/maestros/clientes_screen.dart';
import 'screens/maestros/proveedores_screen.dart';

// Screens - Transaccionales
import 'screens/transaccionales/ventas_screen.dart';
import 'screens/transaccionales/compras_screen.dart';
import 'screens/transaccionales/movimientos_inventario_screen.dart';
import 'screens/transaccionales/pagos_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CategoriaProvider()),
        ChangeNotifierProvider(create: (_) => ClienteProvider()),
        ChangeNotifierProvider(create: (_) => ProveedorProvider()),
        ChangeNotifierProvider(create: (_) => ProductoProvider()),
        ChangeNotifierProvider(create: (_) => EstadoCompraProvider()),
        ChangeNotifierProvider(create: (_) => EstadoVentaProvider()),
        ChangeNotifierProvider(create: (_) => MetodoPagoProvider()),
        ChangeNotifierProvider(create: (_) => TipoMovimientoProvider()),
        ChangeNotifierProvider(create: (_) => UnidadMedidaProvider()),
        ChangeNotifierProvider(create: (_) => VentaProvider()),
        ChangeNotifierProvider(create: (_) => CompraProvider()),
        ChangeNotifierProvider(create: (_) => MovimientoInventarioProvider()),
        ChangeNotifierProvider(create: (_) => PagoProvider()),
      ],
      child: const TiendaApp(),
    ),
  );
}

class TiendaApp extends StatelessWidget {
  const TiendaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tienda API',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _sectionIndex = 0;
  int _parametroIndex = 0;
  int _maestroIndex = 0;
  int _transaccionalIndex = 0;

  // Sub-indices por seccion
  final List<String> _paramTitles = [
    'Categorías',
    'Estados Compra',
    'Estados Venta',
    'Métodos Pago',
    'Tipos Movimiento',
    'Unidades Medida',
  ];
  final List<Widget> _paramScreens = [
    const CategoriasScreen(),
    const EstadosCompraScreen(),
    const EstadosVentaScreen(),
    const MetodosPagoScreen(),
    const TiposMovimientoScreen(),
    const UnidadesMedidaScreen(),
  ];
  final List<IconData> _paramIcons = [
    Icons.category_outlined,
    Icons.local_shipping_outlined,
    Icons.point_of_sale_outlined,
    Icons.credit_card_outlined,
    Icons.swap_vert,
    Icons.straighten,
  ];

  final List<String> _maestroTitles = ['Productos', 'Clientes', 'Proveedores'];
  final List<Widget> _maestroScreens = [
    const ProductosScreen(),
    const ClientesScreen(),
    const ProveedoresScreen(),
  ];
  final List<IconData> _maestroIcons = [
    Icons.inventory_2_outlined,
    Icons.people_outline,
    Icons.business_outlined,
  ];

  final List<String> _transTitles = [
    'Ventas',
    'Compras',
    'Movimientos',
    'Pagos',
  ];
  final List<Widget> _transScreens = [
    const VentasScreen(),
    const ComprasScreen(),
    const MovimientosInventarioScreen(),
    const PagosScreen(),
  ];
  final List<IconData> _transIcons = [
    Icons.receipt_long_outlined,
    Icons.shopping_cart_outlined,
    Icons.swap_horiz_outlined,
    Icons.payment_outlined,
  ];

  Widget _buildSubNav({
    required List<String> titles,
    required List<IconData> icons,
    required int selected,
    required void Function(int) onTap,
  }) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: titles.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) => FilterChip(
          selected: selected == i,
          avatar: Icon(icons[i], size: 16),
          label: Text(titles[i], style: const TextStyle(fontSize: 12)),
          onSelected: (_) => onTap(i),
        ),
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return ValueListenableBuilder<OfflineSyncStatus>(
      valueListenable: ApiClient.syncStatus,
      builder: (context, status, _) {
        if (!status.hasNotice) return const SizedBox.shrink();

        final colorScheme = Theme.of(context).colorScheme;
        final background = status.online
            ? colorScheme.tertiaryContainer
            : colorScheme.errorContainer;
        final foreground = status.online
            ? colorScheme.onTertiaryContainer
            : colorScheme.onErrorContainer;
        final icon = status.syncing
            ? Icons.sync
            : status.online
            ? Icons.cloud_queue
            : Icons.cloud_off_outlined;

        return Container(
          width: double.infinity,
          color: background,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 18, color: foreground),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  status.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (status.pendingOperations > 0)
                TextButton.icon(
                  onPressed: ApiClient.syncPendingOperations,
                  icon: const Icon(Icons.upload_outlined, size: 16),
                  label: const Text('Subir'),
                  style: TextButton.styleFrom(
                    foregroundColor: foreground,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget body;
    Widget? subNav;

    switch (_sectionIndex) {
      case 0:
        body = _paramScreens[_parametroIndex];
        subNav = _buildSubNav(
          titles: _paramTitles,
          icons: _paramIcons,
          selected: _parametroIndex,
          onTap: (i) => setState(() => _parametroIndex = i),
        );
        break;
      case 1:
        body = _maestroScreens[_maestroIndex];
        subNav = _buildSubNav(
          titles: _maestroTitles,
          icons: _maestroIcons,
          selected: _maestroIndex,
          onTap: (i) => setState(() => _maestroIndex = i),
        );
        break;
      case 2:
      default:
        body = _transScreens[_transaccionalIndex];
        subNav = _buildSubNav(
          titles: _transTitles,
          icons: _transIcons,
          selected: _transaccionalIndex,
          onTap: (i) => setState(() => _transaccionalIndex = i),
        );
        break;
    }

    return Scaffold(
      body: Column(
        children: [
          Container(color: colorScheme.surfaceContainerLow, child: subNav),
          _buildOfflineBanner(),
          Expanded(child: body),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _sectionIndex,
        onDestinationSelected: (i) => setState(() => _sectionIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune),
            label: 'Parámetros',
          ),
          NavigationDestination(
            icon: Icon(Icons.store_outlined),
            selectedIcon: Icon(Icons.store),
            label: 'Maestros',
          ),
          NavigationDestination(
            icon: Icon(Icons.point_of_sale_outlined),
            selectedIcon: Icon(Icons.point_of_sale),
            label: 'Transaccional',
          ),
        ],
      ),
    );
  }
}
