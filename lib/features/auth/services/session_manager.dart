import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'auth_notification_service.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  final AuthService _authService = AuthService();
  final AuthNotificationService _authNotificationService = AuthNotificationService();
  
  bool _isSessionValid = true;
  bool _isCheckingSession = false;

  /// Verifica si la sesión es válida
  Future<bool> isSessionValid() async {
    if (_isCheckingSession) return _isSessionValid;
    
    _isCheckingSession = true;
    
    try {
      final token = await _authService.getAccessToken();
      if (token == null || token.isEmpty) {
        _isSessionValid = false;
        return false;
      }

      // Verificar si el token está expirado haciendo una petición de prueba
      final isValid = await _verifyTokenValidity();
      _isSessionValid = isValid;
      
      return isValid;
    } catch (e) {
      _isSessionValid = false;
      return false;
    } finally {
      _isCheckingSession = false;
    }
  }

  /// Verifica la validez del token haciendo una petición al servidor
  Future<bool> _verifyTokenValidity() async {
    try {
      final response = await _authService.verifyToken();
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Maneja la expiración de sesión
  Future<void> handleSessionExpired(BuildContext context) async {
    if (!_isSessionValid) return; // Evitar múltiples llamadas
    
    _isSessionValid = false;
    
    // Mostrar notificación
    await _authNotificationService.handleTokenRefreshFailure(context);
  }

  /// Intenta refrescar el token y maneja el resultado
  Future<bool> attemptTokenRefresh(BuildContext context) async {
    try {
      final refreshed = await _authService.refreshToken();
      
      if (refreshed) {
        _isSessionValid = true;
        return true;
      } else {
        await handleSessionExpired(context);
        return false;
      }
    } catch (e) {
      await handleSessionExpired(context);
      return false;
    }
  }

  /// Resetea el estado de la sesión
  void resetSessionState() {
    _isSessionValid = true;
    _isCheckingSession = false;
  }

  /// Verifica la sesión y redirige si es necesario
  Future<bool> checkSessionAndRedirect(BuildContext context) async {
    final isValid = await isSessionValid();
    
    if (!isValid) {
      await handleSessionExpired(context);
      return false;
    }
    
    return true;
  }
}
