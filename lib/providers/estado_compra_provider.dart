import 'package:flutter/material.dart';
import '../model/estado_compra.dart';
import '../services/estado_compra_service.dart';

class EstadoCompraProvider extends ChangeNotifier {
  final _service = EstadoCompraService();
  List<EstadoCompra> items = [];
  bool loading = false;
  String? error;

  Future<void> cargar() async {
    loading = true; error = null; notifyListeners();
    try { items = await _service.obtenerTodos(); }
    catch (e) { error = e.toString(); }
    finally { loading = false; notifyListeners(); }
  }

  Future<void> crear(EstadoCompra ec) async { await _service.crear(ec); await cargar(); }
  Future<void> actualizar(EstadoCompra ec) async { await _service.actualizar(ec); await cargar(); }
  Future<void> eliminar(int id) async { await _service.eliminar(id); await cargar(); }
}
