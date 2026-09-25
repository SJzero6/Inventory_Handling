import '../core/network/api_client.dart';
import '../models/category_model.dart';

class CategoryService {
  final ApiClient apiClient;

  CategoryService(this.apiClient);

  Future<List<CategoryModel>> getCategories({required String token}) async {
    final response = await apiClient.get('/categories/', token: token);

    final List data = response['data'] ?? [];

    return data
        .map((item) => CategoryModel.fromJson(item))
        .where((category) => category.isActive)
        .toList();
  }

  Future<void> createCategory({
    required String name,
    String? description,
    required String token,
  }) async {
    await apiClient.post(
      '/categories/',
      body: {'name': name, 'description': description},
      token: token,
    );
  }

  Future<void> updateCategory({
    required int id,
    required String name,
    String? description,
    required String token,
  }) async {
    await apiClient.put(
      '/categories/$id',
      body: {'name': name, 'description': description},
      token: token,
    );
  }
}
