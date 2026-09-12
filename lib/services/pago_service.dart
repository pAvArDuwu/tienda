import '../core/api_client.dart';
import '../model/pago.dart';

class PagoService {
  Future<List<Pago>> obtenerTodos() async {
    final data = await ApiClient.get('/api/pagos') as List<dynamic>;
    return data.map((e) => Pago.fromJson(e as Map<String, dynamic>)).toList();
  }
  Future<List<Pago>> obtenerPorVenta(int ventaId) async {
    final data = await ApiClient.get('/api/ventas/$ventaId/pagos') as List<dynamic>;
    return data.map((e) => Pago.fromJson(e as Map<String, dynamic>)).toList();
  }
  Future<int> crear(Pago p) async {
    final res = await ApiClient.post('/api/pagos', p.toJson());
    return (res as Map<String, dynamic>)['id'] as int;
  }
  Future<void> eliminar(int id) => ApiClient.delete('/api/pagos/$id');
}
