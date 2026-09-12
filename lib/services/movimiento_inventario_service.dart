import '../core/api_client.dart';
import '../model/movimiento_inventario.dart';

class MovimientoInventarioService {
  Future<List<MovimientoInventario>> obtenerTodos() async {
    final data = await ApiClient.get('/api/movimientos_inventario') as List<dynamic>;
    return data.map((e) => MovimientoInventario.fromJson(e as Map<String, dynamic>)).toList();
  }
  Future<int> crear(MovimientoInventario mi) async {
    final res = await ApiClient.post('/api/movimientos_inventario', mi.toJson());
    return (res as Map<String, dynamic>)['id'] as int;
  }
}
