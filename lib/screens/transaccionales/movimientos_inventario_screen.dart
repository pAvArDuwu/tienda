import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/movimiento_inventario.dart';
import '../../providers/movimiento_inventario_provider.dart';
import '../../providers/producto_provider.dart';
import '../../providers/tipo_movimiento_provider.dart';

class MovimientosInventarioScreen extends StatefulWidget {
  const MovimientosInventarioScreen({super.key});
  @override State<MovimientosInventarioScreen> createState() => _MovimientosInventarioScreenState();
}

class _MovimientosInventarioScreenState extends State<MovimientosInventarioScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovimientoInventarioProvider>().cargar();
      context.read<ProductoProvider>().cargar();
      context.read<TipoMovimientoProvider>().cargar();
    });
  }

  void _dialogo() {
    final productos = context.read<ProductoProvider>().items;
    final tipos = context.read<TipoMovimientoProvider>().items;
    if (productos.isEmpty || tipos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Carga productos y tipos de movimiento primero')));
      return;
    }
    int? prodId = productos.first.id;
    int? tipoId = tipos.first.id;
    final cantCtrl = TextEditingController(text: '1');
    final refCtrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => AlertDialog(
      title: const Text('Nuevo Movimiento'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButtonFormField<int>(value: prodId, decoration: const InputDecoration(labelText: 'Producto *', border: OutlineInputBorder()), items: productos.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nombre))).toList(), onChanged: (v) => setS(() => prodId = v)),
        const SizedBox(height: 10),
        DropdownButtonFormField<int>(value: tipoId, decoration: const InputDecoration(labelText: 'Tipo Movimiento *', border: OutlineInputBorder()), items: tipos.map((t) => DropdownMenuItem(value: t.id, child: Text(t.nombre))).toList(), onChanged: (v) => setS(() => tipoId = v)),
        const SizedBox(height: 10),
        TextField(controller: cantCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cantidad *', border: OutlineInputBorder())),
        const SizedBox(height: 10),
        TextField(controller: refCtrl, decoration: const InputDecoration(labelText: 'Referencia', border: OutlineInputBorder())),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        FilledButton(onPressed: () async {
          if (prodId == null || tipoId == null) return;
          final cant = int.tryParse(cantCtrl.text.trim()) ?? 0;
          final mi = MovimientoInventario(id: 0, productoId: prodId!, tipoMovimientoId: tipoId!, cantidad: cant, referencia: refCtrl.text.trim().isEmpty ? null : refCtrl.text.trim());
          try {
            await context.read<MovimientoInventarioProvider>().crear(mi);
            if (ctx.mounted) Navigator.pop(ctx);
          } catch (e) { if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)); }
        }, child: const Text('Registrar')),
      ],
    )));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Movimientos Inventario'), centerTitle: true),
    floatingActionButton: FloatingActionButton.extended(onPressed: _dialogo, icon: const Icon(Icons.swap_vert), label: const Text('Registrar')),
    body: Consumer<MovimientoInventarioProvider>(builder: (_, prov, __) {
      if (prov.loading) return const Center(child: CircularProgressIndicator());
      if (prov.error != null) return Center(child: Text(prov.error!));
      if (prov.items.isEmpty) return const Center(child: Text('Sin movimientos.'));
      return RefreshIndicator(onRefresh: prov.cargar, child: ListView.builder(itemCount: prov.items.length, itemBuilder: (_, i) {
        final mi = prov.items[i];
        return Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: ListTile(
          leading: CircleAvatar(backgroundColor: Colors.blue.shade100, child: const Icon(Icons.swap_vert, color: Colors.blue)),
          title: Text('Producto #${mi.productoId} — Cant: ${mi.cantidad}'),
          subtitle: Text('Tipo: #${mi.tipoMovimientoId} • ${mi.fecha ?? 'Sin fecha'}${mi.referencia != null ? " • Ref: ${mi.referencia}" : ""}'),
        ));
      }));
    }),
  );
}
