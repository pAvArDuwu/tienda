import '../core/api_client.dart';
import '../model/tipo_movimiento.dart';

class TipoMovimientoService {
  Future<List<TipoMovimiento>> obtenerTodos() async {
    final data = await ApiClient.get('/api/tipos-movimiento') as List<dynamic>;
    return data.map((e) => TipoMovimiento.fromJson(e as Map<String, dynamic>)).toList();
  }
  Future<int> crear(TipoMovimiento tm) async {
    final res = await ApiClient.post('/api/tipos-movimiento', tm.toJson());
    return (res as Map<String, dynamic>)['id'] as int;
  }
  Future<void> actualizar(TipoMovimiento tm) => ApiClient.put('/api/tipos-movimiento/${tm.id}', tm.toJson());
  Future<void> eliminar(int id) => ApiClient.delete('/api/tipos-movimiento/$id');
}
