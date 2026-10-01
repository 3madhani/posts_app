import 'package:flutter_test/flutter_test.dart';
import 'package:posts_app/controllers/auth_controller.dart';
import 'package:posts_app/controllers/resource_controller.dart';
import 'package:posts_app/models/user.dart';
import 'package:posts_app/services/api_exception.dart';
import 'package:posts_app/services/api_service.dart';

class FakeApiService extends ApiService {
  final List<User> mockUsers;
  final bool shouldThrow;

  FakeApiService({
    this.mockUsers = const [],
    this.shouldThrow = false,
  });

  @override
  Future<List<User>> getUsers() async {
    if (shouldThrow) {
      throw ApiException.network('Connection error');
    }
    return mockUsers;
  }
}

void main() {
  group('AuthController Tests', () {
    const testUser1 = User(
      id: 1,
      name: 'Leanne Graham',
      username: 'Bret',
      email: 'Sincere@april.biz',
      phone: '1-770-736-8031',
      website: 'hildegard.org',
    );

    const testUser2 = User(
      id: 2,
      name: 'Ervin Howell',
      username: 'Antonette',
      email: 'Shanna@melissa.tv',
      phone: '010-692-6593',
      website: 'anastasia.net',
    );

    final mockUsersList = [testUser1, testUser2];

    test('Initial state is unauthenticated and idle', () {
      final authController = AuthController(
        apiService: FakeApiService(mockUsers: mockUsersList),
      );

      expect(authController.currentUser, isNull);
      expect(authController.isAuthenticated, isFalse);
      expect(authController.isLoading, isFalse);
      expect(authController.errorMessage, isNull);
      expect(authController.authResource.status, ResourceStatus.initial);

      authController.dispose();
    });

    test('Login with empty username returns false and sets validation error', () async {
      final authController = AuthController(
        apiService: FakeApiService(mockUsers: mockUsersList),
      );

      final result = await authController.login('');

      expect(result, isFalse);
      expect(authController.isAuthenticated, isFalse);
      expect(authController.currentUser, isNull);
      expect(authController.errorMessage, 'Please enter a username or email');
      expect(authController.authResource.status, ResourceStatus.error);

      authController.dispose();
    });

    test('Login with whitespace-only input returns false and sets validation error', () async {
      final authController = AuthController(
        apiService: FakeApiService(mockUsers: mockUsersList),
      );

      final result = await authController.login('   ');

      expect(result, isFalse);
      expect(authController.isAuthenticated, isFalse);
      expect(authController.errorMessage, 'Please enter a username or email');

      authController.dispose();
    });

    test('Login with valid username succeeds and updates currentUser', () async {
      final authController = AuthController(
        apiService: FakeApiService(mockUsers: mockUsersList),
      );

      final result = await authController.login('Bret');

      expect(result, isTrue);
      expect(authController.isAuthenticated, isTrue);
      expect(authController.currentUser, equals(testUser1));
      expect(authController.errorMessage, isNull);
      expect(authController.authResource.status, ResourceStatus.success);

      authController.dispose();
    });

    test('Login is case-insensitive for username', () async {
      final authController = AuthController(
        apiService: FakeApiService(mockUsers: mockUsersList),
      );

      final result = await authController.login('bReT');

      expect(result, isTrue);
      expect(authController.isAuthenticated, isTrue);
      expect(authController.currentUser?.username, 'Bret');

      authController.dispose();
    });

    test('Login with valid email succeeds and updates currentUser', () async {
      final authController = AuthController(
        apiService: FakeApiService(mockUsers: mockUsersList),
      );

      final result = await authController.login('Shanna@melissa.tv');

      expect(result, isTrue);
      expect(authController.isAuthenticated, isTrue);
      expect(authController.currentUser, equals(testUser2));

      authController.dispose();
    });

    test('Login with unknown username/email returns false and sets error', () async {
      final authController = AuthController(
        apiService: FakeApiService(mockUsers: mockUsersList),
      );

      final result = await authController.login('nonexistent_user');

      expect(result, isFalse);
      expect(authController.isAuthenticated, isFalse);
      expect(authController.currentUser, isNull);
      expect(authController.errorMessage, contains('No user found matching'));
      expect(authController.authResource.status, ResourceStatus.error);

      authController.dispose();
    });

    test('Login handles ApiService exception properly', () async {
      final authController = AuthController(
        apiService: FakeApiService(shouldThrow: true),
      );

      final result = await authController.login('Bret');

      expect(result, isFalse);
      expect(authController.isAuthenticated, isFalse);
      expect(authController.currentUser, isNull);
      expect(authController.errorMessage, isNotNull);
      expect(authController.authResource.status, ResourceStatus.error);

      authController.dispose();
    });

    test('Logout clears currentUser and resets authResource', () async {
      final authController = AuthController(
        apiService: FakeApiService(mockUsers: mockUsersList),
      );

      // Log in first
      await authController.login('Bret');
      expect(authController.isAuthenticated, isTrue);

      // Log out
      authController.logout();
      expect(authController.isAuthenticated, isFalse);
      expect(authController.currentUser, isNull);
      expect(authController.authResource.status, ResourceStatus.initial);

      authController.dispose();
    });

    test('setCurrentUser updates currentUser and status directly', () {
      final authController = AuthController(
        apiService: FakeApiService(mockUsers: mockUsersList),
      );

      authController.setCurrentUser(testUser1);

      expect(authController.isAuthenticated, isTrue);
      expect(authController.currentUser, equals(testUser1));
      expect(authController.authResource.status, ResourceStatus.success);

      authController.dispose();
    });
  });
}
