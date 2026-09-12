import '../core/api_client.dart';
import '../model/metodo_pago.dart';

class MetodoPagoService {
  Future<List<MetodoPago>> obtenerTodos() async {
    final data = await ApiClient.get('/api/metodos_pago') as List<dynamic>;
    return data.map((e) => MetodoPago.fromJson(e as Map<String, dynamic>)).toList();
  }
  Future<int> crear(MetodoPago mp) async {
    final res = await ApiClient.post('/api/metodos_pago', mp.toJson());
    return (res as Map<String, dynamic>)['id'] as int;
  }
  Future<void> actualizar(MetodoPago mp) => ApiClient.put('/api/metodos_pago/${mp.id}', mp.toJson());
  Future<void> eliminar(int id) => ApiClient.delete('/api/metodos_pago/$id');
}
