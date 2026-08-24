import 'package:flutter/material.dart';

/// Wiz Desk Design System Color Palette
/// Curated sleek dark mode with neon cyan and electric blue accents
class AppColors {
  // Backgrounds
  static const Color background = Color(0xFF080C1E);
  static const Color backgroundSecondary = Color(0xFF0D1432);
  static const Color surface = Color(0xFF131C42);
  static const Color surfaceElevated = Color(0xFF182352);
  static const Color surfaceLight = Color(0xFF1F2D68);

  // Primary & Neon Accents
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
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF475569);

  // Borders, Dividers & Cards
  static const Color border = Color(0xFF222F5E);
  static const Color borderLight = Color(0xFF2E3E7A);
  static const Color borderHighlight = Color(0xFF3874FF);
  static const Color divider = Color(0xFF1A244D);

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

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF141D45), Color(0xFF0E1636)],
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

  static const LinearGradient darkOverlayGradient = LinearGradient(
    colors: [Colors.transparent, Color(0xFF080C1E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
