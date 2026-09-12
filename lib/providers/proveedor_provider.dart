import 'package:flutter/material.dart';
import '../model/proveedor.dart';
import '../services/proveedor_service.dart';

class ProveedorProvider extends ChangeNotifier {
  final _service = ProveedorService();
  List<Proveedor> items = [];
  bool loading = false;
  String? error;

  Future<void> cargar() async {
    loading = true; error = null; notifyListeners();
    try { items = await _service.obtenerTodos(); }
    catch (e) { error = e.toString(); }
    finally { loading = false; notifyListeners(); }
  }

  Future<void> crear(Proveedor p) async { await _service.crear(p); await cargar(); }
  Future<void> actualizar(Proveedor p) async { await _service.actualizar(p); await cargar(); }
  Future<void> eliminar(int id) async { await _service.eliminar(id); await cargar(); }
}
