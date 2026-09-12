import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/producto.dart';
import '../../providers/producto_provider.dart';
import '../../widgets/entity_list_tile.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});
  @override State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<ProductoProvider>().cargar());
  }

  void _dialogo({Producto? item}) {
    final nCtrl = TextEditingController(text: item?.nombre ?? '');
    final pCtrl = TextEditingController(text: item?.precio.toString() ?? '');
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(item == null ? 'Nuevo Producto' : 'Editar Producto'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nCtrl, decoration: const InputDecoration(labelText: 'Nombre *', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: pCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Precio *', prefixText: 'Bs. ', border: OutlineInputBorder())),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        FilledButton(onPressed: () async {
          if (nCtrl.text.trim().isEmpty) return;
          final precio = double.tryParse(pCtrl.text.trim()) ?? 0;
          final prov = context.read<ProductoProvider>();
          final prod = Producto(id: item?.id ?? 0, nombre: nCtrl.text.trim(), precio: precio);
          try {
            if (item == null) await prov.crear(prod); else await prov.actualizar(prod);
            if (ctx.mounted) Navigator.pop(ctx);
          } catch (e) { if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)); }
        }, child: Text(item == null ? 'Crear' : 'Guardar')),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Productos'), centerTitle: true),
    floatingActionButton: FloatingActionButton.extended(onPressed: () => _dialogo(), icon: const Icon(Icons.add), label: const Text('Nuevo')),
    body: Consumer<ProductoProvider>(builder: (_, prov, __) {
      if (prov.loading) return const Center(child: CircularProgressIndicator());
      if (prov.error != null) return ErrorBanner(message: prov.error!, onRetry: prov.cargar);
      if (prov.items.isEmpty) return const Center(child: Text('Sin productos.'));
      return RefreshIndicator(onRefresh: prov.cargar, child: ListView.builder(itemCount: prov.items.length, itemBuilder: (_, i) {
        final p = prov.items[i];
        return EntityListTile(title: p.nombre, subtitle: 'Bs. ${p.precio.toStringAsFixed(2)}',
          leading: CircleAvatar(backgroundColor: Theme.of(context).colorScheme.secondaryContainer, child: const Icon(Icons.inventory_2_outlined)),
          onEdit: () => _dialogo(item: p),
          onDelete: () async {
            final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Eliminar'), content: Text('¿Eliminar "${p.nombre}"?'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sí'))]));
            if (ok == true && context.mounted) { try { await context.read<ProductoProvider>().eliminar(p.id); } catch (e) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)); } }
          });
      }));
    }),
  );
}
