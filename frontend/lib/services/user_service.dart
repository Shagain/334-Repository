import 'auth_service.dart';
import '../models/user.dart';

class UserService {
  UserService({AuthService? authService}) : _authService = authService ?? AuthService();

  final AuthService _authService;

  static const bool useRealApi = false;

  Future<User> getCurrentUser() async {
    await _authService.ensureMicrosoftProfile();

    final name = await _authService.getFullName() ?? '';
    final email = await _authService.getEmail() ?? '';

    if (!useRealApi) {
      return User(
        name: name.isNotEmpty ? name : 'Signed in',
        email: email.isNotEmpty ? email : 'No email on Microsoft profile',
        role: 'Microsoft account',
      );
    }

    // REAL API MODE later
    // final response = await _apiClient.get('/users/me');
    // return User.fromJson(response);

    return User(
      name: name.isNotEmpty ? name : 'Signed in',
      email: email.isNotEmpty ? email : '',
      role: 'Microsoft account',
    );
  }
}
