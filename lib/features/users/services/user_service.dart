import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  final String baseUrl = "http://10.0.2.2:3000";

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
      if (!['M', 'F', 'Otro'].contains(gender)) {
        return UserRegistrationResult.error('El género seleccionado no es válido');
      }

      // Preparar datos para enviar
      final userData = {
        "name": firstName.trim(),
        "last_name": lastName.trim(),
        "address": address.trim(),
        "country": country.trim(),
        "age": age,
        "gender": gender,
        "role": roles,
        "email": email.trim().toLowerCase(),
        "password": password,
      };


      // Realizar petición HTTP
      final response = await http.post(
        Uri.parse("$baseUrl/users"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
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
        headers: {"Accept": "application/json"},
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
        headers: {"Accept": "application/json"},
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
  Future<List<UserInfo>> getAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/users"),
        headers: {"Accept": "application/json"},
      ).timeout(const Duration(seconds: 15));

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
        headers: {"Accept": "application/json"},
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
        headers: {"Accept": "application/json"},
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
  final String nombre;
  final String apellidos;
  final String email;
  final String direccion;
  final String pais;
  final int edad;
  final String sexo;
  final List<String> roles;
  final DateTime? createdAt;

  UserInfo({
    required this.id,
    required this.nombre,
    required this.apellidos,
    required this.email,
    required this.direccion,
    required this.pais,
    required this.edad,
    required this.sexo,
    required this.roles,
    this.createdAt,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre'] ?? '',
      apellidos: json['apellidos'] ?? '',
      email: json['email'] ?? '',
      direccion: json['direccion'] ?? '',
      pais: json['pais'] ?? '',
      edad: json['edad'] ?? 0,
      sexo: json['sexo'] ?? '',
      roles: List<String>.from(json['roles'] ?? []),
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellidos': apellidos,
      'email': email,
      'direccion': direccion,
      'pais': pais,
      'edad': edad,
      'sexo': sexo,
      'roles': roles,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
