import 'package:flutter/material.dart';
import '../model/tipo_movimiento.dart';
import '../services/tipo_movimiento_service.dart';

class TipoMovimientoProvider extends ChangeNotifier {
  final _service = TipoMovimientoService();
  List<TipoMovimiento> items = [];
  bool loading = false;
  String? error;

  Future<void> cargar() async {
    loading = true; error = null; notifyListeners();
    try { items = await _service.obtenerTodos(); }
    catch (e) { error = e.toString(); }
    finally { loading = false; notifyListeners(); }
  }

  Future<void> crear(TipoMovimiento tm) async { await _service.crear(tm); await cargar(); }
  Future<void> actualizar(TipoMovimiento tm) async { await _service.actualizar(tm); await cargar(); }
  Future<void> eliminar(int id) async { await _service.eliminar(id); await cargar(); }
}
