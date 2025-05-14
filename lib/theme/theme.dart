import 'package:flutter/material.dart';

final ThemeData customDarkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color.fromARGB(255, 15, 12, 15), // Fondo general oscuro
  colorScheme: ColorScheme.dark(
    primary: Color(0xFFe50914), // Rojo principal del botón
    secondary: Colors.white, // Texto secundario
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: false, // No tiene fondo
    hintStyle: TextStyle(color: Colors.grey[400]),
    labelStyle: const TextStyle(color: Colors.white),
    prefixIconColor: Colors.redAccent, // Color del ícono
    enabledBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.white), // Borde blanco
    ),
    focusedBorder: const UnderlineInputBorder(
      borderSide:
          BorderSide(color: Colors.redAccent), // Borde rojo al hacer focus
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFe50914), // Color del botón
      foregroundColor: Colors.white, // Color del texto
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white),
  ),
);
