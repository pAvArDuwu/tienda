import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/compra.dart';
import '../../providers/compra_provider.dart';
import '../../providers/proveedor_provider.dart';
import '../../providers/estado_compra_provider.dart';

class ComprasScreen extends StatefulWidget {
  const ComprasScreen({super.key});
  @override State<ComprasScreen> createState() => _ComprasScreenState();
}

class _ComprasScreenState extends State<ComprasScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompraProvider>().cargar();
      context.read<ProveedorProvider>().cargar();
      context.read<EstadoCompraProvider>().cargar();
    });
  }

  void _dialogo({Compra? item}) {
    final proveedores = context.read<ProveedorProvider>().items;
    final estadosCompra = context.read<EstadoCompraProvider>().items;
    if (proveedores.isEmpty || estadosCompra.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Carga proveedores y estados de compra primero')));
      return;
    }
    int? provId = item?.proveedorId ?? proveedores.first.id;
    int? ecId = item?.estadoCompraId ?? estadosCompra.first.id;
    final tCtrl = TextEditingController(text: item?.total.toString() ?? '');
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => AlertDialog(
      title: Text(item == null ? 'Nueva Compra' : 'Editar Compra'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButtonFormField<int>(value: provId, decoration: const InputDecoration(labelText: 'Proveedor *', border: OutlineInputBorder()), items: proveedores.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nombre))).toList(), onChanged: (v) => setS(() => provId = v)),
        const SizedBox(height: 10),
        DropdownButtonFormField<int>(value: ecId, decoration: const InputDecoration(labelText: 'Estado Compra *', border: OutlineInputBorder()), items: estadosCompra.map((e) => DropdownMenuItem(value: e.id, child: Text(e.nombre))).toList(), onChanged: (v) => setS(() => ecId = v)),
        const SizedBox(height: 10),
        TextField(controller: tCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Total *', prefixText: 'Bs. ', border: OutlineInputBorder())),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        FilledButton(onPressed: () async {
          if (provId == null || ecId == null) return;
          final total = double.tryParse(tCtrl.text.trim()) ?? 0;
          final prov = context.read<CompraProvider>();
          final comp = Compra(id: item?.id ?? 0, proveedorId: provId!, estadoCompraId: ecId!, total: total);
          try {
            if (item == null) await prov.crear(comp); else await prov.actualizar(comp);
            if (ctx.mounted) Navigator.pop(ctx);
          } catch (e) { if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)); }
        }, child: Text(item == null ? 'Crear' : 'Guardar')),
      ],
    )));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Compras'), centerTitle: true),
    floatingActionButton: FloatingActionButton.extended(onPressed: () => _dialogo(), icon: const Icon(Icons.shopping_cart), label: const Text('Nueva')),
    body: Consumer<CompraProvider>(builder: (_, prov, __) {
      if (prov.loading) return const Center(child: CircularProgressIndicator());
      if (prov.error != null) return Center(child: Text(prov.error!));
      if (prov.items.isEmpty) return const Center(child: Text('Sin compras registradas.'));
      return RefreshIndicator(onRefresh: prov.cargar, child: ListView.builder(itemCount: prov.items.length, itemBuilder: (_, i) {
        final c = prov.items[i];
        return Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: ListTile(
          leading: CircleAvatar(child: Text('#${c.id}')),
          title: Text('Compra #${c.id} — Proveedor #${c.proveedorId}'),
          subtitle: Text('Bs. ${c.total.toStringAsFixed(2)} • ${c.fecha ?? 'Sin fecha'}'),
          trailing: IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _dialogo(item: c)),
        ));
      }));
    }),
  );
}
