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
    final dCtrl = TextEditingController(text: item?.descripcion ?? '');
    int signo = item?.signo ?? 1;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(item == null ? 'Nuevo Tipo Movimiento' : 'Editar Tipo Movimiento'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nCtrl,
                decoration: const InputDecoration(labelText: 'Nombre *', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dCtrl,
                decoration: const InputDecoration(labelText: 'Descripción', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: signo,
                decoration: const InputDecoration(labelText: 'Tipo de Movimiento', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('↑ Entrada (+1)')),
                  DropdownMenuItem(value: -1, child: Text('↓ Salida (-1)')),
                ],
                onChanged: (v) => setS(() => signo = v!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () async {
                if (nCtrl.text.trim().isEmpty) return;
                final prov = context.read<TipoMovimientoProvider>();
                final tm = TipoMovimiento(
                  id: item?.id ?? 0,
                  nombre: nCtrl.text.trim(),
                  descripcion: dCtrl.text.trim().isEmpty ? null : dCtrl.text.trim(),
                  signo: signo,
                );
                try {
                  if (item == null) {
                    await prov.crear(tm);
                  } else {
                    await prov.actualizar(tm);
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: Text(item == null ? 'Crear' : 'Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Tipos de Movimiento'), centerTitle: true),
    floatingActionButton: FloatingActionButton.extended(onPressed: () => _dialogo(), icon: const Icon(Icons.add), label: const Text('Nuevo')),
    body: Consumer<TipoMovimientoProvider>(builder: (_, prov, __) {
      if (prov.loading) return const Center(child: CircularProgressIndicator());
      if (prov.error != null) return ErrorBanner(message: prov.error!, onRetry: prov.cargar);
      if (prov.items.isEmpty) return const Center(child: Text('Sin registros.'));
      return RefreshIndicator(
        onRefresh: prov.cargar,
        child: ListView.builder(
          itemCount: prov.items.length,
          itemBuilder: (_, i) {
            final tm = prov.items[i];
            final esEntrada = tm.signo >= 0;
            return EntityListTile(
              title: tm.nombre,
              subtitle: '${esEntrada ? '↑ Entrada' : '↓ Salida'}${tm.descripcion != null ? ' - ${tm.descripcion}' : ''}',
              leading: CircleAvatar(
                backgroundColor: esEntrada ? Colors.green.shade100 : Colors.red.shade100,
                child: Icon(
                  esEntrada ? Icons.arrow_downward : Icons.arrow_upward,
                  color: esEntrada ? Colors.green : Colors.red,
                ),
              ),
              onEdit: () => _dialogo(item: tm),
              onDelete: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Eliminar'),
                    content: Text('¿Eliminar "${tm.nombre}"?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
                      FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sí')),
                    ],
                  ),
                );
                if (ok == true && context.mounted) {
                  try {
                    await context.read<TipoMovimientoProvider>().eliminar(tm.id);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                      );
                    }
                  }
                }
              },
            );
          },
        ),
      );
    }),
  );
}
