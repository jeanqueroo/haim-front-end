import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/services/http_interceptor.dart';

class StoreService {
  final String baseUrl = "http://10.0.2.2:3000";
  final AuthService _authService = AuthService();
  final HttpInterceptor _httpInterceptor = HttpInterceptor();

  /// Obtiene los headers de autenticación con el token
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _authService.getAccessToken();
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  /// Valida el formato de teléfono según el país
  bool _isValidPhoneForCountry(String phone, String country) {
    switch (country.toLowerCase()) {
      case 'spain':
      case 'es':
        // España: +34, 9 dígitos, puede tener espacios o guiones
        // Ejemplos: +34 123 456 789, +34123456789, 123 456 789
        final spainRegex = RegExp(r'^(\+34\s?)?[6-9]\d{2}\s?\d{3}\s?\d{3}$');
        return spainRegex.hasMatch(phone);
      
      case 'unitedstates':
      case 'us':
      case 'usa':
        // Estados Unidos: +1, 10 dígitos, puede tener espacios, guiones o paréntesis
        // Ejemplos: +1 (123) 456-7890, +1 123 456 7890, (123) 456-7890, 123-456-7890
        final usRegex = RegExp(r'^(\+1\s?)?(\([0-9]{3}\)\s?[0-9]{3}-[0-9]{4}|[0-9]{3}-[0-9]{3}-[0-9]{4}|[0-9]{3}\s[0-9]{3}\s[0-9]{4}|[0-9]{10})$');
        return usRegex.hasMatch(phone);
      
      default:
        // Para otros países, usar validación genérica
        final genericRegex = RegExp(r'^[\+]?[0-9\s\-\(\)]{10,}$');
        return genericRegex.hasMatch(phone);
    }
  }

  /// Obtiene el formato esperado de teléfono para un país
  String _getPhoneFormatForCountry(String country) {
    switch (country.toLowerCase()) {
      case 'spain':
      case 'es':
        return 'Ejemplo: +34 123 456 789 o 123 456 789';
      case 'unitedstates':
      case 'us':
      case 'usa':
        return 'Ejemplo: +1 (123) 456-7890 o (123) 456-7890';
      default:
        return 'Ejemplo: +1 234 567 8900';
    }
  }

