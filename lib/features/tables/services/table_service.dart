import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../auth/services/auth_service.dart';

class TableService {
  final String baseUrl = "http://10.0.2.2:3000";
  final AuthService _authService = AuthService();

  /// Obtiene los headers de autenticación con el token
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _authService.getAccessToken();
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  /// Registra una nueva mesa en el sistema
  /// 
  /// [tableNumber] - Número de la mesa
  /// [capacity] - Capacidad de la mesa
  /// [status] - Estado de la mesa (available, occupied, reserved, maintenance)
  /// [storeId] - ID de la tienda a la que pertenece la mesa
  /// 
  /// Retorna un [TableRegistrationResult] con el resultado del registro
  Future<TableRegistrationResult> registerTable({
    required String tableNumber,
    required int capacity,
    required String status,
    required String storeId,
  }) async {
    try {
      // Validaciones básicas
      if (tableNumber.trim().isEmpty) {
        return TableRegistrationResult.error('El número de mesa es obligatorio');
      }
      if (capacity <= 0) {
        return TableRegistrationResult.error('La capacidad debe ser mayor a 0');
      }
      if (status.trim().isEmpty) {
        return TableRegistrationResult.error('El estado de la mesa es obligatorio');
      }
      if (storeId.trim().isEmpty) {
        return TableRegistrationResult.error('La tienda es obligatoria');
      }

      // Validar que el ID de la tienda sea un número válido
      final storeIdInt = int.tryParse(storeId.trim());
      if (storeIdInt == null) {
        return TableRegistrationResult.error('El ID de la tienda no es válido');
      }

      // Validar que el número de mesa sea único (solo números)
      final tableNumberInt = int.tryParse(tableNumber.trim());
      if (tableNumberInt == null) {
        return TableRegistrationResult.error('El número de mesa debe ser un número válido');
      }

      // Validar estado válido
      final validStatuses = ['available', 'occupied', 'reserved', 'maintenance'];
      if (!validStatuses.contains(status.trim().toLowerCase())) {
        return TableRegistrationResult.error('El estado debe ser: disponible, ocupada, reservada o mantenimiento');
      }

      // Preparar datos para enviar
      final tableData = {
        "tableNumber": tableNumberInt,
        "capacity": capacity,
        "status": status.trim().toLowerCase(),
        "storeId": storeIdInt,
      };

      // Realizar petición HTTP
      final response = await http.post(
        Uri.parse("$baseUrl/tables"),
        headers: await _getAuthHeaders(),
        body: jsonEncode(tableData),
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
          return TableRegistrationResult.success(
            message: 'Mesa registrada exitosamente',
            tableId: responseData['id']?.toString(),
            tableData: responseData,
          );
        } catch (e) {
          return TableRegistrationResult.success(
            message: 'Mesa registrada exitosamente',
          );
        }
      } else {
        // Manejar errores específicos del servidor
        String errorMessage = 'Error al registrar mesa';
        
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
              errorMessage = 'Ya existe una mesa con este número en la tienda';
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
        
        return TableRegistrationResult.error(errorMessage);
      }
    } catch (e) {
      // Manejar errores de conexión y otros errores
      if (e.toString().contains('SocketException') || 
          e.toString().contains('HandshakeException')) {
        return TableRegistrationResult.error(
          'No se pudo conectar al servidor. Verifica tu conexión a internet.'
        );
      } else if (e.toString().contains('Tiempo de espera agotado')) {
        return TableRegistrationResult.error(e.toString());
      } else {
        return TableRegistrationResult.error(
          'Error inesperado: ${e.toString()}'
        );
      }
    }
  }

  /// Obtiene la lista de todas las mesas registradas
  Future<List<TableInfo>> getAllTables() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/tables"),
        headers: await _getAuthHeaders(),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.map((tableData) => TableInfo.fromJson(tableData)).toList();
        } else if (data['tables'] is List) {
          return (data['tables'] as List)
              .map((tableData) => TableInfo.fromJson(tableData))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Obtiene las mesas de una tienda específica
  Future<List<TableInfo>> getTablesByStore(String storeId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/tables/store/$storeId"),
        headers: await _getAuthHeaders(),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.map((tableData) => TableInfo.fromJson(tableData)).toList();
        } else if (data['tables'] is List) {
          return (data['tables'] as List)
              .map((tableData) => TableInfo.fromJson(tableData))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Obtiene la información de una mesa por ID
  Future<TableInfo?> getTableById(String tableId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/tables/$tableId"),
        headers: await _getAuthHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return TableInfo.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Actualiza una mesa existente
  Future<TableRegistrationResult> updateTable({
    required String tableId,
    required String tableNumber,
    required int capacity,
    required String status,
    required String storeId,
  }) async {
    try {
      // Validaciones básicas (mismas que en registerTable)
      if (tableNumber.trim().isEmpty) {
        return TableRegistrationResult.error('El número de mesa es obligatorio');
      }
      if (capacity <= 0) {
        return TableRegistrationResult.error('La capacidad debe ser mayor a 0');
      }
      if (status.trim().isEmpty) {
        return TableRegistrationResult.error('El estado de la mesa es obligatorio');
      }
      if (storeId.trim().isEmpty) {
        return TableRegistrationResult.error('La tienda es obligatoria');
      }

      // Validar que el ID de la tienda sea un número válido
      final storeIdInt = int.tryParse(storeId.trim());
      if (storeIdInt == null) {
        return TableRegistrationResult.error('El ID de la tienda no es válido');
      }

      // Validar que el número de mesa sea un número válido
      final tableNumberInt = int.tryParse(tableNumber.trim());
      if (tableNumberInt == null) {
        return TableRegistrationResult.error('El número de mesa debe ser un número válido');
      }

      // Validar estado válido
      final validStatuses = ['available', 'occupied', 'reserved', 'maintenance'];
      if (!validStatuses.contains(status.trim().toLowerCase())) {
        return TableRegistrationResult.error('El estado debe ser: disponible, ocupada, reservada o mantenimiento');
      }

      // Preparar datos para enviar
      final tableData = {
        "tableNumber": tableNumberInt,
        "capacity": capacity,
        "status": status.trim().toLowerCase(),
        "storeId": storeIdInt,
      };

      final response = await http.put(
        Uri.parse("$baseUrl/tables/$tableId"),
        headers: await _getAuthHeaders(),
        body: jsonEncode(tableData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return TableRegistrationResult.success(message: 'Mesa actualizada exitosamente');
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Error al actualizar mesa';
        return TableRegistrationResult.error(errorMessage);
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || 
          e.toString().contains('HandshakeException')) {
        return TableRegistrationResult.error('Error de conexión. Verifica tu conexión a internet');
      }
      return TableRegistrationResult.error('Error inesperado: ${e.toString()}');
    }
  }

  /// Elimina una mesa
  Future<TableRegistrationResult> deleteTable(String tableId) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/tables/$tableId"),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return TableRegistrationResult.success(message: 'Mesa eliminada exitosamente');
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Error al eliminar mesa';
        return TableRegistrationResult.error(errorMessage);
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || 
          e.toString().contains('HandshakeException')) {
        return TableRegistrationResult.error('Error de conexión. Verifica tu conexión a internet');
      }
      return TableRegistrationResult.error('Error inesperado: ${e.toString()}');
    }
  }
}

