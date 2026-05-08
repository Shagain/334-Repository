import 'api_client.dart';

class BookingService {
  BookingService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<dynamic>> getBookings({String? status}) async {
    final response = await _apiClient.get(
      '/bookings',
      queryParameters: status == null ? null : {'status': status},
    );
    return response is List ? response : <dynamic>[];
  }

  Future<void> createBooking({
    required DateTime startTime,
    required DateTime endTime,
    required int spotId,
    required int vehicleId,
  }) async {
    // NOTE: Your Swagger currently requires userID here. With bearer auth,
    // the backend should ideally derive userID from the token instead.
    await _apiClient.post(
      '/bookings',
      body: {
        'startTime': startTime.toUtc().toIso8601String(),
        'endTime': endTime.toUtc().toIso8601String(),
        'spotID': spotId,
        'vehicleID': vehicleId,
      },
    );
  }
}
