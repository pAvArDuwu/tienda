import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/estado_venta.dart';
import '../../providers/estado_venta_provider.dart';
import '../../widgets/entity_list_tile.dart';

class EstadosVentaScreen extends StatefulWidget {
  const EstadosVentaScreen({super.key});
  @override State<EstadosVentaScreen> createState() => _EstadosVentaScreenState();
}

class _EstadosVentaScreenState extends State<EstadosVentaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<EstadoVentaProvider>().cargar());
  }

  void _dialogo({EstadoVenta? item}) {
    final nCtrl = TextEditingController(text: item?.nombre ?? '');
    final dCtrl = TextEditingController(text: item?.descripcion ?? '');
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(item == null ? 'Nuevo Estado Venta' : 'Editar Estado Venta'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nCtrl, decoration: const InputDecoration(labelText: 'Nombre *', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: dCtrl, decoration: const InputDecoration(labelText: 'Descripción', border: OutlineInputBorder())),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        FilledButton(onPressed: () async {
          if (nCtrl.text.trim().isEmpty) return;
          final prov = context.read<EstadoVentaProvider>();
          final ev = EstadoVenta(id: item?.id ?? 0, nombre: nCtrl.text.trim(), descripcion: dCtrl.text.trim().isEmpty ? null : dCtrl.text.trim());
          try {
            if (item == null) await prov.crear(ev); else await prov.actualizar(ev);
            if (ctx.mounted) Navigator.pop(ctx);
          } catch (e) { if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)); }
        }, child: Text(item == null ? 'Crear' : 'Guardar')),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Estados de Venta'), centerTitle: true),
    floatingActionButton: FloatingActionButton.extended(onPressed: () => _dialogo(), icon: const Icon(Icons.add), label: const Text('Nuevo')),
    body: Consumer<EstadoVentaProvider>(builder: (_, prov, __) {
      if (prov.loading) return const Center(child: CircularProgressIndicator());
      if (prov.error != null) return ErrorBanner(message: prov.error!, onRetry: prov.cargar);
      if (prov.items.isEmpty) return const Center(child: Text('Sin registros.'));
      return RefreshIndicator(onRefresh: prov.cargar, child: ListView.builder(itemCount: prov.items.length, itemBuilder: (_, i) {
        final ev = prov.items[i];
        return EntityListTile(title: ev.nombre, subtitle: ev.descripcion, onEdit: () => _dialogo(item: ev),
          onDelete: () async {
            final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Eliminar'), content: Text('¿Eliminar "${ev.nombre}"?'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sí'))]));
            if (ok == true && context.mounted) { try { await context.read<EstadoVentaProvider>().eliminar(ev.id); } catch (e) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)); } }
          });
      }));
    }),
  );
}
