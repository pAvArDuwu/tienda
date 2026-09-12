import '../core/api_client.dart';
import '../model/venta.dart';

class VentaService {
  Future<List<Venta>> obtenerTodos() async {
    final data = await ApiClient.get('/api/ventas') as List<dynamic>;
    return data.map((e) => Venta.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Venta?> obtenerPorId(int id) async {
    try {
      final data = await ApiClient.get('/api/ventas/$id');
      return Venta.fromJson(data as Map<String, dynamic>);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<Map<String, dynamic>> crear(int clienteId, List<DetalleVentaInput> detalles) async {
    final body = {'cliente_id': clienteId, 'detalles': detalles.map((d) => d.toJson()).toList()};
    final res = await ApiClient.post('/api/ventas', body);
    return res as Map<String, dynamic>;
  }

  Future<void> actualizarEstado(int id, String estado) =>
      ApiClient.put('/api/ventas/$id/estado', {'estado': estado});
}
