import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/services/http_interceptor.dart';

class UserService {
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

  /// Agrega un usuario a una tienda
  /// 
  /// [storeId] - ID de la tienda
  /// [userId] - ID del usuario
  /// [isPrimary] - Si el usuario es el usuario principal de la tienda
  /// 
  /// Retorna un [UserStoreAssignmentResult] con el resultado de la asignación
  Future<UserStoreAssignmentResult> addUserToStore({
    required int storeId,
    required int userId,
    bool isPrimary = false,
    BuildContext? context,
  }) async {
    try {
      final body = jsonEncode({
        'userId': userId,
        'isPrimary': isPrimary,
      });

      final response = await _httpInterceptor.post(
        '$baseUrl/stores/$storeId/users',
        body: body,
        context: context,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return UserStoreAssignmentResult.success(
          id: data['id'],
          storeId: data['storeId'],
          userId: data['userId'],
          isPrimary: data['isPrimary'],
          status: data['status'],
          joinedAt: data['joinedAt'] != null 
              ? DateTime.tryParse(data['joinedAt']) 
              : null,
        );
      } else {
        final errorData = jsonDecode(response.body);
        return UserStoreAssignmentResult.error(
          errorData['message'] ?? 'Error al agregar usuario a la tienda'
        );
      }
    } catch (e) {
      return UserStoreAssignmentResult.error('Error de conexión: $e');
    }
  }

  /// Agrega múltiples usuarios a una tienda
  /// 
  /// [storeId] - ID de la tienda
  /// [userIds] - Lista de IDs de usuarios
  /// [isPrimary] - Si los usuarios son usuarios principales de la tienda
  /// 
  /// Retorna un [BulkUserStoreAssignmentResult] con el resultado de las asignaciones
  Future<BulkUserStoreAssignmentResult> addUsersToStore({
    required int storeId,
    required List<int> userIds,
    bool isPrimary = false,
    BuildContext? context,
  }) async {
    try {
      final results = <UserStoreAssignmentResult>[];
      final errors = <String>[];

      for (final userId in userIds) {
        final result = await addUserToStore(
          storeId: storeId,
          userId: userId,
          isPrimary: isPrimary,
          context: context,
        );
        
        if (result.isSuccess) {
          results.add(result);
        } else {
          errors.add('Usuario $userId: ${result.message}');
        }
      }

      if (errors.isEmpty) {
        return BulkUserStoreAssignmentResult.success(
          successfulAssignments: results,
          totalProcessed: userIds.length,
          totalSuccessful: results.length,
        );
      } else {
        return BulkUserStoreAssignmentResult.partialSuccess(
          successfulAssignments: results,
          errors: errors,
          totalProcessed: userIds.length,
          totalSuccessful: results.length,
        );
      }
    } catch (e) {
      return BulkUserStoreAssignmentResult.error('Error de conexión: $e');
    }
  }

  /// Registra un nuevo usuario en el sistema
  /// 
  /// [firstName] - Nombre del usuario
  /// [lastName] - Apellidos del usuario
  /// [address] - Dirección del usuario
  /// [country] - País del usuario
  /// [age] - Edad del usuario
  /// [gender] - Género del usuario (M, F, Otro)
  /// [roles] - Lista de roles del usuario
  /// [email] - Email del usuario
  /// [password] - Contraseña del usuario
  /// 
  /// Retorna un [UserRegistrationResult] con el resultado del registro
  Future<UserRegistrationResult> registerUser({
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
    try {
      // Validaciones básicas
      if (firstName.trim().isEmpty) {
        return UserRegistrationResult.error('El nombre es obligatorio');
      }
      if (lastName.trim().isEmpty) {
        return UserRegistrationResult.error('Los apellidos son obligatorios');
      }
      if (email.trim().isEmpty) {
        return UserRegistrationResult.error('El email es obligatorio');
      }
      if (password.length < 6) {
        return UserRegistrationResult.error('La contraseña debe tener al menos 6 caracteres');
      }
      if (age <= 0) {
        return UserRegistrationResult.error('La edad debe ser mayor a 0');
      }
      if (roles.isEmpty) {
        return UserRegistrationResult.error('Debe seleccionar al menos un rol');
      }

      // Validar formato de email
      final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
      if (!emailRegex.hasMatch(email.trim())) {
        return UserRegistrationResult.error('El formato del email no es válido');
      }

      // Validar género
      if (!['M', 'F'].contains(gender)) {
        return UserRegistrationResult.error('El género seleccionado no es válido');
      }

      // Preparar datos para enviar
      final userData = {
        "firstName": firstName.trim(),
        "lastName": lastName.trim(),
        "address": address.trim(),
        "country": country.trim(),
        "age": age,
        "gender": gender,
        "roles": roles,
        "email": email.trim().toLowerCase(),
        "password": password,
      };


      // Realizar petición HTTP
      final response = await http.post(
        Uri.parse("$baseUrl/users"),
        headers: await _getAuthHeaders(),
        body: jsonEncode(userData),
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
          return UserRegistrationResult.success(
            message: 'Usuario registrado exitosamente',
            userId: responseData['id']?.toString(),
            userData: responseData,
          );
        } catch (e) {
          return UserRegistrationResult.success(
            message: 'Usuario registrado exitosamente',
          );
        }
      } else {
        // Manejar errores específicos del servidor
        String errorMessage = 'Error al registrar usuario';
        
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
              errorMessage = 'El email ya está registrado';
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
        
        return UserRegistrationResult.error(errorMessage);
      }
    } catch (e) {
      // Manejar errores de conexión y otros errores
      if (e.toString().contains('SocketException') || 
          e.toString().contains('HandshakeException')) {
        return UserRegistrationResult.error(
          'No se pudo conectar al servidor. Verifica tu conexión a internet.'
        );
      } else if (e.toString().contains('Tiempo de espera agotado')) {
        return UserRegistrationResult.error(e.toString());
      } else {
        return UserRegistrationResult.error(
          'Error inesperado: ${e.toString()}'
        );
      }
    }
  }

