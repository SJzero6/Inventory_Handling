import '../core/network/api_client.dart';
import '../models/warehouse_location_model.dart';

class WarehouseLocationService {
  final ApiClient apiClient;

  WarehouseLocationService(this.apiClient);

  Future<List<WarehouseLocationModel>> getWarehouseLocations({
    required String token,
  }) async {
    final response = await apiClient.get('/warehouse-locations/', token: token);

    final List data = response['data'] ?? [];

    return data.map((item) => WarehouseLocationModel.fromJson(item)).toList();
  }

  Future<void> createWarehouseLocation({
    required Map<String, dynamic> body,
    required String token,
  }) async {
    await apiClient.post('/warehouse-locations/', body: body, token: token);
  }

  Future<void> updateWarehouseLocation({
    required int id,
    required Map<String, dynamic> body,
    required String token,
  }) async {
    await apiClient.put('/warehouse-locations/$id', body: body, token: token);
  }

  Future<void> deleteWarehouseLocation({
    required int id,
    required String token,
  }) async {
    await apiClient.delete('/warehouse-locations/$id', token: token);
  }
}
