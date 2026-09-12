import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/cliente.dart';
import '../../providers/cliente_provider.dart';
import '../../widgets/entity_list_tile.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});
  @override State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<ClienteProvider>().cargar());
  }

  void _dialogo({Cliente? item}) {
    final nCtrl = TextEditingController(text: item?.nombre ?? '');
    final apCtrl = TextEditingController(text: item?.apellido ?? '');
    final tlCtrl = TextEditingController(text: item?.telefono ?? '');
    final emCtrl = TextEditingController(text: item?.email ?? '');
    final dirCtrl = TextEditingController(text: item?.direccion ?? '');
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(item == null ? 'Nuevo Cliente' : 'Editar Cliente'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nCtrl, decoration: const InputDecoration(labelText: 'Nombre *', border: OutlineInputBorder())),
        const SizedBox(height: 10),
        TextField(controller: apCtrl, decoration: const InputDecoration(labelText: 'Apellido', border: OutlineInputBorder())),
        const SizedBox(height: 10),
        TextField(controller: tlCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Teléfono', border: OutlineInputBorder())),
        const SizedBox(height: 10),
        TextField(controller: emCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
        const SizedBox(height: 10),
        TextField(controller: dirCtrl, decoration: const InputDecoration(labelText: 'Dirección', border: OutlineInputBorder())),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        FilledButton(onPressed: () async {
          if (nCtrl.text.trim().isEmpty) return;
          final prov = context.read<ClienteProvider>();
          final cl = Cliente(id: item?.id ?? 0, nombre: nCtrl.text.trim(), apellido: apCtrl.text.trim().isEmpty ? null : apCtrl.text.trim(), telefono: tlCtrl.text.trim().isEmpty ? null : tlCtrl.text.trim(), email: emCtrl.text.trim().isEmpty ? null : emCtrl.text.trim(), direccion: dirCtrl.text.trim().isEmpty ? null : dirCtrl.text.trim());
          try {
            if (item == null) await prov.crear(cl); else await prov.actualizar(cl);
            if (ctx.mounted) Navigator.pop(ctx);
          } catch (e) { if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)); }
        }, child: Text(item == null ? 'Crear' : 'Guardar')),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Clientes'), centerTitle: true),
    floatingActionButton: FloatingActionButton.extended(onPressed: () => _dialogo(), icon: const Icon(Icons.person_add), label: const Text('Nuevo')),
    body: Consumer<ClienteProvider>(builder: (_, prov, __) {
      if (prov.loading) return const Center(child: CircularProgressIndicator());
      if (prov.error != null) return ErrorBanner(message: prov.error!, onRetry: prov.cargar);
      if (prov.items.isEmpty) return const Center(child: Text('Sin clientes.'));
      return RefreshIndicator(onRefresh: prov.cargar, child: ListView.builder(itemCount: prov.items.length, itemBuilder: (_, i) {
        final cl = prov.items[i];
        return EntityListTile(title: cl.nombreCompleto, subtitle: cl.email ?? cl.telefono,
          onEdit: () => _dialogo(item: cl),
          onDelete: () async {
            final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Eliminar'), content: Text('¿Eliminar a "${cl.nombreCompleto}"?'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sí'))]));
            if (ok == true && context.mounted) { try { await context.read<ClienteProvider>().eliminar(cl.id); } catch (e) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)); } }
          });
      }));
    }),
  );
}
