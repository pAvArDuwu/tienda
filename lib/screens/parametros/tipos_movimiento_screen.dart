import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/tipo_movimiento.dart';
import '../../providers/tipo_movimiento_provider.dart';
import '../../widgets/entity_list_tile.dart';

class TiposMovimientoScreen extends StatefulWidget {
  const TiposMovimientoScreen({super.key});
  @override State<TiposMovimientoScreen> createState() => _TiposMovimientoScreenState();
}

class _TiposMovimientoScreenState extends State<TiposMovimientoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<TipoMovimientoProvider>().cargar());
  }

  void _dialogo({TipoMovimiento? item}) {
    final nCtrl = TextEditingController(text: item?.nombre ?? '');
    String tipo = item?.tipo ?? 'entrada';
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => AlertDialog(
      title: Text(item == null ? 'Nuevo Tipo Movimiento' : 'Editar Tipo Movimiento'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nCtrl, decoration: const InputDecoration(labelText: 'Nombre *', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: tipo,
          decoration: const InputDecoration(labelText: 'Tipo', border: OutlineInputBorder()),
          items: const [DropdownMenuItem(value: 'entrada', child: Text('Entrada')), DropdownMenuItem(value: 'salida', child: Text('Salida'))],
          onChanged: (v) => setS(() => tipo = v!),
        ),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        FilledButton(onPressed: () async {
          if (nCtrl.text.trim().isEmpty) return;
          final prov = context.read<TipoMovimientoProvider>();
          final tm = TipoMovimiento(id: item?.id ?? 0, nombre: nCtrl.text.trim(), tipo: tipo);
          try {
            if (item == null) await prov.crear(tm); else await prov.actualizar(tm);
            if (ctx.mounted) Navigator.pop(ctx);
          } catch (e) { if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)); }
        }, child: Text(item == null ? 'Crear' : 'Guardar')),
      ],
    )));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Tipos de Movimiento'), centerTitle: true),
    floatingActionButton: FloatingActionButton.extended(onPressed: () => _dialogo(), icon: const Icon(Icons.add), label: const Text('Nuevo')),
    body: Consumer<TipoMovimientoProvider>(builder: (_, prov, __) {
      if (prov.loading) return const Center(child: CircularProgressIndicator());
      if (prov.error != null) return ErrorBanner(message: prov.error!, onRetry: prov.cargar);
      if (prov.items.isEmpty) return const Center(child: Text('Sin registros.'));
      return RefreshIndicator(onRefresh: prov.cargar, child: ListView.builder(itemCount: prov.items.length, itemBuilder: (_, i) {
        final tm = prov.items[i];
        return EntityListTile(title: tm.nombre, subtitle: tm.tipo == 'entrada' ? '↑ Entrada' : '↓ Salida',
          leading: CircleAvatar(backgroundColor: tm.tipo == 'entrada' ? Colors.green.shade100 : Colors.red.shade100, child: Icon(tm.tipo == 'entrada' ? Icons.arrow_downward : Icons.arrow_upward, color: tm.tipo == 'entrada' ? Colors.green : Colors.red)),
          onEdit: () => _dialogo(item: tm),
          onDelete: () async {
            final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Eliminar'), content: Text('¿Eliminar "${tm.nombre}"?'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sí'))]));
            if (ok == true && context.mounted) { try { await context.read<TipoMovimientoProvider>().eliminar(tm.id); } catch (e) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)); } }
          });
      }));
    }),
  );
}
