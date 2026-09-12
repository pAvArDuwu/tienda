import 'package:flutter/material.dart';
import '../model/cliente.dart';
import '../services/cliente_service.dart';

class ClienteProvider extends ChangeNotifier {
  final _service = ClienteService();
  List<Cliente> items = [];
  bool loading = false;
  String? error;

  Future<void> cargar() async {
    loading = true; error = null; notifyListeners();
    try { items = await _service.obtenerTodos(); }
    catch (e) { error = e.toString(); }
    finally { loading = false; notifyListeners(); }
  }

  Future<void> crear(Cliente c) async { await _service.crear(c); await cargar(); }
  Future<void> actualizar(Cliente c) async { await _service.actualizar(c); await cargar(); }
  Future<void> eliminar(int id) async { await _service.eliminar(id); await cargar(); }
}
