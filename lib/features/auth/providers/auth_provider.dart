import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../../users/services/user_service.dart';

class AuthProvider with ChangeNotifier {
  final _authService = AuthService();
  final _userService = UserService();
  bool _isAuthenticated = false;
  String? _lastError;
  Map<String, dynamic>? _currentUser;

  bool get isAuthenticated => _isAuthenticated;
  String? get lastError => _lastError;
  Map<String, dynamic>? get currentUser => _currentUser;

  Future<bool> login(String email, String password) async {
    _lastError = null;
    final success = await _authService.login(email, password);
    _isAuthenticated = success;
    
    if (success) {
      // Cargar datos del usuario después del login exitoso
      await _loadCurrentUser();
    } else {
      _lastError = 'Invalid credentials';
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
    _currentUser = null;
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

  /// Carga los datos del usuario actual desde el storage
  Future<void> _loadCurrentUser() async {
    try {
      _currentUser = await _authService.getUserData();
    } catch (e) {
      _currentUser = null;
    }
  }

  /// Inicializa el estado de autenticación al arrancar la app
  Future<void> initializeAuth() async {
    final isLoggedIn = await _authService.isUserLoggedIn();
    _isAuthenticated = isLoggedIn;
    
    if (isLoggedIn) {
      await _loadCurrentUser();
    }
    
    notifyListeners();
  }

  /// Obtiene el nombre completo del usuario actual
  String? get userFullName {
    if (_currentUser == null) return null;
    final name = _currentUser!["nombre"] ?? "";
    final lastname = _currentUser!["apellidos"] ?? "";
    return "$name $lastname".trim();
  }

  /// Obtiene el email del usuario actual
  String? get userEmail {
    return _currentUser?["email"];
  }

  /// Obtiene los roles del usuario actual
  List<String> get userRoles {
    if (_currentUser == null) return [];
    final roles = _currentUser!["roles"];
    if (roles is List) {
      return roles.cast<String>();
    }
    return [];
  }

  /// Verifica si el usuario tiene un rol específico
  bool hasRole(String role) {
    return userRoles.contains(role);
  }

  /// Verifica si el usuario es administrador
  bool get isAdmin {
    return hasRole('admin');
  }

  /// Verifica si el usuario es vendedor
  bool get isVendedor {
    return hasRole('vendedor');
  }

  /// Actualiza los datos del usuario actual
  Future<void> updateCurrentUser() async {
    await _loadCurrentUser();
    notifyListeners();
  }
}
