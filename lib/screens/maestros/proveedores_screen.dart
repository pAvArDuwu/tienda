import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/proveedor.dart';
import '../../providers/proveedor_provider.dart';
import '../../widgets/entity_list_tile.dart';

class ProveedoresScreen extends StatefulWidget {
  const ProveedoresScreen({super.key});
  @override State<ProveedoresScreen> createState() => _ProveedoresScreenState();
}

class _ProveedoresScreenState extends State<ProveedoresScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<ProveedorProvider>().cargar());
  }

  void _dialogo({Proveedor? item}) {
    final nCtrl = TextEditingController(text: item?.nombre ?? '');
    final cCtrl = TextEditingController(text: item?.contacto ?? '');
    final tCtrl = TextEditingController(text: item?.telefono ?? '');
    final eCtrl = TextEditingController(text: item?.email ?? '');
    final dCtrl = TextEditingController(text: item?.direccion ?? '');
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(item == null ? 'Nuevo Proveedor' : 'Editar Proveedor'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nCtrl, decoration: const InputDecoration(labelText: 'Nombre *', border: OutlineInputBorder())),
        const SizedBox(height: 10),
        TextField(controller: cCtrl, decoration: const InputDecoration(labelText: 'Contacto', border: OutlineInputBorder())),
        const SizedBox(height: 10),
        TextField(controller: tCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Teléfono', border: OutlineInputBorder())),
        const SizedBox(height: 10),
        TextField(controller: eCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
        const SizedBox(height: 10),
        TextField(controller: dCtrl, decoration: const InputDecoration(labelText: 'Dirección', border: OutlineInputBorder())),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        FilledButton(onPressed: () async {
          if (nCtrl.text.trim().isEmpty) return;
          final prov = context.read<ProveedorProvider>();
          final pr = Proveedor(id: item?.id ?? 0, nombre: nCtrl.text.trim(), contacto: cCtrl.text.trim().isEmpty ? null : cCtrl.text.trim(), telefono: tCtrl.text.trim().isEmpty ? null : tCtrl.text.trim(), email: eCtrl.text.trim().isEmpty ? null : eCtrl.text.trim(), direccion: dCtrl.text.trim().isEmpty ? null : dCtrl.text.trim());
          try {
            if (item == null) await prov.crear(pr); else await prov.actualizar(pr);
            if (ctx.mounted) Navigator.pop(ctx);
          } catch (e) { if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)); }
        }, child: Text(item == null ? 'Crear' : 'Guardar')),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Proveedores'), centerTitle: true),
    floatingActionButton: FloatingActionButton.extended(onPressed: () => _dialogo(), icon: const Icon(Icons.add_business), label: const Text('Nuevo')),
    body: Consumer<ProveedorProvider>(builder: (_, prov, __) {
      if (prov.loading) return const Center(child: CircularProgressIndicator());
      if (prov.error != null) return ErrorBanner(message: prov.error!, onRetry: prov.cargar);
      if (prov.items.isEmpty) return const Center(child: Text('Sin proveedores.'));
      return RefreshIndicator(onRefresh: prov.cargar, child: ListView.builder(itemCount: prov.items.length, itemBuilder: (_, i) {
        final pr = prov.items[i];
        return EntityListTile(title: pr.nombre, subtitle: pr.contacto ?? pr.email,
          onEdit: () => _dialogo(item: pr),
          onDelete: () async {
            final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Eliminar'), content: Text('¿Eliminar "${pr.nombre}"?'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sí'))]));
            if (ok == true && context.mounted) { try { await context.read<ProveedorProvider>().eliminar(pr.id); } catch (e) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)); } }
          });
      }));
    }),
  );
}
