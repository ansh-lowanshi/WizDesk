import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/settings/domain/models/app_font_family.dart';
import 'app_colors.dart';

/// Wiz Desk Centralized Typography System
///
/// Designed to be ultra-clean, modern, and focused for productivity.
/// Easily switchable at runtime via [currentFontFamily] and [AppFontFamily].
class AppTypography {
  /// Currently active global font family
  static AppFontFamily currentFontFamily = AppFontFamily.plusJakartaSans;

  /// Dynamic font builder based on [currentFontFamily]
  static TextStyle Function({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) get primaryFontBuilder {
    switch (currentFontFamily) {
      case AppFontFamily.spaceGrotesk:
        return GoogleFonts.spaceGrotesk;
      case AppFontFamily.inter:
        return GoogleFonts.inter;
      case AppFontFamily.outfit:
        return GoogleFonts.outfit;
      case AppFontFamily.plusJakartaSans:
        return GoogleFonts.plusJakartaSans;
    }
  }

  /// Dedicated font for Focus Timer countdown numerals (modern geometric look)
  static TextStyle Function({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) get timerFontBuilder => GoogleFonts.spaceGrotesk;

  /// Helper factory to generate standardized text styles
  static TextStyle _style({
    required double fontSize,
    required FontWeight fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    return primaryFontBuilder(
      fontSize: fontSize.sp,
      fontWeight: fontWeight,
      color: color ?? AppColors.textPrimary,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
  }

  // Display & Hero Titles
  static TextStyle get displayLarge => _style(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      );

  static TextStyle get displayMedium => _style(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      );

  // Headlines
  static TextStyle get heading1 => _style(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      );

  static TextStyle get heading2 => _style(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      );

  static TextStyle get heading3 => _style(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      );

  // Section Headers & Card Titles
  static TextStyle get titleLarge => _style(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get titleMedium => _style(
        fontSize: 15,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get titleSmall => _style(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      );

  // Body Content
  static TextStyle get bodyLarge => _style(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get bodyMedium => _style(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get bodySmall => _style(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
      );

  // Captions & Microcopy
  static TextStyle get caption => _style(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
        letterSpacing: 0.2,
      );

  static TextStyle get captionBold => _style(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
        letterSpacing: 0.2,
      );

  static TextStyle get badge => _style(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      );

  // Button Labels
  static TextStyle get buttonLarge => _style(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 0.2,
      );

  static TextStyle get buttonMedium => _style(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  static TextStyle get buttonSmall => _style(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  // Pomodoro Focus Timer Display Digits
  static TextStyle timerDisplay({
    double fontSize = 48,
    Color? color,
  }) {
    return timerFontBuilder(
      fontSize: fontSize.sp,
      fontWeight: FontWeight.w700,
      color: color ?? AppColors.textPrimary,
      letterSpacing: -1.0,
    );
  }

  static TextStyle timerDisplayFullscreen({
    double fontSize = 72,
    Color color = AppColors.accentCyan,
  }) {
    return timerFontBuilder(
      fontSize: fontSize.sp,
      fontWeight: FontWeight.w800,
      color: color,
      letterSpacing: -1.5,
      shadows: [
        Shadow(
          color: AppColors.accentCyanGlow,
          blurRadius: 24,
        ),
      ],
    );
  }
}
