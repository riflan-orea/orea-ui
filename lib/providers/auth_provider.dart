import 'package:flutter_riverpod/flutter_riverpod.dart';

// Auth State class
class AuthState {
  final bool isAuthenticated;
  final String? username;

  const AuthState({
    this.isAuthenticated = false,
    this.username,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? username,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      username: username ?? this.username,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<bool> login(String username, String password) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // Simple validation - in a real app, this would call an API
    if (username.isNotEmpty && password.isNotEmpty) {
      state = AuthState(
        isAuthenticated: true,
        username: username,
      );
      return true;
    }

    return false;
  }

  void logout() {
    state = const AuthState(
      isAuthenticated: false,
      username: null,
    );
  }
}

// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
