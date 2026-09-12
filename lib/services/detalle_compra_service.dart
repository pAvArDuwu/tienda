import '../core/api_client.dart';
import '../model/detalle_compra.dart';

class DetalleCompraService {
  Future<List<DetalleCompra>> obtenerPorCompra(int compraId) async {
    final data = await ApiClient.get('/api/compras/$compraId/detalles') as List<dynamic>;
    return data.map((e) => DetalleCompra.fromJson(e as Map<String, dynamic>)).toList();
  }
  Future<int> crear(DetalleCompra dc) async {
    final res = await ApiClient.post('/api/detalle_compra', dc.toJson());
    return (res as Map<String, dynamic>)['id'] as int;
  }
  Future<void> eliminar(int id) => ApiClient.delete('/api/detalle_compra/$id');
}
