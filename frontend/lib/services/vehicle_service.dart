import 'api_client.dart';

class VehicleService {
  VehicleService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<dynamic>> getVehicles() async {
    final response = await _apiClient.get('/vehicles');
    return response is List ? response : <dynamic>[];
  }

  Future<void> registerVehicle({required String licensePlate}) async {
    await _apiClient.post(
      '/vehicles',
      body: {'licensePlate': licensePlate},
    );
  }
}
