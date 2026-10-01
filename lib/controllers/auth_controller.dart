import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'resource_controller.dart';

class AuthController extends ChangeNotifier {
  final ApiService _apiService;
  final ResourceController<User?> authResource = ResourceController<User?>();

  User? _currentUser;

  AuthController({ApiService? apiService})
      : _apiService = apiService ?? ApiService() {
    authResource.addListener(notifyListeners);
  }

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => authResource.isLoading;
  String? get errorMessage => authResource.errorMessage;

  Future<bool> login(String usernameOrEmail) async {
    final query = usernameOrEmail.trim().toLowerCase();
    if (query.isEmpty) {
      authResource.setError('Please enter a username or email');
      notifyListeners();
      return false;
    }

    authResource.setLoading();
    try {
      final users = await _apiService.getUsers();
      final matchedUser = users.cast<User?>().firstWhere(
            (u) =>
                u != null &&
                (u.username.toLowerCase() == query ||
                    u.email.toLowerCase() == query),
            orElse: () => null,
          );

      if (matchedUser != null) {
        _currentUser = matchedUser;
        authResource.setData(matchedUser);
        notifyListeners();
        return true;
      } else {
        _currentUser = null;
        authResource.setError('No user found matching "$usernameOrEmail"');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _currentUser = null;
      authResource.setError(e.toString());
      notifyListeners();
      return false;
    }
  }

  void setCurrentUser(User user) {
    _currentUser = user;
    authResource.setData(user);
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    authResource.reset();
    notifyListeners();
  }

  @override
  void dispose() {
    authResource.removeListener(notifyListeners);
    authResource.dispose();
    super.dispose();
  }
}
