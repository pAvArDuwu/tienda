import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/venta.dart';
import '../../model/producto.dart';
import '../../providers/venta_provider.dart';
import '../../providers/cliente_provider.dart';
import '../../providers/producto_provider.dart';

class VentasScreen extends StatefulWidget {
  const VentasScreen({super.key});
  @override State<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VentaProvider>().cargar();
      context.read<ClienteProvider>().cargar();
      context.read<ProductoProvider>().cargar();
    });
  }

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'pagada': return Colors.green;
      case 'cancelada': return Colors.red;
      default: return Colors.orange;
    }
  }

  void _nuevaVenta() {
    final clientes = context.read<ClienteProvider>().items;
    final productos = context.read<ProductoProvider>().items;
    if (clientes.isEmpty || productos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Carga clientes y productos primero')));
      return;
    }
    int? clienteId = clientes.first.id;
    final List<Map<String, dynamic>> detalles = [];
    int? prodSelId = productos.first.id;
    int cantSel = 1;

    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => AlertDialog(
      title: const Text('Nueva Venta'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButtonFormField<int>(
          value: clienteId,
          decoration: const InputDecoration(labelText: 'Cliente *', border: OutlineInputBorder()),
          items: clientes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.nombreCompleto))).toList(),
          onChanged: (v) => setS(() => clienteId = v),
        ),
        const SizedBox(height: 12),
        const Text('Agregar productos:', style: TextStyle(fontWeight: FontWeight.bold)),
        DropdownButtonFormField<int>(
          value: prodSelId,
          decoration: const InputDecoration(labelText: 'Producto', border: OutlineInputBorder()),
          items: productos.map((p) => DropdownMenuItem(value: p.id, child: Text('${p.nombre} — Bs.${p.precio.toStringAsFixed(2)}'))).toList(),
          onChanged: (v) => setS(() => prodSelId = v),
        ),
        Row(children: [
          Expanded(child: TextFormField(initialValue: cantSel.toString(), keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cant.', border: OutlineInputBorder()), onChanged: (v) => cantSel = int.tryParse(v) ?? 1)),
          const SizedBox(width: 8),
          FilledButton(onPressed: () {
            if (prodSelId != null && cantSel > 0) {
              setS(() { detalles.add({'producto_id': prodSelId, 'cantidad': cantSel}); });
            }
          }, child: const Icon(Icons.add)),
        ]),
        if (detalles.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...detalles.map((d) {
            final p = productos.firstWhere((pr) => pr.id == d['producto_id'], orElse: () => Producto(id: 0, nombre: '?', precio: 0));
            return ListTile(dense: true, title: Text(p.nombre), trailing: Text('x${d['cantidad']}'));
          }),
        ],
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        FilledButton(onPressed: () async {
          if (clienteId == null || detalles.isEmpty) return;
          final inputs = detalles.map((d) => DetalleVentaInput(productoId: d['producto_id'] as int, cantidad: d['cantidad'] as int)).toList();
          try {
            final res = await context.read<VentaProvider>().crear(clienteId!, inputs);
            if (ctx.mounted) { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Venta #${res['id']} creada. Total: Bs.${res['total']}'), backgroundColor: Colors.green)); }
          } catch (e) { if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)); }
        }, child: const Text('Registrar')),
      ],
    )));
  }

  void _cambiarEstado(Venta v) {
    int estadoVentaId = v.estadoVentaId;
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => AlertDialog(
      title: Text('Estado Venta #${v.id}'),
      content: DropdownButtonFormField<int>(
        value: estadoVentaId,
        decoration: const InputDecoration(border: OutlineInputBorder()),
        items: const [
          DropdownMenuItem(value: 1, child: Text('Pendiente')),
          DropdownMenuItem(value: 2, child: Text('Pagada')),
          DropdownMenuItem(value: 3, child: Text('Cancelada')),
        ],
        onChanged: (val) => setS(() => estadoVentaId = val!),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        FilledButton(onPressed: () async {
          try {
            await context.read<VentaProvider>().actualizarEstado(v.id, estadoVentaId);
            if (ctx.mounted) Navigator.pop(ctx);
          }
          catch (e) {
            if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
          }
        }, child: const Text('Guardar')),
      ],
    )));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Ventas'), centerTitle: true),
    floatingActionButton: FloatingActionButton.extended(onPressed: _nuevaVenta, icon: const Icon(Icons.receipt_long), label: const Text('Nueva Venta')),
    body: Consumer<VentaProvider>(builder: (_, prov, __) {
      if (prov.loading) return const Center(child: CircularProgressIndicator());
      if (prov.error != null) return Center(child: Text(prov.error!));
      if (prov.items.isEmpty) return const Center(child: Text('Sin ventas registradas.'));
      return RefreshIndicator(onRefresh: prov.cargar, child: ListView.builder(itemCount: prov.items.length, itemBuilder: (_, i) {
        final v = prov.items[i];
        return Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: ListTile(
          leading: CircleAvatar(backgroundColor: _estadoColor(v.estado).withOpacity(0.15), child: Text('#${v.id}', style: TextStyle(color: _estadoColor(v.estado), fontWeight: FontWeight.bold, fontSize: 12))),
          title: Text('Venta #${v.id} — Cliente #${v.clienteId}'),
          subtitle: Text('Bs. ${v.total.toStringAsFixed(2)} • ${v.fecha ?? 'Sin fecha'}'),
          trailing: Chip(label: Text(v.estado, style: const TextStyle(fontSize: 11, color: Colors.white)), backgroundColor: _estadoColor(v.estado)),
          onTap: () => _cambiarEstado(v),
        ));
      }));
    }),
  );
}
