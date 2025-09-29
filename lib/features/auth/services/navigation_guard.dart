import 'package:flutter/material.dart';
import 'session_manager.dart';
import 'auth_service.dart';

class NavigationGuard {
  static final NavigationGuard _instance = NavigationGuard._internal();
  factory NavigationGuard() => _instance;
  NavigationGuard._internal();

  final SessionManager _sessionManager = SessionManager();
  final AuthService _authService = AuthService();
  
  /// Rutas que no requieren autenticación
  final List<String> _publicRoutes = [
    '/login',
    '/register',
    '/welcome',
    '/',
  ];

  /// Verifica si una ruta requiere autenticación
  bool isPublicRoute(String routeName) {
    return _publicRoutes.contains(routeName);
  }

  /// Intercepta la navegación y verifica la sesión
  Future<bool> canNavigate(BuildContext context, String routeName) async {
    // Si es una ruta pública, permitir navegación
    if (isPublicRoute(routeName)) {
      return true;
    }

    // Verificar si hay un usuario logueado
    final isLoggedIn = await _authService.isUserLoggedIn();
    if (!isLoggedIn) {
      _redirectToLogin(context);
      return false;
    }

    // Verificar si la sesión es válida
    final isSessionValid = await _sessionManager.isSessionValid();
    if (!isSessionValid) {
      await _sessionManager.handleSessionExpired(context);
      return false;
    }

    return true;
  }

  /// Redirige al login
  void _redirectToLogin(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    });
  }

  /// Verifica la sesión periódicamente
  void startPeriodicSessionCheck(BuildContext context) {
    // Verificar sesión cada 5 minutos
    Future.delayed(const Duration(minutes: 5), () {
      if (context.mounted) {
        _checkSessionPeriodically(context);
      }
    });
  }

  Future<void> _checkSessionPeriodically(BuildContext context) async {
    final isLoggedIn = await _authService.isUserLoggedIn();
    if (!isLoggedIn) {
      _redirectToLogin(context);
      return;
    }

    final isSessionValid = await _sessionManager.isSessionValid();
    if (!isSessionValid) {
      await _sessionManager.handleSessionExpired(context);
      return;
    }

    // Programar la siguiente verificación
    startPeriodicSessionCheck(context);
  }
}
