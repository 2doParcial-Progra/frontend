import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ApiService {
  static const String _tokenKey = 'auth_token';

  // Obtener token almacenado
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
  
  // Para uso interno
  Future<String?> _getToken() async {
    return getToken();
  }

  // Almacenar token (llamado después de login)
  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Limpiar token (logout)
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Verificar si existe un token almacenado (público)
  Future<bool> hasToken() async {
    final token = await _getToken();
    return token != null;
  }

  // Headers base con Bearer si hay token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    print('Request headers: $headers'); // Debug
    return headers;
  }

  // Método GET genérico
  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('${Constants.baseUrl}$endpoint');
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);
    return _handleResponse(response);
  }

  // Método POST genérico
  Future<dynamic> post(String endpoint, Map<String, dynamic>? body) async {
    final url = Uri.parse('${Constants.baseUrl}$endpoint');
    final headers = await _getHeaders();
    
    if (!endpoint.contains('/login') && !endpoint.contains('/register')) {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No hay sesión activa. Por favor, inicia sesión.');
      }
    }
    
    final response = await http.post(url, headers: headers, body: jsonEncode(body));
    return _handleResponse(response);
  }

  // Método PUT genérico
  Future<dynamic> put(String endpoint, Map<String, dynamic>? body) async {
    final url = Uri.parse('${Constants.baseUrl}$endpoint');
    final headers = await _getHeaders();
    final response =
        await http.put(url, headers: headers, body: jsonEncode(body));
    return _handleResponse(response);
  }

  // Método PATCH genérico
  Future<dynamic> patch(String endpoint, Map<String, dynamic>? body) async {
    final url = Uri.parse('${Constants.baseUrl}$endpoint');
    final headers = await _getHeaders();
    final response =
        await http.patch(url, headers: headers, body: jsonEncode(body));
    return _handleResponse(response);
  }

  // Método DELETE genérico
  Future<dynamic> delete(String endpoint) async {
    final url = Uri.parse('${Constants.baseUrl}$endpoint');
    final headers = await _getHeaders();
    final response = await http.delete(url, headers: headers);
    return _handleResponse(response);
  }

  // Manejo de respuesta común
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else if (response.statusCode == 403) {
      // Intenta parsear el mensaje de error de la API si existe
      try {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'No tienes permiso para realizar esta acción. Por favor, verifica que tu cuenta tenga los permisos necesarios.');
      } catch (e) {
        throw Exception('No tienes permiso para realizar esta acción. Por favor, verifica que tu cuenta tenga los permisos necesarios.');
      }
    } else {
      try {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Error ${response.statusCode}: ${response.body}');
      } catch (e) {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    }
  }
}
