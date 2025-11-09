import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _username;

  bool get isAuthenticated => _isAuthenticated;
  String? get username => _username;

  Future<bool> login(String username, String password) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // Simple validation - in a real app, this would call an API
    if (username.isNotEmpty && password.isNotEmpty) {
      _isAuthenticated = true;
      _username = username;
      notifyListeners();
      return true;
    }

    return false;
  }

  void logout() {
    _isAuthenticated = false;
    _username = null;
    notifyListeners();
  }
}
