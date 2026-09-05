import 'package:flutter/material.dart';

/// Wiz Desk Design System Color Palette
/// Dynamic theme palette supporting sleek dark mode and crisp modern light mode
class AppColors {
  /// Global active theme mode flag, synchronized with MaterialApp theme
  static bool isDarkMode = true;

  // Backgrounds
  static Color get background =>
      isDarkMode ? const Color(0xFF080C1E) : const Color(0xFFF8FAFC);
  static Color get backgroundSecondary =>
      isDarkMode ? const Color(0xFF0D1432) : const Color(0xFFF1F5F9);
  static Color get surface =>
      isDarkMode ? const Color(0xFF131C42) : const Color(0xFFFFFFFF);
  static Color get surfaceElevated =>
      isDarkMode ? const Color(0xFF182352) : const Color(0xFFF8FAFC);
  static Color get surfaceLight =>
      isDarkMode ? const Color(0xFF1F2D68) : const Color(0xFFEDF2F7);

  // Primary & Neon Accents (Consistent brand identity)
  static const Color primary = Color(0xFF3874FF);
  static const Color primaryLight = Color(0xFF5A8DFF);
  static const Color primaryDark = Color(0xFF1A56DB);
  static const Color accentCyan = Color(0xFF00F0FF);
  static const Color accentCyanGlow = Color(0x6600F0FF);
  static const Color accentPurple = Color(0xFF7F56D9);
  static const Color accentIndigo = Color(0xFF6366F1);

  // Status & Priority Colors
  static const Color priorityUrgent = Color(0xFFFF4D4D);
  static const Color priorityHigh = Color(0xFFFF6B6B);
  static const Color priorityMedium = Color(0xFFFFB020);
  static const Color priorityLow = Color(0xFF10B981);

  // Task Status Colors
  static const Color statusTodo = Color(0xFF94A3B8);
  static const Color statusInProgress = Color(0xFF3874FF);
  static const Color statusCompleted = Color(0xFF00E5FF);
  static const Color statusArchived = Color(0xFF64748B);

  // Text & Content Colors
  static Color get textPrimary =>
      isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF0F172A);
  static Color get textSecondary =>
      isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF475569);
  static Color get textMuted =>
      isDarkMode ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
  static Color get textTertiary =>
      isDarkMode ? const Color(0xFF475569) : const Color(0xFFCBD5E1);

  // Borders, Dividers & Cards
  static Color get border =>
      isDarkMode ? const Color(0xFF222F5E) : const Color(0xFFE2E8F0);
  static Color get borderLight =>
      isDarkMode ? const Color(0xFF2E3E7A) : const Color(0xFFCBD5E1);
  static Color get borderHighlight => const Color(0xFF3874FF);
  static Color get divider =>
      isDarkMode ? const Color(0xFF1A244D) : const Color(0xFFE2E8F0);

  // Feedback Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3874FF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF3874FF), Color(0xFF00F0FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get cardGradient => LinearGradient(
        colors: isDarkMode
            ? [const Color(0xFF141D45), const Color(0xFF0E1636)]
            : [const Color(0xFFFFFFFF), const Color(0xFFF8FAFC)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static const LinearGradient timerProgressGradient = LinearGradient(
    colors: [Color(0xFF00F0FF), Color(0xFF3874FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient glowButtonGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF3874FF), Color(0xFF00D4FF)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static LinearGradient get darkOverlayGradient => LinearGradient(
        colors: isDarkMode
            ? [Colors.transparent, const Color(0xFF080C1E)]
            : [Colors.transparent, const Color(0xFFF8FAFC)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
}