/// Clase para manejar el resultado del registro de mesa
class TableRegistrationResult {
  final bool isSuccess;
  final String message;
  final String? tableId;
  final Map<String, dynamic>? tableData;

  TableRegistrationResult._({
    required this.isSuccess,
    required this.message,
    this.tableId,
    this.tableData,
  });

  factory TableRegistrationResult.success({
    required String message,
    String? tableId,
    Map<String, dynamic>? tableData,
  }) {
    return TableRegistrationResult._(
      isSuccess: true,
      message: message,
      tableId: tableId,
      tableData: tableData,
    );
  }

  factory TableRegistrationResult.error(String message) {
    return TableRegistrationResult._(
      isSuccess: false,
      message: message,
    );
  }
}

/// Clase para representar la información de una mesa
class TableInfo {
  final String id;
  final int tableNumber;
  final int capacity;
  final String status;
  final String storeId;
  final String? storeName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TableInfo({
    required this.id,
    required this.tableNumber,
    required this.capacity,
    required this.status,
    required this.storeId,
    this.storeName,
    this.createdAt,
    this.updatedAt,
  });

  factory TableInfo.fromJson(Map<String, dynamic> json) {
    return TableInfo(
      id: json['id']?.toString() ?? '',
      tableNumber: json['tableNumber'] ?? 0,
      capacity: json['capacity'] ?? 0,
      status: json['status'] ?? '',
      storeId: json['storeId']?.toString() ?? '',
      storeName: json['storeName'],
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
      'tableNumber': tableNumber,
      'capacity': capacity,
      'status': status,
      'storeId': storeId,
      'storeName': storeName,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
