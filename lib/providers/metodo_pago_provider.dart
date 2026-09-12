import 'package:flutter/material.dart';
import '../model/metodo_pago.dart';
import '../services/metodo_pago_service.dart';

class MetodoPagoProvider extends ChangeNotifier {
  final _service = MetodoPagoService();
  List<MetodoPago> items = [];
  bool loading = false;
  String? error;

  Future<void> cargar() async {
    loading = true; error = null; notifyListeners();
    try { items = await _service.obtenerTodos(); }
    catch (e) { error = e.toString(); }
    finally { loading = false; notifyListeners(); }
  }

  Future<void> crear(MetodoPago mp) async { await _service.crear(mp); await cargar(); }
  Future<void> actualizar(MetodoPago mp) async { await _service.actualizar(mp); await cargar(); }
  Future<void> eliminar(int id) async { await _service.eliminar(id); await cargar(); }
}
