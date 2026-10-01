import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'resource_controller.dart';

class UserController extends ChangeNotifier {
  final ApiService _apiService;
  final ResourceController<List<User>> usersResource = ResourceController<List<User>>();
  final Map<int, User> _userCache = {};

  UserController({ApiService? apiService})
      : _apiService = apiService ?? ApiService() {
    usersResource.addListener(notifyListeners);
  }

  Map<int, User> get userCache => Map.unmodifiable(_userCache);
  List<User> get users => usersResource.data ?? const [];

  Future<void> loadUsers({bool forceRefresh = false}) async {
    if (!forceRefresh && usersResource.hasData && usersResource.data!.isNotEmpty) {
      return;
    }

    final result = await usersResource.execute(() async {
      final list = await _apiService.getUsers();
      for (final user in list) {
        _userCache[user.id] = user;
      }
      return list;
    });

    if (result != null) {
      notifyListeners();
    }
  }

  User? getUserById(int id) {
    return _userCache[id];
  }

  Future<User?> fetchUserById(int id) async {
    if (_userCache.containsKey(id)) {
      return _userCache[id];
    }
    try {
      final user = await _apiService.getUser(id);
      _userCache[user.id] = user;
      notifyListeners();
      return user;
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    usersResource.removeListener(notifyListeners);
    usersResource.dispose();
    super.dispose();
  }
}
