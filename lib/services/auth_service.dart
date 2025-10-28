import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/token.dart';
import '../models/role.dart';
import 'api_service.dart';
//import '../utils/constants.dart';

class AuthService extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isCompany => _currentUser?.role == Role.company;

  // Limpiar completamente la sesión
  Future<void> clearSession() async {
    await _apiService.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Limpia todas las preferencias
    _currentUser = null;
    notifyListeners();
  }

  // Registro de usuario
  Future<void> register(User user) async {
    try {
      await clearSession(); // Limpia cualquier sesión anterior
      
      final body = user.toJsonForRegister();
      print('Registering with data: $body'); // Debug
      
      await _apiService.post('/api/Auth/register', body);
      // Después de registro exitoso, hacer login
      await login(user);
    } catch (e) {
      print('Error en registro: $e'); // Debug
      rethrow;
    }
  }

  // Login de usuario
  Future<void> login(User user) async {
    try {
      final body = user.toJsonForLogin();
      final response = await _apiService.post('/api/Auth/login', body);
      final token = Token.fromJson(response);

      if (token.token != null) {
        await _apiService.setToken(token.token!);
        await _loadCurrentUser();
      }
    } catch (e) {
      rethrow;
    }
  }

  // Cargar datos del usuario actual
  Future<void> _loadCurrentUser() async {
    try {
      final userData = await _apiService.get('/api/Users/me');
      print('User data from API: $userData'); // Debug
      _currentUser = User.fromJson(userData);
      print('Current user role: ${_currentUser?.role}'); // Debug
      print('Is company: ${_currentUser?.role == Role.company}'); // Debug
      
      // Verificar si el token tiene el rol correcto
      final token = await _apiService.getToken();
      if (token != null) {
        final parts = token.split('.');
        if (parts.length > 1) {
          final payload = parts[1];
          final normalized = base64Url.normalize(payload);
          final decodedPayload = utf8.decode(base64Url.decode(normalized));
          final payloadMap = json.decode(decodedPayload);
          
          final tokenRole = payloadMap['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];
          final isCompanyInDb = _currentUser?.role == Role.company;
          
          if (isCompanyInDb && tokenRole != 'Empresa') {
            // El rol en la base de datos es empresa pero el token no lo refleja
            await clearSession();
            throw Exception('Hay un problema con los permisos de tu cuenta. Por favor, contacta al soporte técnico. (Error: Token role mismatch)');
          }
        }
      }
      
      notifyListeners();
    } catch (e) {
      await clearSession();
      rethrow;
    }
  }

  // Logout (limpia token y usuario)
  Future<void> logout() async {
    await _apiService.clearToken();
    _currentUser = null;
    notifyListeners();
  }

  // Verificar estado de autenticación
  Future<bool> checkAuthStatus() async {
    try {
      if (await _apiService.hasToken()) {
        await _loadCurrentUser();
        return true;
      }
    } catch (e) {
      await logout();
    }
    return false;
  }
}