  /// Valida si un email ya está registrado
  Future<bool> isEmailAvailable(String email) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/users/check-email?email=${Uri.encodeComponent(email)}"),
        headers: await _getAuthHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['available'] ?? true;
      }
      return true; // En caso de error, asumir que está disponible
    } catch (e) {
      return true; // En caso de error, asumir que está disponible
    }
  }

  /// Obtiene la información de un usuario por ID
  Future<UserInfo?> getUserById(String userId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/users/$userId"),
        headers: await _getAuthHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserInfo.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Obtiene la lista de todos los usuarios registrados
  Future<List<UserInfo>> getAllUsers({BuildContext? context}) async {
    try {
      final response = await _httpInterceptor.get("$baseUrl/users", context: context);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.map((userData) => UserInfo.fromJson(userData)).toList();
        } else if (data['users'] is List) {
          return (data['users'] as List)
              .map((userData) => UserInfo.fromJson(userData))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Busca usuarios por nombre, email o rol
  Future<List<UserInfo>> searchUsers(String query) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/users/search?q=${Uri.encodeComponent(query)}"),
        headers: await _getAuthHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.map((userData) => UserInfo.fromJson(userData)).toList();
        } else if (data['users'] is List) {
          return (data['users'] as List)
              .map((userData) => UserInfo.fromJson(userData))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Filtra usuarios por rol
  Future<List<UserInfo>> getUsersByRole(String role) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/users?role=${Uri.encodeComponent(role)}"),
        headers: await _getAuthHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.map((userData) => UserInfo.fromJson(userData)).toList();
        } else if (data['users'] is List) {
          return (data['users'] as List)
              .map((userData) => UserInfo.fromJson(userData))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Actualiza un usuario existente
  Future<UserRegistrationResult> updateUser({
    required String userId,
    required String firstName,
    required String lastName,
    required String address,
    required String country,
    required int age,
    required String gender,
    required List<String> roles,
    required String email,
  }) async {
    try {
      // Validaciones básicas
      if (firstName.trim().isEmpty) {
        return UserRegistrationResult.error('El nombre es obligatorio');
      }
      if (lastName.trim().isEmpty) {
        return UserRegistrationResult.error('Los apellidos son obligatorios');
      }
      if (email.trim().isEmpty) {
        return UserRegistrationResult.error('El email es obligatorio');
      }
      if (age <= 0) {
        return UserRegistrationResult.error('La edad debe ser mayor a 0');
      }
      if (roles.isEmpty) {
        return UserRegistrationResult.error('Debe seleccionar al menos un rol');
      }

      // Validar formato de email
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email)) {
        return UserRegistrationResult.error('El formato del email no es válido');
      }

      // Preparar datos para enviar
      final userData = {
        "firstName": firstName.trim(),
        "lastName": lastName.trim(),
        "address": address.trim(),
        "country": country.trim(),
        "age": age,
        "gender": gender,
        "roles": roles,
        "email": email.trim().toLowerCase(),
      };

      final response = await http.put(
        Uri.parse("$baseUrl/users/$userId"),
        headers: await _getAuthHeaders(),
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserRegistrationResult.success(message: 'Usuario actualizado exitosamente');
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Error al actualizar usuario';
        return UserRegistrationResult.error(errorMessage);
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || 
          e.toString().contains('HandshakeException')) {
        return UserRegistrationResult.error('Error de conexión. Verifica tu conexión a internet');
      }
      return UserRegistrationResult.error('Error inesperado: ${e.toString()}');
    }
  }
}

