import 'package:flutter/material.dart';
import '../model/pago.dart';
import '../services/pago_service.dart';

class PagoProvider extends ChangeNotifier {
  final _service = PagoService();
  List<Pago> items = [];
  bool loading = false;
  String? error;

  Future<void> cargar() async {
    loading = true; error = null; notifyListeners();
    try { items = await _service.obtenerTodos(); }
    catch (e) { error = e.toString(); }
    finally { loading = false; notifyListeners(); }
  }

  Future<void> crear(Pago p) async { await _service.crear(p); await cargar(); }
  Future<void> eliminar(int id) async { await _service.eliminar(id); await cargar(); }
}
