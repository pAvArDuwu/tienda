import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/unidad_medida.dart';
import '../../providers/unidad_medida_provider.dart';
import '../../widgets/entity_list_tile.dart';

class UnidadesMedidaScreen extends StatefulWidget {
  const UnidadesMedidaScreen({super.key});
  @override State<UnidadesMedidaScreen> createState() => _UnidadesMedidaScreenState();
}

class _UnidadesMedidaScreenState extends State<UnidadesMedidaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<UnidadMedidaProvider>().cargar());
  }

  void _dialogo({UnidadMedida? item}) {
    final nCtrl = TextEditingController(text: item?.nombre ?? '');
    final aCtrl = TextEditingController(text: item?.abreviatura ?? '');
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(item == null ? 'Nueva Unidad de Medida' : 'Editar Unidad de Medida'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nCtrl, decoration: const InputDecoration(labelText: 'Nombre *', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: aCtrl, decoration: const InputDecoration(labelText: 'Abreviatura', border: OutlineInputBorder())),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        FilledButton(onPressed: () async {
          if (nCtrl.text.trim().isEmpty) return;
          final prov = context.read<UnidadMedidaProvider>();
          final um = UnidadMedida(id: item?.id ?? 0, nombre: nCtrl.text.trim(), abreviatura: aCtrl.text.trim().isEmpty ? null : aCtrl.text.trim());
          try {
            if (item == null) await prov.crear(um); else await prov.actualizar(um);
            if (ctx.mounted) Navigator.pop(ctx);
          } catch (e) { if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)); }
        }, child: Text(item == null ? 'Crear' : 'Guardar')),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Unidades de Medida'), centerTitle: true),
    floatingActionButton: FloatingActionButton.extended(onPressed: () => _dialogo(), icon: const Icon(Icons.add), label: const Text('Nuevo')),
    body: Consumer<UnidadMedidaProvider>(builder: (_, prov, __) {
      if (prov.loading) return const Center(child: CircularProgressIndicator());
      if (prov.error != null) return ErrorBanner(message: prov.error!, onRetry: prov.cargar);
      if (prov.items.isEmpty) return const Center(child: Text('Sin registros.'));
      return RefreshIndicator(onRefresh: prov.cargar, child: ListView.builder(itemCount: prov.items.length, itemBuilder: (_, i) {
        final um = prov.items[i];
        return EntityListTile(title: um.nombre, subtitle: um.abreviatura, onEdit: () => _dialogo(item: um),
          onDelete: () async {
            final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Eliminar'), content: Text('¿Eliminar "${um.nombre}"?'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sí'))]));
            if (ok == true && context.mounted) { try { await context.read<UnidadMedidaProvider>().eliminar(um.id); } catch (e) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)); } }
          });
      }));
    }),
  );
}
