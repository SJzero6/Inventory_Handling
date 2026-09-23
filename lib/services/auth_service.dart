import '../core/network/api_client.dart';
import '../models/login_response.dart';

class AuthService {
  final ApiClient apiClient;

  AuthService(this.apiClient);

  Future<LoginResponse> login({
    required String username,
    required String password,
  }) async {
    final response = await apiClient.post(
      '/auth/login',
      body: {'username': username, 'password': password},
    );

    return LoginResponse.fromJson(response);
  }
}
