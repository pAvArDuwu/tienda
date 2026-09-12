import '../core/api_client.dart';
import '../model/producto.dart';

class ProductoService {
  Future<List<Producto>> obtenerTodos() async {
    final data = await ApiClient.get('/api/productos') as List<dynamic>;
    return data.map((e) => Producto.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Producto?> obtenerPorId(int id) async {
    try {
      final data = await ApiClient.get('/api/productos/$id');
      return Producto.fromJson(data as Map<String, dynamic>);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<int> crear(Producto p) async {
    final res = await ApiClient.post('/api/productos', p.toJson());
    return (res as Map<String, dynamic>)['id'] as int;
  }

  Future<void> actualizar(Producto p) =>
      ApiClient.put('/api/productos/${p.id}', p.toJson());

  Future<void> eliminar(int id) => ApiClient.delete('/api/productos/$id');
}
