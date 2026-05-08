import 'api_client.dart';

class UserService {
  UserService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await _apiClient.get('/users/me');
    return response is Map<String, dynamic> ? response : <String, dynamic>{};
  }
}
