import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  final String baseUrl = "http://10.0.2.2:3000";

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
    final response = await http.post(
      Uri.parse("$baseUrl/users"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nombre": firstName,
        "apellidos": lastName,
        "direccion": address,
        "pais": country,
        "edad": age,
        "sexo": gender,
        "roles": roles,
        "email": email,
        "password": password,
      }),
    );

    return response.statusCode == 201 || response.statusCode == 200;
  }

  Future<bool> signup(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/signup"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    return response.statusCode == 201 || response.statusCode == 200;
  }

  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      // Guardar tokens
      await _storage.write(key: "access_token", value: data["access_token"]);
      await _storage.write(key: "refresh_token", value: data["refresh_token"]);
      
      // Guardar datos del usuario si están disponibles
      if (data["user"] != null) {
        await _saveUserData(data["user"]);
      } else {
        // Si no vienen datos del usuario en el login, obtenerlos por separado
        await _fetchAndSaveUserData(email);
      }
      
      return true;
    }
    return false;
  }

  /// Guarda los datos del usuario en el storage
  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    await _storage.write(key: "user_id", value: userData["id"]?.toString());
    await _storage.write(key: "user_email", value: userData["email"]);
    await _storage.write(key: "user_name", value: userData["firstName"]);
    await _storage.write(key: "user_lastname", value: userData["lastName"]);
    await _storage.write(key: "user_address", value: userData["address"]);
    await _storage.write(key: "user_country", value: userData["country"]);
    await _storage.write(key: "user_age", value: userData["age"]?.toString());
    await _storage.write(key: "user_gender", value: userData["gender"]);
    await _storage.write(key: "user_roles", value: jsonEncode(userData["roles"] ?? []));
    await _storage.write(key: "user_created_at", value: userData["createdAt"]);
  }

  /// Obtiene y guarda los datos del usuario por email
  Future<void> _fetchAndSaveUserData(String email) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/users/by-email?email=${Uri.encodeComponent(email)}"),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        await _saveUserData(userData);
      }
    } catch (e) {
      // Si no se pueden obtener los datos del usuario, continuar sin ellos
      print('Error fetching user data: $e');
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: "access_token");
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: "refresh_token");
  }

  /// Obtiene los datos del usuario guardados
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final userId = await _storage.read(key: "user_id");
      if (userId == null) return null;
      
      return {
        "id": userId,
        "email": await _storage.read(key: "user_email"),
        "nombre": await _storage.read(key: "user_name"),
        "apellidos": await _storage.read(key: "user_lastname"),
        "direccion": await _storage.read(key: "user_address"),
        "pais": await _storage.read(key: "user_country"),
        "edad": int.tryParse(await _storage.read(key: "user_age") ?? "0"),
        "sexo": await _storage.read(key: "user_gender"),
        "roles": _parseRoles(await _storage.read(key: "user_roles")),
        "createdAt": await _storage.read(key: "user_created_at"),
      };
    } catch (e) {
      return null;
    }
  }

  /// Parsea los roles del JSON guardado
  List<String> _parseRoles(String? rolesJson) {
    if (rolesJson == null || rolesJson.isEmpty) return [];
    try {
      final List<dynamic> roles = jsonDecode(rolesJson);
      return roles.cast<String>();
    } catch (e) {
      return [];
    }
  }

  /// Verifica si hay un usuario logueado
  Future<bool> isUserLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Obtiene el nombre completo del usuario
  Future<String?> getUserFullName() async {
    final userData = await getUserData();
    if (userData == null) return null;
    
    final name = userData["nombre"] ?? "";
    final lastname = userData["apellidos"] ?? "";
    return "$name $lastname".trim();
  }

  /// Obtiene el email del usuario
  Future<String?> getUserEmail() async {
    return await _storage.read(key: "user_email");
  }

  /// Obtiene los roles del usuario
  Future<List<String>> getUserRoles() async {
    return _parseRoles(await _storage.read(key: "user_roles"));
  }

  Future<bool> refreshToken() async {
    final refresh = await getRefreshToken();
    if (refresh == null) return false;

    final response = await http.post(
      Uri.parse("$baseUrl/auth/refresh"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $refresh"
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _storage.write(key: "access_token", value: data["access_token"]);
      await _storage.write(key: "refresh_token", value: data["refresh_token"]);
      return true;
    }

    return false;
  }
}
