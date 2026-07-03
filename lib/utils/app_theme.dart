import 'package:flutter/material.dart';

/// Centralized theme definitions for Light and Dark mode.
/// Kept deliberately simple (Material defaults + a seed color) so it
/// renders reliably in the FlutLab web/mobile preview environment.
class AppTheme {
  AppTheme._();

  static const Color _seedColor = Color(0xFF4C6FFF);

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF7F8FC),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      fontFamily: 'Roboto',
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      fontFamily: 'Roboto',
    );
  }
}
