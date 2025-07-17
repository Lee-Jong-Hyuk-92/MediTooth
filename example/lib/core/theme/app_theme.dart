// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  static const Color lightBackground = Color(0xFFB4D4FF);
  static const Color darkBackground = Color(0xFF5F97F7);

  static const Color lightAppBarText = Color(0xFF2B3A67);
  static const Color darkAppBarText = Colors.white;

  static const Color buttonColor = Color(0xFF9681EB);

  static const Color lightText = Color(0xFF2B3A67);
  static const Color darkText = Colors.white;

  static const Color errorColor = Color(0xFFFF5252);

  static const Color lightAuxBackground = Color(0xFFE8F0FE);
  static const Color darkAuxBackground = Color(0xFF3A6FCE);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: lightBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        foregroundColor: lightAppBarText,
        elevation: 1,
        centerTitle: true,
        iconTheme: IconThemeData(color: lightAppBarText),
        titleTextStyle: TextStyle(
          color: lightAppBarText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      colorScheme: const ColorScheme.light(
        primary: buttonColor,
        onPrimary: Colors.white,
        error: errorColor,
        background: lightBackground,
        onBackground: lightText,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: lightText),
        headlineLarge: TextStyle(color: lightText, fontWeight: FontWeight.bold),
        labelLarge: TextStyle(color: lightText, fontWeight: FontWeight.w600),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: buttonColor),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: buttonColor,
        selectionColor: buttonColor,
        selectionHandleColor: buttonColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      cardColor: lightAuxBackground,
      iconTheme: const IconThemeData(color: lightAppBarText),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkAppBarText,
        elevation: 1,
        centerTitle: true,
        iconTheme: IconThemeData(color: darkAppBarText),
        titleTextStyle: TextStyle(
          color: darkAppBarText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      colorScheme: const ColorScheme.dark(
        primary: buttonColor,
        onPrimary: Colors.white,
        error: errorColor,
        background: darkBackground,
        onBackground: darkText,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: darkText),
        headlineLarge: TextStyle(color: darkText, fontWeight: FontWeight.bold),
        labelLarge: TextStyle(color: darkText, fontWeight: FontWeight.w600),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: buttonColor),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        fillColor: darkAuxBackground,
        filled: true,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: buttonColor,
        selectionColor: buttonColor,
        selectionHandleColor: buttonColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      cardColor: darkAuxBackground,
      iconTheme: const IconThemeData(color: darkAppBarText),
    );
  }
}
