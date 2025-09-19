import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final _authService = AuthService();
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Future<bool> login(String email, String password) async {
    final success = await _authService.login(email, password);
    _isAuthenticated = success;
    notifyListeners();
    return success;
  }

  Future<bool> signup(String email, String password) async {
    return await _authService.signup(email, password);
  }

  void logout() async {
    await _authService.logout();
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<bool> refreshToken() async {
    final success = await _authService.refreshToken();
    _isAuthenticated = success;
    notifyListeners();
    return success;
  }
}
