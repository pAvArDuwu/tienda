import '../core/api_client.dart';
import '../model/detalle_venta.dart';

class DetalleVentaService {
  Future<List<DetalleVenta>> obtenerPorVenta(int ventaId) async {
    final data = await ApiClient.get('/api/ventas/$ventaId/detalles') as List<dynamic>;
    return data.map((e) => DetalleVenta.fromJson(e as Map<String, dynamic>)).toList();
  }
  Future<int> crear(DetalleVenta dv) async {
    final res = await ApiClient.post('/api/detalle_venta', dv.toJson());
    return (res as Map<String, dynamic>)['id'] as int;
  }
  Future<void> eliminar(int id) => ApiClient.delete('/api/detalle_venta/$id');
}
