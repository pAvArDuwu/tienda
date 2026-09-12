import 'package:flutter/material.dart';
import '../model/unidad_medida.dart';
import '../services/unidad_medida_service.dart';

class UnidadMedidaProvider extends ChangeNotifier {
  final _service = UnidadMedidaService();
  List<UnidadMedida> items = [];
  bool loading = false;
  String? error;

  Future<void> cargar() async {
    loading = true; error = null; notifyListeners();
    try { items = await _service.obtenerTodos(); }
    catch (e) { error = e.toString(); }
    finally { loading = false; notifyListeners(); }
  }

  Future<void> crear(UnidadMedida um) async { await _service.crear(um); await cargar(); }
  Future<void> actualizar(UnidadMedida um) async { await _service.actualizar(um); await cargar(); }
  Future<void> eliminar(int id) async { await _service.eliminar(id); await cargar(); }
}
