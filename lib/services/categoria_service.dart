import '../core/api_client.dart';
import '../model/categoria.dart';

class CategoriaService {
  Future<List<Categoria>> obtenerTodos() async {
    final data = await ApiClient.get('/api/categorias') as List<dynamic>;
    return data.map((e) => Categoria.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Categoria?> obtenerPorId(int id) async {
    try {
      final data = await ApiClient.get('/api/categorias/$id');
      return Categoria.fromJson(data as Map<String, dynamic>);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<int> crear(Categoria c) async {
    final res = await ApiClient.post('/api/categorias', c.toJson());
    return (res as Map<String, dynamic>)['id'] as int;
  }

  Future<void> actualizar(Categoria c) =>
      ApiClient.put('/api/categorias/${c.id}', c.toJson());

  Future<void> eliminar(int id) => ApiClient.delete('/api/categorias/$id');
}
