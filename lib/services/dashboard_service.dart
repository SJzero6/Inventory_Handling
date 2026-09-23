import '../core/network/api_client.dart';
import '../models/dashboard_model.dart';

class DashboardService {
  final ApiClient apiClient;

  DashboardService(this.apiClient);

  Future<DashboardModel> getDashboard(String token) async {
    final response = await apiClient.get('/dashboard', token: token);

    return DashboardModel.fromJson(response);
  }
}
