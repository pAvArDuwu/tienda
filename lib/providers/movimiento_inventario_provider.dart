import 'package:flutter/material.dart';
import '../model/movimiento_inventario.dart';
import '../services/movimiento_inventario_service.dart';

class MovimientoInventarioProvider extends ChangeNotifier {
  final _service = MovimientoInventarioService();
  List<MovimientoInventario> items = [];
  bool loading = false;
  String? error;

  Future<void> cargar() async {
    loading = true; error = null; notifyListeners();
    try { items = await _service.obtenerTodos(); }
    catch (e) { error = e.toString(); }
    finally { loading = false; notifyListeners(); }
  }

  Future<void> crear(MovimientoInventario mi) async {
    await _service.crear(mi); await cargar();
  }
}
