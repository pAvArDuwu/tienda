import '../core/api_client.dart';
import '../model/compra.dart';

class CompraService {
  Future<List<Compra>> obtenerTodos() async {
    final data = await ApiClient.get('/api/compras') as List<dynamic>;
    return data.map((e) => Compra.fromJson(e as Map<String, dynamic>)).toList();
  }
  Future<int> crear(Compra c) async {
    final res = await ApiClient.post('/api/compras', c.toJson());
    return (res as Map<String, dynamic>)['id'] as int;
  }
  Future<void> actualizar(Compra c) => ApiClient.put('/api/compras/${c.id}', c.toJson());
  Future<void> eliminar(int id) => ApiClient.delete('/api/compras/$id');
}
