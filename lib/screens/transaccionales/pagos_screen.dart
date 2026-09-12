import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/pago.dart';
import '../../providers/pago_provider.dart';
import '../../providers/venta_provider.dart';
import '../../providers/metodo_pago_provider.dart';

class PagosScreen extends StatefulWidget {
  const PagosScreen({super.key});
  @override State<PagosScreen> createState() => _PagosScreenState();
}

class _PagosScreenState extends State<PagosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PagoProvider>().cargar();
      context.read<VentaProvider>().cargar();
      context.read<MetodoPagoProvider>().cargar();
    });
  }

  void _dialogo() {
    final ventas = context.read<VentaProvider>().items;
    final metodos = context.read<MetodoPagoProvider>().items;
    if (ventas.isEmpty || metodos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Carga ventas y métodos de pago primero')));
      return;
    }
    int? ventaId = ventas.first.id;
    int? metodoId = metodos.first.id;
    final montoCtrl = TextEditingController();
    final refCtrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => AlertDialog(
      title: const Text('Registrar Pago'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButtonFormField<int>(value: ventaId, decoration: const InputDecoration(labelText: 'Venta *', border: OutlineInputBorder()), items: ventas.map((v) => DropdownMenuItem(value: v.id, child: Text('#${v.id} — Bs.${v.total.toStringAsFixed(2)}'))).toList(), onChanged: (v) => setS(() => ventaId = v)),
        const SizedBox(height: 10),
        DropdownButtonFormField<int>(value: metodoId, decoration: const InputDecoration(labelText: 'Método Pago *', border: OutlineInputBorder()), items: metodos.map((m) => DropdownMenuItem(value: m.id, child: Text(m.nombre))).toList(), onChanged: (v) => setS(() => metodoId = v)),
        const SizedBox(height: 10),
        TextField(controller: montoCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Monto *', prefixText: 'Bs. ', border: OutlineInputBorder())),
        const SizedBox(height: 10),
        TextField(controller: refCtrl, decoration: const InputDecoration(labelText: 'Referencia', border: OutlineInputBorder())),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        FilledButton(onPressed: () async {
          if (ventaId == null || metodoId == null) return;
          final monto = double.tryParse(montoCtrl.text.trim()) ?? 0;
          final pago = Pago(id: 0, ventaId: ventaId!, metodoPagoId: metodoId!, monto: monto, referencia: refCtrl.text.trim().isEmpty ? null : refCtrl.text.trim());
          try {
            await context.read<PagoProvider>().crear(pago);
            if (ctx.mounted) Navigator.pop(ctx);
          } catch (e) { if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)); }
        }, child: const Text('Registrar')),
      ],
    )));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Pagos'), centerTitle: true),
    floatingActionButton: FloatingActionButton.extended(onPressed: _dialogo, icon: const Icon(Icons.payment), label: const Text('Registrar')),
    body: Consumer<PagoProvider>(builder: (_, prov, __) {
      if (prov.loading) return const Center(child: CircularProgressIndicator());
      if (prov.error != null) return Center(child: Text(prov.error!));
      if (prov.items.isEmpty) return const Center(child: Text('Sin pagos.'));
      return RefreshIndicator(onRefresh: prov.cargar, child: ListView.builder(itemCount: prov.items.length, itemBuilder: (_, i) {
        final p = prov.items[i];
        return Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.payment)),
          title: Text('Venta #${p.ventaId} — Bs.${p.monto.toStringAsFixed(2)}'),
          subtitle: Text('Método #${p.metodoPagoId} • ${p.fecha ?? 'Sin fecha'}${p.referencia != null ? " • ${p.referencia}" : ""}'),
          trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () async {
            final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Eliminar pago'), content: Text('¿Eliminar pago de Bs.${p.monto}?'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sí'))]));
            if (ok == true && context.mounted) { try { await context.read<PagoProvider>().eliminar(p.id); } catch (e) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)); } }
          }),
        ));
      }));
    }),
  );
}
