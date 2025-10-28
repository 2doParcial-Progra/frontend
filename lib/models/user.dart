import 'role.dart';

class User {
  final int? id;
  final String? email;
  final String? password;
  final Role? role;  // Usando el enum Role
  final String? companyName;

  User({
    this.id,
    this.email,
    this.password,
    this.role,
    this.companyName,
  });

  // Constructor desde JSON (para /me o respuestas)
  factory User.fromJson(Map<String, dynamic> json) {
    final roleValue = json['role'] as int?;
    return User(
      id: json['id'] as int?,
      email: json['email'] as String?,
      role: roleValue != null ? (roleValue == 1 ? Role.client : Role.company) : null,
      companyName: json['companyName'] as String?,
    );
  }

  // Convertir a JSON para registro
  Map<String, dynamic> toJsonForRegister() {
    if (email == null || password == null || role == null) {
      throw Exception('Email, password y role son requeridos para el registro');
    }
    return {
      'email': email!,
      'password': password!,
      'role': role!.value, // Usar el valor numérico del enum
      if (companyName != null) 'companyName': companyName,
    };
  }

  // Convertir a JSON para login
  Map<String, dynamic> toJsonForLogin() {
    return {  
      'email': email,
      'password': password,
    };
  }
}