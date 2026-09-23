import '../core/network/api_client.dart';
import '../models/product_model.dart';
import '../models/product_request.dart';

class ProductService {
  final ApiClient apiClient;

  ProductService(this.apiClient);

  Future<List<ProductModel>> getProducts({required String token}) async {
    final response = await apiClient.get('/products/', token: token);

    final List data = response['data'] ?? [];

    return data.map((item) => ProductModel.fromJson(item)).toList();
  }

  Future<ProductModel> getProductById({
    required int id,
    required String token,
  }) async {
    final response = await apiClient.get('/products/$id', token: token);

    final List data = response['data'] ?? [];

    final product = data.where((item) => item['Id'] == id).toList();

    if (product.isEmpty) {
      throw Exception('Product not found');
    }

    return ProductModel.fromJson(product.first);
  }

  Future<void> createProduct({
    required ProductRequest request,
    required String token,
  }) async {
    await apiClient.post('/products/', body: request.toJson(), token: token);
  }

  Future<void> updateProduct({
    required int id,
    required ProductRequest request,
    required String token,
  }) async {
    await apiClient.put('/products/$id', body: request.toJson(), token: token);
  }

  Future<void> deleteProduct({required int id, required String token}) async {
    await apiClient.delete('/products/$id', token: token);
  }
}
