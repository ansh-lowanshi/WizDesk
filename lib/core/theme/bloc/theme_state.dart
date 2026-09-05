import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../features/settings/domain/models/app_font_family.dart';
import '../../../features/settings/domain/models/app_theme_mode.dart';
import '../app_theme.dart';

class ThemeState extends Equatable {
  final AppThemeMode themeMode;
  final AppFontFamily fontFamily;
  final bool isDarkMode;

  const ThemeState({
    this.themeMode = AppThemeMode.dark,
    this.fontFamily = AppFontFamily.plusJakartaSans,
    this.isDarkMode = true,
  });

  ThemeData get themeData =>
      isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

  ThemeState copyWith({
    AppThemeMode? themeMode,
    AppFontFamily? fontFamily,
    bool? isDarkMode,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      fontFamily: fontFamily ?? this.fontFamily,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  @override
  List<Object?> get props => [themeMode, fontFamily, isDarkMode];
}
