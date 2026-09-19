import '../core/api_client.dart';
import '../model/estado_venta.dart';

class EstadoVentaService {
  Future<List<EstadoVenta>> obtenerTodos() async {
    final data = await ApiClient.get('/api/estados-venta') as List<dynamic>;
    return data.map((e) => EstadoVenta.fromJson(e as Map<String, dynamic>)).toList();
  }
  Future<int> crear(EstadoVenta ev) async {
    final res = await ApiClient.post('/api/estados-venta', ev.toJson());
    return (res as Map<String, dynamic>)['id'] as int;
  }
  Future<void> actualizar(EstadoVenta ev) => ApiClient.put('/api/estados-venta/${ev.id}', ev.toJson());
  Future<void> eliminar(int id) => ApiClient.delete('/api/estados-venta/$id');
}
