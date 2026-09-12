import '../core/api_client.dart';
import '../model/proveedor.dart';

class ProveedorService {
  Future<List<Proveedor>> obtenerTodos() async {
    final data = await ApiClient.get('/api/proveedores') as List<dynamic>;
    return data.map((e) => Proveedor.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Proveedor?> obtenerPorId(int id) async {
    try {
      final data = await ApiClient.get('/api/proveedores/$id');
      return Proveedor.fromJson(data as Map<String, dynamic>);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<int> crear(Proveedor p) async {
    final res = await ApiClient.post('/api/proveedores', p.toJson());
    return (res as Map<String, dynamic>)['id'] as int;
  }

  Future<void> actualizar(Proveedor p) =>
      ApiClient.put('/api/proveedores/${p.id}', p.toJson());

  Future<void> eliminar(int id) => ApiClient.delete('/api/proveedores/$id');
}
