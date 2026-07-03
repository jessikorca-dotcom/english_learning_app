import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_constants.dart';

/// Holds the app's current ThemeMode and persists it to SharedPreferences.
///
/// Uses a plain ValueNotifier (per project requirement: no heavy state
/// management libraries). The root MaterialApp listens to this via
/// ValueListenableBuilder and rebuilds when the mode changes.
class ThemeService {
  ThemeService._internal();
  static final ThemeService instance = ThemeService._internal();

  final ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(
    ThemeMode.light,
  );

  /// Loads the saved theme preference. Call once during app startup,
  /// before runApp, so the correct theme is applied on first frame.
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(AppConstants.prefThemeMode);
    themeMode.value = (saved == 'dark') ? ThemeMode.dark : ThemeMode.light;
  }

  /// Toggles between light and dark and persists the choice.
  Future<void> toggleTheme() async {
    final isDark = themeMode.value == ThemeMode.dark;
    themeMode.value = isDark ? ThemeMode.light : ThemeMode.dark;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.prefThemeMode,
      isDark ? 'light' : 'dark',
    );
  }
}
