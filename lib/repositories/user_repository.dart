import '../models/user.dart';
import '../services/dio_service.dart';

/// User Repository
/// Handles all user-related API calls
/// Separates business logic from UI
class UserRepository {
  final DioService _dioService;

  UserRepository({DioService? dioService})
      : _dioService = dioService ?? DioService();

  /// Fetch all users
  Future<List<User>> getUsers() async {
    try {
      final response = await _dioService.get('/users');

      if (response.data is List) {
        return (response.data as List).map((json) => User.fromJson(json)).toList();
      }

      throw Exception('Invalid response format');
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch single user by ID
  Future<User> getUserById(int id) async {
    try {
      final response = await _dioService.get('/users/$id');
      return User.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Create new user
  Future<User> createUser(User user) async {
    try {
      final response = await _dioService.post('/users', data: user.toJson());
      return User.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update user
  Future<User> updateUser(int id, User user) async {
    try {
      final response = await _dioService.put('/users/$id', data: user.toJson());
      return User.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete user
  Future<void> deleteUser(int id) async {
    try {
      await _dioService.delete('/users/$id');
    } catch (e) {
      rethrow;
    }
  }

  /// Search users (simulated - API doesn't support this)
  Future<List<User>> searchUsers(String query) async {
    try {
      final users = await getUsers();
      return users.where((user) {
        final searchLower = query.toLowerCase();
        return user.name.toLowerCase().contains(searchLower) ||
            user.email.toLowerCase().contains(searchLower) ||
            user.company.name.toLowerCase().contains(searchLower);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
}
