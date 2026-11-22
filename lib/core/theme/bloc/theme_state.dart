import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../features/settings/domain/models/app_theme_mode.dart';
import '../app_theme.dart';

class ThemeState extends Equatable {
  final AppThemeMode themeMode;
  final bool isDarkMode;

  const ThemeState({
    this.themeMode = AppThemeMode.dark,
    this.isDarkMode = true,
  });

  ThemeData get themeData =>
      isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

  ThemeState copyWith({
    AppThemeMode? themeMode,
    bool? isDarkMode,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  @override
  List<Object?> get props => [themeMode, isDarkMode];
}
