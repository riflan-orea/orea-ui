import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Auth State class
class AuthState {
  final bool isAuthenticated;
  final String? username;
  final bool isLoading;

  const AuthState({
    this.isAuthenticated = false,
    this.username,
    this.isLoading = true,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? username,
    bool? isLoading,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      username: username ?? this.username,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  static const String _keyIsAuthenticated = 'isAuthenticated';
  static const String _keyUsername = 'username';

  AuthNotifier() : super(const AuthState(isLoading: true)) {
    _loadAuthState();
  }

  // Load auth state from SharedPreferences on initialization
  Future<void> _loadAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isAuthenticated = prefs.getBool(_keyIsAuthenticated) ?? false;
      final username = prefs.getString(_keyUsername);

      state = AuthState(
        isAuthenticated: isAuthenticated,
        username: username,
        isLoading: false,
      );
    } catch (e) {
      state = const AuthState(isAuthenticated: false, isLoading: false);
    }
  }

  Future<bool> login(String username, String password) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // Simple validation - in a real app, this would call an API
    if (username.isNotEmpty && password.isNotEmpty) {
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsAuthenticated, true);
      await prefs.setString(_keyUsername, username);

      state = AuthState(
        isAuthenticated: true,
        username: username,
        isLoading: false,
      );
      return true;
    }

    return false;
  }

  Future<void> logout() async {
    // Clear from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsAuthenticated);
    await prefs.remove(_keyUsername);

    state = const AuthState(
      isAuthenticated: false,
      username: null,
      isLoading: false,
    );
  }
}

// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