  /// Registra una nueva tienda en el sistema
  /// 
  /// [name] - Nombre de la tienda
  /// [type] - Tipo de tienda
  /// [address] - Dirección de la tienda
  /// [country] - País de la tienda
  /// [phone] - Número de teléfono
  /// [responsibleUserId] - ID del usuario responsable
  /// 
  /// Retorna un [StoreRegistrationResult] con el resultado del registro
  Future<StoreRegistrationResult> registerStore({
    required String name,
    required String type,
    required String address,
    required String country,
    required String phone,
    required String responsibleUserId,
  }) async {
    try {
      // Validaciones básicas
      if (name.trim().isEmpty) {
        return StoreRegistrationResult.error('El nombre de la tienda es obligatorio');
      }
      if (type.trim().isEmpty) {
        return StoreRegistrationResult.error('El tipo de tienda es obligatorio');
      }
      if (address.trim().isEmpty) {
        return StoreRegistrationResult.error('La dirección es obligatoria');
      }
      if (country.trim().isEmpty) {
        return StoreRegistrationResult.error('El país es obligatorio');
      }
      if (phone.trim().isEmpty) {
        return StoreRegistrationResult.error('El número de teléfono es obligatorio');
      }
      if (responsibleUserId.trim().isEmpty) {
        return StoreRegistrationResult.error('El usuario responsable es obligatorio');
      }

      // Validar que el ID del usuario responsable sea un número válido
      final userId = int.tryParse(responsibleUserId.trim());
      if (userId == null) {
        return StoreRegistrationResult.error('El ID del usuario responsable no es válido');
      }

      // Validar formato de teléfono según el país
      if (!_isValidPhoneForCountry(phone.trim(), country.trim())) {
        final formatExample = _getPhoneFormatForCountry(country.trim());
        return StoreRegistrationResult.error('El formato del teléfono no es válido para el país seleccionado. $formatExample');
      }

      // Validar longitud mínima de la dirección
      if (address.trim().length < 10) {
        return StoreRegistrationResult.error('La dirección debe tener al menos 10 caracteres');
      }

      // Preparar datos para enviar
      final storeData = {
        "name": name.trim(),
        "storeType": type.trim(),
        "address": address.trim(),
        "country": country.trim(),
        "phone": phone.trim(),
        "userId": userId,
      };

      // Realizar petición HTTP
      final response = await http.post(
        Uri.parse("$baseUrl/stores"),
        headers: await _getAuthHeaders(),
        body: jsonEncode(storeData),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Tiempo de espera agotado. Verifica tu conexión a internet.');
        },
      );

      // Procesar respuesta
      if (response.statusCode == 201 || response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          return StoreRegistrationResult.success(
            message: 'Tienda registrada exitosamente',
            storeId: responseData['id']?.toString(),
            storeData: responseData,
          );
        } catch (e) {
          return StoreRegistrationResult.success(
            message: 'Tienda registrada exitosamente',
          );
        }
      } else {
        // Manejar errores específicos del servidor
        String errorMessage = 'Error al registrar tienda';
        
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          } else if (errorData['error'] != null) {
            errorMessage = errorData['error'];
          }
        } catch (e) {
          // Si no se puede parsear el error, usar mensaje por defecto según el código
          switch (response.statusCode) {
            case 400:
              errorMessage = 'Datos inválidos enviados al servidor';
              break;
            case 409:
              errorMessage = 'Ya existe una tienda con este nombre';
              break;
            case 422:
              errorMessage = 'Los datos enviados no son válidos';
              break;
            case 500:
              errorMessage = 'Error interno del servidor';
              break;
            default:
              errorMessage = 'Error del servidor (${response.statusCode})';
          }
        }
        
        return StoreRegistrationResult.error(errorMessage);
      }
    } catch (e) {
      // Manejar errores de conexión y otros errores
      if (e.toString().contains('SocketException') || 
          e.toString().contains('HandshakeException')) {
        return StoreRegistrationResult.error(
          'No se pudo conectar al servidor. Verifica tu conexión a internet.'
        );
      } else if (e.toString().contains('Tiempo de espera agotado')) {
        return StoreRegistrationResult.error(e.toString());
      } else {
        return StoreRegistrationResult.error(
          'Error inesperado: ${e.toString()}'
        );
      }
    }
  }

  /// Obtiene la lista de todas las tiendas registradas
  Future<List<StoreInfo>> getAllStores() async {
    try {
      final response = await _httpInterceptor.get("$baseUrl/stores");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.map((storeData) => StoreInfo.fromJson(storeData)).toList();
        } else if (data['stores'] is List) {
          return (data['stores'] as List)
              .map((storeData) => StoreInfo.fromJson(storeData))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Obtiene las tiendas de un usuario específico
  Future<List<StoreInfo>> getStoresForUser(String userId, {BuildContext? context}) async {
    try {
      final response = await _httpInterceptor.get("$baseUrl/stores/user/$userId", context: context);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.map((storeData) => StoreInfo.fromJson(storeData)).toList();
        } else if (data['stores'] is List) {
          return (data['stores'] as List)
              .map((storeData) => StoreInfo.fromJson(storeData))
              .toList();
        }
      }
      return [];
    } catch (e) {
      // Si el endpoint no existe, devolver lista vacía
      return [];
    }
  }

  /// Obtiene la información de una tienda por ID
  Future<StoreInfo?> getStoreById(String storeId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/stores/$storeId"),
        headers: await _getAuthHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return StoreInfo.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Actualiza una tienda existente
  Future<StoreRegistrationResult> updateStore({
    required String storeId,
    required String name,
    required String type,
    required String address,
    required String country,
    required String phone,
    required String responsibleUserId,
  }) async {
    try {
      // Validaciones básicas (mismas que en registerStore)
      if (name.trim().isEmpty) {
        return StoreRegistrationResult.error('El nombre de la tienda es obligatorio');
      }
      if (type.trim().isEmpty) {
        return StoreRegistrationResult.error('El tipo de tienda es obligatorio');
      }
      if (address.trim().isEmpty) {
        return StoreRegistrationResult.error('La dirección es obligatoria');
      }
      if (country.trim().isEmpty) {
        return StoreRegistrationResult.error('El país es obligatorio');
      }
      if (phone.trim().isEmpty) {
        return StoreRegistrationResult.error('El número de teléfono es obligatorio');
      }
      if (responsibleUserId.trim().isEmpty) {
        return StoreRegistrationResult.error('El usuario responsable es obligatorio');
      }

      // Validar que el ID del usuario responsable sea un número válido
      final userId = int.tryParse(responsibleUserId.trim());
      if (userId == null) {
        return StoreRegistrationResult.error('El ID del usuario responsable no es válido');
      }

      // Validar formato de teléfono según el país
      if (!_isValidPhoneForCountry(phone.trim(), country.trim())) {
        final formatExample = _getPhoneFormatForCountry(country.trim());
        return StoreRegistrationResult.error('El formato del teléfono no es válido para el país seleccionado. $formatExample');
      }

      // Preparar datos para enviar
      final storeData = {
        "name": name.trim(),
        "storeType": type.trim(),
        "address": address.trim(),
        "country": country.trim(),
        "phone": phone.trim(),
        "userId": userId,
      };

      final response = await http.put(
        Uri.parse("$baseUrl/stores/$storeId"),
        headers: await _getAuthHeaders(),
        body: jsonEncode(storeData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return StoreRegistrationResult.success(message: 'Tienda actualizada exitosamente');
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Error al actualizar tienda';
        return StoreRegistrationResult.error(errorMessage);
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || 
          e.toString().contains('HandshakeException')) {
        return StoreRegistrationResult.error('Error de conexión. Verifica tu conexión a internet');
      }
      return StoreRegistrationResult.error('Error inesperado: ${e.toString()}');
    }
  }

  /// Elimina una tienda
  Future<StoreRegistrationResult> deleteStore(String storeId) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/stores/$storeId"),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return StoreRegistrationResult.success(message: 'Tienda eliminada exitosamente');
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Error al eliminar tienda';
        return StoreRegistrationResult.error(errorMessage);
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || 
          e.toString().contains('HandshakeException')) {
        return StoreRegistrationResult.error('Error de conexión. Verifica tu conexión a internet');
      }
      return StoreRegistrationResult.error('Error inesperado: ${e.toString()}');
    }
  }
}

