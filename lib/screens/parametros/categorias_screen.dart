import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/categoria.dart';
import '../../providers/categoria_provider.dart';
import '../../widgets/entity_list_tile.dart';

class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({super.key});

  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoriaProvider>().cargar();
    });
  }

  void _mostrarDialogo({Categoria? item}) {
    final nombreCtrl = TextEditingController(text: item?.nombre ?? '');
    final descCtrl = TextEditingController(text: item?.descripcion ?? '');
    bool activo = item?.activo ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(item == null ? 'Nueva Categoría' : 'Editar Categoría'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre *', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descripción', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              SwitchListTile(title: const Text('Activo'), value: activo, onChanged: (v) => setS(() => activo = v)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () async {
                if (nombreCtrl.text.trim().isEmpty) return;
                final prov = context.read<CategoriaProvider>();
                final cat = Categoria(id: item?.id ?? 0, nombre: nombreCtrl.text.trim(), descripcion: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(), activo: activo);
                try {
                  if (item == null) await prov.crear(cat);
                  else await prov.actualizar(cat);
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (e) {
                  if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categorías'), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarDialogo(),
        icon: const Icon(Icons.add),
        label: const Text('Nueva'),
      ),
      body: Consumer<CategoriaProvider>(
        builder: (_, prov, __) {
          if (prov.loading) return const Center(child: CircularProgressIndicator());
          if (prov.error != null) return ErrorBanner(message: prov.error!, onRetry: prov.cargar);
          if (prov.items.isEmpty) return const Center(child: Text('Sin registros. Agrega la primera categoría.'));
          return RefreshIndicator(
            onRefresh: prov.cargar,
            child: ListView.builder(
              itemCount: prov.items.length,
              itemBuilder: (_, i) {
                final c = prov.items[i];
                return EntityListTile(
                  title: c.nombre,
                  subtitle: c.descripcion,
                  leading: CircleAvatar(
                    backgroundColor: c.activo ? Colors.green.shade100 : Colors.grey.shade200,
                    child: Icon(Icons.category_outlined, color: c.activo ? Colors.green : Colors.grey),
                  ),
                  onEdit: () => _mostrarDialogo(item: c),
                  onDelete: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Eliminar'),
                        content: Text('¿Eliminar "${c.nombre}"?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
                          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sí')),
                        ],
                      ),
                    );
                    if (ok == true && context.mounted) {
                      try { await context.read<CategoriaProvider>().eliminar(c.id); }
                      catch (e) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)); }
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
