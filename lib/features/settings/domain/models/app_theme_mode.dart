import 'package:flutter/material.dart';

/// Available UI Theme Modes
enum AppThemeMode {
  dark('dark', 'Dark Mode', Icons.dark_mode_rounded),
  light('light', 'Light Mode', Icons.light_mode_rounded),
  system('system', 'System Default', Icons.brightness_auto_rounded);

  final String id;
  final String label;
  final IconData icon;

  const AppThemeMode(this.id, this.label, this.icon);

  static AppThemeMode fromId(String? id) {
    return AppThemeMode.values.firstWhere(
      (m) => m.id == id,
      orElse: () => AppThemeMode.dark,
    );
  }

  ThemeMode get toFlutterThemeMode {
    switch (this) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}