/// Clase para manejar el resultado del registro de tienda
class StoreRegistrationResult {
  final bool isSuccess;
  final String message;
  final String? storeId;
  final Map<String, dynamic>? storeData;

  StoreRegistrationResult._({
    required this.isSuccess,
    required this.message,
    this.storeId,
    this.storeData,
  });

  factory StoreRegistrationResult.success({
    required String message,
    String? storeId,
    Map<String, dynamic>? storeData,
  }) {
    return StoreRegistrationResult._(
      isSuccess: true,
      message: message,
      storeId: storeId,
      storeData: storeData,
    );
  }

  factory StoreRegistrationResult.error(String message) {
    return StoreRegistrationResult._(
      isSuccess: false,
      message: message,
    );
  }
}

/// Clase para representar la información de una tienda
class StoreInfo {
  final String id;
  final String name;
  final String type;
  final String address;
  final String country;
  final String phone;
  final String responsibleUserId;
  final String? responsibleUserName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  StoreInfo({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.country,
    required this.phone,
    required this.responsibleUserId,
    this.responsibleUserName,
    this.createdAt,
    this.updatedAt,
  });

  factory StoreInfo.fromJson(Map<String, dynamic> json) {
    return StoreInfo(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      type: json['storeType'] ?? json['type'] ?? '', // Try both storeType and type
      address: json['address'] ?? '',
      country: json['country'] ?? '',
      phone: json['phone'] ?? '',
      responsibleUserId: json['userId']?.toString() ?? '',
      responsibleUserName: json['responsibleUserName'],
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.tryParse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'address': address,
      'country': country,
      'phone': phone,
      'responsibleUserId': responsibleUserId,
      'responsibleUserName': responsibleUserName,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
