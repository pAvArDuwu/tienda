import 'package:flutter/material.dart';
import '../model/venta.dart';
import '../services/venta_service.dart';

class VentaProvider extends ChangeNotifier {
  final _service = VentaService();
  List<Venta> items = [];
  bool loading = false;
  String? error;

  Future<void> cargar() async {
    loading = true; error = null; notifyListeners();
    try { items = await _service.obtenerTodos(); }
    catch (e) { error = e.toString(); }
    finally { loading = false; notifyListeners(); }
  }

  Future<Map<String, dynamic>> crear(int clienteId, List<DetalleVentaInput> detalles) async {
    final res = await _service.crear(clienteId, detalles);
    await cargar();
    return res;
  }

  Future<void> actualizarEstado(int id, String estado) async {
    await _service.actualizarEstado(id, estado); await cargar();
  }
}
