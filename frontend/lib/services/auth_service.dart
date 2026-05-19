import '../auth/jwt_claims.dart';
import 'api_client.dart';
import 'booking_service.dart';
import 'vehicle_service.dart';

class AuthService {
  AuthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  static const _expiryBuffer = Duration(minutes: 2);

  Future<String> exchangeToken({
    required String provider,
    required String code,
    required String codeVerifier,
    String? redirectUri,
  }) async {
    final body = <String, dynamic>{
      'provider': provider,
      'code': code,
      'codeVerifier': codeVerifier,
      if (redirectUri != null && redirectUri.isNotEmpty) 'redirectUri': redirectUri,
    };

    final response = await _apiClient.post(
      '/auth/token',
      authenticated: false,
      body: body,
    );

    return _persistAuthResponse(response);
  }

  Future<String> refreshSession() async {
    final refreshToken = await _apiClient.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw ApiException(401, 'No saved sign-in session. Please sign in with Microsoft again.');
    }

    final response = await _apiClient.post(
      '/auth/refresh',
      authenticated: false,
      body: <String, dynamic>{
        'provider': 'microsoft',
        'refreshToken': refreshToken,
      },
    );

    return _persistAuthResponse(response, previousRefreshToken: refreshToken);
  }

  /// Returns true when a stored session is still valid or was refreshed silently.
  Future<bool> tryRestoreSession() async {
    if (await _hasValidAccessToken()) return true;

    try {
      await refreshSession();
      return true;
    } on ApiException {
      await logout();
      return false;
    }
  }

  Future<bool> _hasValidAccessToken() async {
    final token = await _apiClient.getToken();
    if (token == null || token.isEmpty) return false;

    final expiresAt = await _apiClient.getTokenExpiresAt();
    if (expiresAt == null) return true;

    return DateTime.now().toUtc().isBefore(expiresAt.subtract(_expiryBuffer));
  }

  Future<String> _persistAuthResponse(
    dynamic response, {
    String? previousRefreshToken,
  }) async {
    if (response is! Map<String, dynamic>) {
      throw ApiException(500, 'Unexpected auth response from server.');
    }

    final accessToken = response['accessToken']?.toString();
    if (accessToken == null || accessToken.isEmpty) {
      throw ApiException(500, 'Auth response did not include accessToken.');
    }

    final refreshToken = response['refreshToken']?.toString();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _apiClient.saveRefreshToken(refreshToken);
    } else if (previousRefreshToken != null && previousRefreshToken.isNotEmpty) {
      await _apiClient.saveRefreshToken(previousRefreshToken);
    }

    final expiresIn = response['expiresIn'];
    if (expiresIn is int && expiresIn > 0) {
      final expiresAt = DateTime.now().toUtc().add(Duration(seconds: expiresIn));
      await _apiClient.saveTokenExpiresAt(expiresAt);
    }

    await _apiClient.saveToken(accessToken);

    final idToken = response['idToken']?.toString();
    if (idToken != null && idToken.isNotEmpty) {
      await _apiClient.saveIdToken(idToken);
    }

    await _persistMicrosoftProfile(
      apiDisplayName: response['displayName']?.toString(),
      apiFullName: response['fullName']?.toString(),
      apiEmail: response['email']?.toString(),
      idToken: idToken,
      accessToken: accessToken,
    );

    return accessToken;
  }

  /// Fills stored Microsoft profile from id_token when missing (e.g. old session).
  Future<void> ensureMicrosoftProfile() async {
    final hasName = (await _apiClient.getFullName())?.isNotEmpty == true
        || (await _apiClient.getDisplayName())?.isNotEmpty == true;
    final hasEmail = (await _apiClient.getUserEmail())?.isNotEmpty == true;
    if (hasName && hasEmail) return;

    final idToken = await _apiClient.getIdToken();
    final accessToken = await _apiClient.getToken();
    await _persistMicrosoftProfile(idToken: idToken, accessToken: accessToken);
  }

  @Deprecated('Use ensureMicrosoftProfile')
  Future<void> ensureDisplayName() => ensureMicrosoftProfile();

  Future<void> _persistMicrosoftProfile({
    String? apiDisplayName,
    String? apiFullName,
    String? apiEmail,
    String? idToken,
    String? accessToken,
  }) async {
    final displayName = _firstNonEmpty([
      apiDisplayName,
      displayNameFromJwt(idToken),
      displayNameFromJwt(accessToken),
    ]);

    final fullName = _firstNonEmpty([
      apiFullName,
      fullNameFromJwt(idToken),
      fullNameFromJwt(accessToken),
      displayName,
    ]);

    final email = _firstNonEmpty([
      apiEmail,
      emailFromJwt(idToken),
      emailFromJwt(accessToken),
    ]);

    if (displayName != null) await _apiClient.saveDisplayName(displayName);
    if (fullName != null) await _apiClient.saveFullName(fullName);
    if (email != null) await _apiClient.saveUserEmail(email);
  }

  String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    }
    return null;
  }

  Future<String?> getDisplayName() async {
    await ensureMicrosoftProfile();
    return _apiClient.getDisplayName();
  }

  Future<String?> getFullName() async {
    await ensureMicrosoftProfile();
    final full = await _apiClient.getFullName();
    if (full != null && full.isNotEmpty) return full;
    return _apiClient.getDisplayName();
  }

  Future<String?> getEmail() async {
    await ensureMicrosoftProfile();
    return _apiClient.getUserEmail();
  }

  Future<void> logout() async {
    await _apiClient.clearToken();
    await VehicleService().clearRegisteredVehicles();
    await BookingService().clearSessions();
  }

  Future<bool> isLoggedIn() async {
    if (await _hasValidAccessToken()) return true;
    final refresh = await _apiClient.getRefreshToken();
    return refresh != null && refresh.isNotEmpty;
  }
}
