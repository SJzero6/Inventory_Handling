import '../core/network/api_client.dart';
import '../models/warehouse_model.dart';

class WarehouseService {
  final ApiClient apiClient;

  WarehouseService(this.apiClient);

  Future<List<WarehouseModel>> getWarehouses({required String token}) async {
    final response = await apiClient.get('/warehouses/', token: token);

    final List data = response['data'] ?? [];

    return data.map((item) => WarehouseModel.fromJson(item)).toList();
  }

  Future<void> createWarehouse({
    required Map<String, dynamic> body,
    required String token,
  }) async {
    await apiClient.post('/warehouses/', body: body, token: token);
  }

  Future<void> updateWarehouse({
    required int id,
    required Map<String, dynamic> body,
    required String token,
  }) async {
    await apiClient.put('/warehouses/$id', body: body, token: token);
  }

  Future<void> deleteWarehouse({required int id, required String token}) async {
    await apiClient.delete('/warehouses/$id', token: token);
  }
}
