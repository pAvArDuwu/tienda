import 'package:flutter/material.dart';
import '../model/producto.dart';
import '../services/producto_service.dart';

class ProductoProvider extends ChangeNotifier {
  final _service = ProductoService();
  List<Producto> items = [];
  bool loading = false;
  String? error;

  Future<void> cargar() async {
    loading = true; error = null; notifyListeners();
    try { items = await _service.obtenerTodos(); }
    catch (e) { error = e.toString(); }
    finally { loading = false; notifyListeners(); }
  }

  Future<void> crear(Producto p) async { await _service.crear(p); await cargar(); }
  Future<void> actualizar(Producto p) async { await _service.actualizar(p); await cargar(); }
  Future<void> eliminar(int id) async { await _service.eliminar(id); await cargar(); }
}
