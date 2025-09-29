import 'package:flutter/material.dart';
import 'auth_service.dart';

class AuthNotificationService {
  static final AuthNotificationService _instance = AuthNotificationService._internal();
  factory AuthNotificationService() => _instance;
  AuthNotificationService._internal();

  final AuthService _authService = AuthService();

  /// Muestra una notificación de sesión expirada y redirige al login
  void showSessionExpiredNotification(BuildContext context) {
    // Mostrar SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Tu sesión ha expirado. Por favor, inicia sesión nuevamente.'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Entendido',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );

    // Redirigir al login después de un breve delay
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    });
  }

  /// Maneja el logout automático cuando el refresh del token falla
  Future<void> handleTokenRefreshFailure(BuildContext context) async {
    await _authService.logout();
    showSessionExpiredNotification(context);
  }

  /// Verifica si el usuario está autenticado y maneja la expiración del token
  Future<bool> checkAuthStatus(BuildContext context) async {
    final isLoggedIn = await _authService.isUserLoggedIn();
    
    if (!isLoggedIn) {
      // Si no está logueado, redirigir al login
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
      return false;
    }
    
    return true;
  }
}
