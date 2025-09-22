import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../../users/services/user_service.dart';

class AuthProvider with ChangeNotifier {
  final _authService = AuthService();
  final _userService = UserService();
  bool _isAuthenticated = false;
  String? _lastError;

  bool get isAuthenticated => _isAuthenticated;
  String? get lastError => _lastError;

  Future<bool> login(String email, String password) async {
    _lastError = null;
    final success = await _authService.login(email, password);
    _isAuthenticated = success;
    if (!success) {
      _lastError = 'Credenciales inválidas';
    }
    notifyListeners();
    return success;
  }

  Future<bool> signup(String email, String password) async {
    return await _authService.signup(email, password);
  }

  Future<bool> registerUser({
    required String firstName,
    required String lastName,
    required String address,
    required String country,
    required int age,
    required String gender,
    required List<String> roles,
    required String email,
    required String password,
  }) async {
    _lastError = null;
    
    final result = await _userService.registerUser(
      firstName: firstName,
      lastName: lastName,
      address: address,
      country: country,
      age: age,
      gender: gender,
      roles: roles,
      email: email,
      password: password,
    );
    
    if (!result.isSuccess) {
      _lastError = result.message;
    }
    
    notifyListeners();
    return result.isSuccess;
  }

  /// Registra un usuario y retorna el resultado detallado
  Future<UserRegistrationResult> registerUserDetailed({
    required String firstName,
    required String lastName,
    required String address,
    required String country,
    required int age,
    required String gender,
    required List<String> roles,
    required String email,
    required String password,
  }) async {
    _lastError = null;
    
    final result = await _userService.registerUser(
      firstName: firstName,
      lastName: lastName,
      address: address,
      country: country,
      age: age,
      gender: gender,
      roles: roles,
      email: email,
      password: password,
    );
    
    if (!result.isSuccess) {
      _lastError = result.message;
    }
    
    notifyListeners();
    return result;
  }

  /// Verifica si un email está disponible
  Future<bool> isEmailAvailable(String email) async {
    return await _userService.isEmailAvailable(email);
  }

  /// Obtiene información de un usuario por ID
  Future<UserInfo?> getUserById(String userId) async {
    return await _userService.getUserById(userId);
  }

  void logout() async {
    await _authService.logout();
    _isAuthenticated = false;
    _lastError = null;
    notifyListeners();
  }

  Future<bool> refreshToken() async {
    _lastError = null;
    final success = await _authService.refreshToken();
    _isAuthenticated = success;
    if (!success) {
      _lastError = 'No se pudo renovar el token';
    }
    notifyListeners();
    return success;
  }

  /// Limpia el último error
  void clearError() {
    _lastError = null;
    notifyListeners();
  }
}
