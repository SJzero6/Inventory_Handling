import '../core/network/api_client.dart';
import '../models/brand_model.dart';

class BrandService {
  final ApiClient apiClient;

  BrandService(this.apiClient);

  Future<List<BrandModel>> getBrands({required String token}) async {
    final response = await apiClient.get('/brands/', token: token);

    final List data = response['data'] ?? [];

    return data
        .map((item) => BrandModel.fromJson(item))
        .where((brand) => brand.isActive)
        .toList();
  }

  Future<void> createBrand({
    required String name,
    required String token,
  }) async {
    await apiClient.post('/brands/', body: {'name': name}, token: token);
  }

  Future<void> updateBrand({
    required int id,
    required String name,
    required String token,
  }) async {
    await apiClient.put('/brands/$id', body: {'name': name}, token: token);
  }

  Future<void> deleteBrand({required int id, required String token}) async {
    await apiClient.delete('/brands/$id', token: token);
  }
}
