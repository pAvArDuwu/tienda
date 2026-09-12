import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/metodo_pago.dart';
import '../../providers/metodo_pago_provider.dart';
import '../../widgets/entity_list_tile.dart';

class MetodosPagoScreen extends StatefulWidget {
  const MetodosPagoScreen({super.key});
  @override State<MetodosPagoScreen> createState() => _MetodosPagoScreenState();
}

class _MetodosPagoScreenState extends State<MetodosPagoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<MetodoPagoProvider>().cargar());
  }

  void _dialogo({MetodoPago? item}) {
    final nCtrl = TextEditingController(text: item?.nombre ?? '');
    final dCtrl = TextEditingController(text: item?.descripcion ?? '');
    bool activo = item?.activo ?? true;
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => AlertDialog(
      title: Text(item == null ? 'Nuevo Método de Pago' : 'Editar Método de Pago'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nCtrl, decoration: const InputDecoration(labelText: 'Nombre *', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: dCtrl, decoration: const InputDecoration(labelText: 'Descripción', border: OutlineInputBorder())),
        SwitchListTile(title: const Text('Activo'), value: activo, onChanged: (v) => setS(() => activo = v)),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        FilledButton(onPressed: () async {
          if (nCtrl.text.trim().isEmpty) return;
          final prov = context.read<MetodoPagoProvider>();
          final mp = MetodoPago(id: item?.id ?? 0, nombre: nCtrl.text.trim(), descripcion: dCtrl.text.trim().isEmpty ? null : dCtrl.text.trim(), activo: activo);
          try {
            if (item == null) await prov.crear(mp); else await prov.actualizar(mp);
            if (ctx.mounted) Navigator.pop(ctx);
          } catch (e) { if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)); }
        }, child: Text(item == null ? 'Crear' : 'Guardar')),
      ],
    )));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Métodos de Pago'), centerTitle: true),
    floatingActionButton: FloatingActionButton.extended(onPressed: () => _dialogo(), icon: const Icon(Icons.add), label: const Text('Nuevo')),
    body: Consumer<MetodoPagoProvider>(builder: (_, prov, __) {
      if (prov.loading) return const Center(child: CircularProgressIndicator());
      if (prov.error != null) return ErrorBanner(message: prov.error!, onRetry: prov.cargar);
      if (prov.items.isEmpty) return const Center(child: Text('Sin registros.'));
      return RefreshIndicator(onRefresh: prov.cargar, child: ListView.builder(itemCount: prov.items.length, itemBuilder: (_, i) {
        final mp = prov.items[i];
        return EntityListTile(title: mp.nombre, subtitle: mp.activo ? 'Activo' : 'Inactivo', onEdit: () => _dialogo(item: mp),
          onDelete: () async {
            final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Eliminar'), content: Text('¿Eliminar "${mp.nombre}"?'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sí'))]));
            if (ok == true && context.mounted) { try { await context.read<MetodoPagoProvider>().eliminar(mp.id); } catch (e) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)); } }
          });
      }));
    }),
  );
}
