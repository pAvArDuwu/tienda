import 'package:flutter/material.dart';
import '../model/compra.dart';
import '../services/compra_service.dart';

class CompraProvider extends ChangeNotifier {
  final _service = CompraService();
  List<Compra> items = [];
  bool loading = false;
  String? error;

  Future<void> cargar() async {
    loading = true; error = null; notifyListeners();
    try { items = await _service.obtenerTodos(); }
    catch (e) { error = e.toString(); }
    finally { loading = false; notifyListeners(); }
  }

  Future<void> crear(Compra c) async { await _service.crear(c); await cargar(); }
  Future<void> actualizar(Compra c) async { await _service.actualizar(c); await cargar(); }
  Future<void> eliminar(int id) async { await _service.eliminar(id); await cargar(); }
}
