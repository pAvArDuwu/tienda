import 'package:flutter/material.dart';
import '../model/estado_venta.dart';
import '../services/estado_venta_service.dart';

class EstadoVentaProvider extends ChangeNotifier {
  final _service = EstadoVentaService();
  List<EstadoVenta> items = [];
  bool loading = false;
  String? error;

  Future<void> cargar() async {
    loading = true; error = null; notifyListeners();
    try { items = await _service.obtenerTodos(); }
    catch (e) { error = e.toString(); }
    finally { loading = false; notifyListeners(); }
  }

  Future<void> crear(EstadoVenta ev) async { await _service.crear(ev); await cargar(); }
  Future<void> actualizar(EstadoVenta ev) async { await _service.actualizar(ev); await cargar(); }
  Future<void> eliminar(int id) async { await _service.eliminar(id); await cargar(); }
}
