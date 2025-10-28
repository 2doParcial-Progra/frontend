import 'package:flutter/material.dart';

class Constants {
  // Base URL de la API local
  static const String baseUrl = 'https://app-251028005550.azurewebsites.net';

  // Colores minimalistas cafés
  static const Color primaryColor = Color(0xFF8D6E63); // Marrón claro para botones y acentos
  static const Color secondaryColor = Color(0xFFD7CCC8); // Beige para fondos secundarios
  static const Color backgroundColor = Color(0xFFEFEBE9); // Fondo principal suave
  static const Color textColor = Color(0xFF5D4037); // Marrón oscuro para texto
  static const Color accentColor = Color(0xFFA1887F); // Marrón medio para highlights

  // Tema de la app
  static ThemeData theme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryColor),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );

  // Endpoints de la API (para reutilización en servicios)
  static const String authRegister = '/api/Auth/register';
  static const String authLogin = '/api/Auth/login';
  static const String products = '/api/Products';
  static const String orders = '/api/Orders';
  static const String reviews = '/api/Reviews';
  static const String usersMe = '/api/Users/me';
}