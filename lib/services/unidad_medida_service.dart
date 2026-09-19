import '../core/api_client.dart';
import '../model/unidad_medida.dart';

class UnidadMedidaService {
  Future<List<UnidadMedida>> obtenerTodos() async {
    final data = await ApiClient.get('/api/unidades-medida') as List<dynamic>;
    return data.map((e) => UnidadMedida.fromJson(e as Map<String, dynamic>)).toList();
  }
  Future<int> crear(UnidadMedida um) async {
    final res = await ApiClient.post('/api/unidades-medida', um.toJson());
    return (res as Map<String, dynamic>)['id'] as int;
  }
  Future<void> actualizar(UnidadMedida um) => ApiClient.put('/api/unidades-medida/${um.id}', um.toJson());
  Future<void> eliminar(int id) => ApiClient.delete('/api/unidades-medida/$id');
}
