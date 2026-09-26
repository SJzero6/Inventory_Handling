import '../core/network/api_client.dart';
import '../models/supplier_model.dart';

class SupplierService {
  final ApiClient apiClient;

  SupplierService(this.apiClient);

  Future<List<SupplierModel>> getSuppliers({required String token}) async {
    final response = await apiClient.get('/suppliers/', token: token);

    final List data = response['data'] ?? [];

    return data.map((e) => SupplierModel.fromJson(e)).toList();
  }

  Future<void> createSupplier({
    required Map<String, dynamic> body,
    required String token,
  }) async {
    await apiClient.post('/suppliers/', body: body, token: token);
  }

  Future<void> updateSupplier({
    required int id,
    required Map<String, dynamic> body,
    required String token,
  }) async {
    await apiClient.put('/suppliers/$id', body: body, token: token);
  }

  Future<void> deleteSupplier({required int id, required String token}) async {
    await apiClient.delete('/suppliers/$id', token: token);
  }
}
