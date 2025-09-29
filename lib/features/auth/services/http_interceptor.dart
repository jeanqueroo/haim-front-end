import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'session_manager.dart';

class HttpInterceptor {
  static final HttpInterceptor _instance = HttpInterceptor._internal();
  factory HttpInterceptor() => _instance;
  HttpInterceptor._internal();

  final AuthService _authService = AuthService();
  final SessionManager _sessionManager = SessionManager();

  /// Intercepta las peticiones HTTP y maneja el refresh automático de tokens
  Future<http.Response> interceptRequest(
    Future<http.Response> Function() request, {
    BuildContext? context,
  }) async {
    try {
      // Realizar la petición original
      final response = await request();
      
      // Si la respuesta es 401 (Unauthorized), intentar refresh del token
      if (response.statusCode == 401) {
        final refreshed = await _sessionManager.attemptTokenRefresh(context!);
        
        if (refreshed) {
          // Si el refresh fue exitoso, reintentar la petición original
          return await request();
        } else {
          // Si el refresh falló, la sesión ya fue manejada por SessionManager
          return response; // Devolver la respuesta original 401
        }
      }
      
      return response;
    } catch (e) {
      // Si hay un error de conexión, también intentar refresh
      if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        final refreshed = await _sessionManager.attemptTokenRefresh(context!);
        
        if (refreshed) {
          try {
            return await request();
          } catch (retryError) {
            // Si el reintento también falla, devolver el error original
            throw e;
          }
        } else {
          // La sesión ya fue manejada por SessionManager
          throw e;
        }
      }
      
      throw e;
    }
  }

  /// Método helper para hacer peticiones GET con interceptación
  Future<http.Response> get(String url, {Map<String, String>? headers, BuildContext? context}) async {
    return await interceptRequest(() async {
      final authHeaders = await _getAuthHeaders();
      final mergedHeaders = {...?headers, ...authHeaders};
      return await http.get(Uri.parse(url), headers: mergedHeaders);
    }, context: context);
  }

  /// Método helper para hacer peticiones POST con interceptación
  Future<http.Response> post(String url, {Map<String, String>? headers, Object? body, BuildContext? context}) async {
    return await interceptRequest(() async {
      final authHeaders = await _getAuthHeaders();
      final mergedHeaders = {...?headers, ...authHeaders};
      return await http.post(
        Uri.parse(url), 
        headers: mergedHeaders,
        body: body,
      );
    }, context: context);
  }

  /// Método helper para hacer peticiones PUT con interceptación
  Future<http.Response> put(String url, {Map<String, String>? headers, Object? body, BuildContext? context}) async {
    return await interceptRequest(() async {
      final authHeaders = await _getAuthHeaders();
      final mergedHeaders = {...?headers, ...authHeaders};
      return await http.put(
        Uri.parse(url), 
        headers: mergedHeaders,
        body: body,
      );
    }, context: context);
  }

  /// Método helper para hacer peticiones DELETE con interceptación
  Future<http.Response> delete(String url, {Map<String, String>? headers, BuildContext? context}) async {
    return await interceptRequest(() async {
      final authHeaders = await _getAuthHeaders();
      final mergedHeaders = {...?headers, ...authHeaders};
      return await http.delete(Uri.parse(url), headers: mergedHeaders);
    }, context: context);
  }

  /// Obtiene los headers de autenticación con el token actual
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _authService.getAccessToken();
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }
}
