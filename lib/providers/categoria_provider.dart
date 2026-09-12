import 'package:flutter/material.dart';
import '../model/categoria.dart';
import '../services/categoria_service.dart';

class CategoriaProvider extends ChangeNotifier {
  final _service = CategoriaService();
  List<Categoria> items = [];
  bool loading = false;
  String? error;

  Future<void> cargar() async {
    loading = true; error = null; notifyListeners();
    try { items = await _service.obtenerTodos(); }
    catch (e) { error = e.toString(); }
    finally { loading = false; notifyListeners(); }
  }

  Future<void> crear(Categoria c) async {
    await _service.crear(c); await cargar();
  }
  Future<void> actualizar(Categoria c) async {
    await _service.actualizar(c); await cargar();
  }
  Future<void> eliminar(int id) async {
    await _service.eliminar(id); await cargar();
  }
}
