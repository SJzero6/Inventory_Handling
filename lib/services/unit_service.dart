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
}
