import '../core/network/api_client.dart';
import '../models/brand_model.dart';

class BrandService {
  final ApiClient apiClient;

  BrandService(this.apiClient);

  Future<List<BrandModel>> getBrands({required String token}) async {
    final response = await apiClient.get('/brands', token: token);

    final List data = response['data'] ?? [];

    return data
        .map((item) => BrandModel.fromJson(item))
        .where((brand) => brand.isActive)
        .toList();
  }
}
