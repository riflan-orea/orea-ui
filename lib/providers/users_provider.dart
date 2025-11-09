import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../repositories/user_repository.dart';
import '../services/dio_service.dart';

/// Provider for UserRepository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

/// Users State
class UsersState {
  final List<User> users;
  final bool isLoading;
  final String? errorMessage;

  const UsersState({
    this.users = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  UsersState copyWith({
    List<User>? users,
    bool? isLoading,
    String? errorMessage,
  }) {
    return UsersState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Users Notifier
class UsersNotifier extends StateNotifier<UsersState> {
  final UserRepository _repository;

  UsersNotifier(this._repository) : super(const UsersState());

  /// Fetch all users
  Future<void> fetchUsers() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final users = await _repository.getUsers();
      state = state.copyWith(
        users: users,
        isLoading: false,
      );
    } on NetworkException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Network error: ${e.message}',
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'API error: ${e.message}',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unexpected error: $e',
      );
    }
  }

  /// Create user
  Future<bool> createUser(User user) async {
    try {
      final newUser = await _repository.createUser(user);
      state = state.copyWith(
        users: [...state.users, newUser],
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to create user: $e');
      return false;
    }
  }

  /// Update user
  Future<bool> updateUser(int id, User user) async {
    try {
      final updatedUser = await _repository.updateUser(id, user);
      final updatedUsers = state.users.map((u) {
        return u.id == id ? updatedUser : u;
      }).toList();

      state = state.copyWith(users: updatedUsers);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to update user: $e');
      return false;
    }
  }

  /// Delete user
  Future<bool> deleteUser(int id) async {
    try {
      await _repository.deleteUser(id);
      final updatedUsers = state.users.where((u) => u.id != id).toList();
      state = state.copyWith(users: updatedUsers);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to delete user: $e');
      return false;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Users Provider
final usersProvider = StateNotifierProvider<UsersNotifier, UsersState>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UsersNotifier(repository);
});

/// Filtered Users Provider (for search)
final filteredUsersProvider = Provider.family<List<User>, String>((ref, query) {
  final usersState = ref.watch(usersProvider);

  if (query.isEmpty) {
    return usersState.users;
  }

  final searchLower = query.toLowerCase();
  return usersState.users.where((user) {
    return user.name.toLowerCase().contains(searchLower) ||
        user.email.toLowerCase().contains(searchLower) ||
        user.company.name.toLowerCase().contains(searchLower);
  }).toList();
});

/// Single User Provider (by ID)
final userByIdProvider = Provider.family<User?, int>((ref, id) {
  final usersState = ref.watch(usersProvider);
  try {
    return usersState.users.firstWhere((user) => user.id == id);
  } catch (e) {
    return null;
  }
});
