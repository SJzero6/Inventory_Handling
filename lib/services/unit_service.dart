import '../core/network/api_client.dart';
import '../models/unit_model.dart';

class UnitService {
  final ApiClient apiClient;

  UnitService(this.apiClient);

  Future<List<UnitModel>> getUnits({required String token}) async {
    final response = await apiClient.get('/units/', token: token);

    final List data = response['data'] ?? [];

    return data
        .map((item) => UnitModel.fromJson(item))
        .where((unit) => unit.isActive)
        .toList();
  }

  Future<void> createUnit({
    required String name,
    required String shortName,
    required String token,
  }) async {
    await apiClient.post(
      '/units/',
      body: {'name': name, 'shortName': shortName},
      token: token,
    );
  }

  Future<void> updateUnit({
    required int id,
    required String name,
    required String shortName,
    required String token,
  }) async {
    await apiClient.put(
      '/units/$id',
      body: {'name': name, 'shortName': shortName},
      token: token,
    );
  }

  Future<void> deleteUnit({required int id, required String token}) async {
    await apiClient.delete('/units/$id', token: token);
  }
}
