import '../core/api_client.dart';
import '../model/estado_compra.dart';

class EstadoCompraService {
  Future<List<EstadoCompra>> obtenerTodos() async {
    final data = await ApiClient.get('/api/estados-compra') as List<dynamic>;
    return data.map((e) => EstadoCompra.fromJson(e as Map<String, dynamic>)).toList();
  }
  Future<int> crear(EstadoCompra ec) async {
    final res = await ApiClient.post('/api/estados-compra', ec.toJson());
    return (res as Map<String, dynamic>)['id'] as int;
  }
  Future<void> actualizar(EstadoCompra ec) => ApiClient.put('/api/estados-compra/${ec.id}', ec.toJson());
  Future<void> eliminar(int id) => ApiClient.delete('/api/estados-compra/$id');
}