/// Clase para manejar el resultado del registro de usuario
class UserRegistrationResult {
  final bool isSuccess;
  final String message;
  final String? userId;
  final Map<String, dynamic>? userData;

  UserRegistrationResult._({
    required this.isSuccess,
    required this.message,
    this.userId,
    this.userData,
  });

  factory UserRegistrationResult.success({
    required String message,
    String? userId,
    Map<String, dynamic>? userData,
  }) {
    return UserRegistrationResult._(
      isSuccess: true,
      message: message,
      userId: userId,
      userData: userData,
    );
  }

  factory UserRegistrationResult.error(String message) {
    return UserRegistrationResult._(
      isSuccess: false,
      message: message,
    );
  }
}

/// Clase para representar la información de un usuario
class UserInfo {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String address;
  final String country;
  final int age;
  final String gender;
  final List<String> roles;
  final DateTime? createdAt;

  UserInfo({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.address,
    required this.country,
    required this.age,
    required this.gender,
    required this.roles,
    this.createdAt,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      country: json['country'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? '',
      roles: List<String>.from(json['roles'] ?? []),
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'address': address,
      'country': country,
      'age': age,
      'gender': gender,
      'roles': roles,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

/// Clase para manejar el resultado de asignar un usuario a una tienda
class UserStoreAssignmentResult {
  final bool isSuccess;
  final String message;
  final int? id;
  final int? storeId;
  final int? userId;
  final bool? isPrimary;
  final String? status;
  final DateTime? joinedAt;

  UserStoreAssignmentResult._({
    required this.isSuccess,
    required this.message,
    this.id,
    this.storeId,
    this.userId,
    this.isPrimary,
    this.status,
    this.joinedAt,
  });

  factory UserStoreAssignmentResult.success({
    required int id,
    required int storeId,
    required int userId,
    required bool isPrimary,
    required String status,
    DateTime? joinedAt,
  }) {
    return UserStoreAssignmentResult._(
      isSuccess: true,
      message: 'Usuario agregado a la tienda exitosamente',
      id: id,
      storeId: storeId,
      userId: userId,
      isPrimary: isPrimary,
      status: status,
      joinedAt: joinedAt,
    );
  }

  factory UserStoreAssignmentResult.error(String message) {
    return UserStoreAssignmentResult._(
      isSuccess: false,
      message: message,
    );
  }
}

/// Clase para manejar el resultado de asignar múltiples usuarios a una tienda
class BulkUserStoreAssignmentResult {
  final bool isSuccess;
  final String message;
  final List<UserStoreAssignmentResult> successfulAssignments;
  final List<String> errors;
  final int totalProcessed;
  final int totalSuccessful;

  BulkUserStoreAssignmentResult._({
    required this.isSuccess,
    required this.message,
    required this.successfulAssignments,
    required this.errors,
    required this.totalProcessed,
    required this.totalSuccessful,
  });

  factory BulkUserStoreAssignmentResult.success({
    required List<UserStoreAssignmentResult> successfulAssignments,
    required int totalProcessed,
    required int totalSuccessful,
  }) {
    return BulkUserStoreAssignmentResult._(
      isSuccess: true,
      message: 'Todos los usuarios fueron agregados exitosamente',
      successfulAssignments: successfulAssignments,
      errors: [],
      totalProcessed: totalProcessed,
      totalSuccessful: totalSuccessful,
    );
  }

  factory BulkUserStoreAssignmentResult.partialSuccess({
    required List<UserStoreAssignmentResult> successfulAssignments,
    required List<String> errors,
    required int totalProcessed,
    required int totalSuccessful,
  }) {
    return BulkUserStoreAssignmentResult._(
      isSuccess: false,
      message: 'Algunos usuarios fueron agregados exitosamente',
      successfulAssignments: successfulAssignments,
      errors: errors,
      totalProcessed: totalProcessed,
      totalSuccessful: totalSuccessful,
    );
  }

  factory BulkUserStoreAssignmentResult.error(String message) {
    return BulkUserStoreAssignmentResult._(
      isSuccess: false,
      message: message,
      successfulAssignments: [],
      errors: [message],
      totalProcessed: 0,
      totalSuccessful: 0,
    );
  }
}
