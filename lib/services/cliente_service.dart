import '../core/api_client.dart';
import '../model/cliente.dart';

class ClienteService {
  Future<List<Cliente>> obtenerTodos() async {
    final data = await ApiClient.get('/api/clientes') as List<dynamic>;
    return data.map((e) => Cliente.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Cliente?> obtenerPorId(int id) async {
    try {
      final data = await ApiClient.get('/api/clientes/$id');
      return Cliente.fromJson(data as Map<String, dynamic>);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<int> crear(Cliente c) async {
    final res = await ApiClient.post('/api/clientes', c.toJson());
    return (res as Map<String, dynamic>)['id'] as int;
  }

  Future<void> actualizar(Cliente c) =>
      ApiClient.put('/api/clientes/${c.id}', c.toJson());

  Future<void> eliminar(int id) => ApiClient.delete('/api/clientes/$id');
}
