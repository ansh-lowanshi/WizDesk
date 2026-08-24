import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

/// Wiz Desk Reusable BoxDecorations, Shadows, and Card Styles
class AppDecorations {
  // Standard Card Decoration
  static BoxDecoration card({
    Color? color,
    Color? borderColor,
    double? borderRadius,
    List<BoxShadow>? shadows,
    Gradient? gradient,
  }) {
    return BoxDecoration(
      color: color ?? AppColors.surface,
      gradient: gradient,
      borderRadius: BorderRadius.circular(borderRadius?.r ?? 16.r),
      border: Border.all(
        color: borderColor ?? AppColors.border,
        width: 1.0,
      ),
      boxShadow: shadows ??
          [
            BoxShadow(
              color: Colors.black.withAlpha(50),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
    );
  }

  // Highlight / Selected Card Decoration with Cyan/Blue Glow
  static BoxDecoration cardHighlighted({
    double? borderRadius,
  }) {
    return BoxDecoration(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(borderRadius?.r ?? 16.r),
      border: Border.all(
        color: AppColors.primaryLight,
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withAlpha(70),
          blurRadius: 16,
          spreadRadius: 1,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Glowing Circle for Pomodoro Timer
  static BoxDecoration timerGlowRing({
    required Color glowColor,
  }) {
    return BoxDecoration(
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: glowColor.withAlpha(80),
          blurRadius: 40,
          spreadRadius: 8,
        ),
      ],
    );
  }

  // Primary Button Glowing Decoration
  static BoxDecoration glowButton({
    double? borderRadius,
    Gradient? gradient,
  }) {
    return BoxDecoration(
      gradient: gradient ?? AppColors.glowButtonGradient,
      borderRadius: BorderRadius.circular(borderRadius?.r ?? 14.r),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withAlpha(100),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  // Circular Action Button (e.g. Play / Pause / Check)
  static BoxDecoration circularActionButton({
    required Color color,
    Color? glowColor,
  }) {
    return BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      boxShadow: [
        if (glowColor != null)
          BoxShadow(
            color: glowColor.withAlpha(120),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
      ],
    );
  }

  // Tag / Badge Decoration
  static BoxDecoration badge({
    required Color color,
    double? borderRadius,
  }) {
    return BoxDecoration(
      color: color.withAlpha(35),
      borderRadius: BorderRadius.circular(borderRadius?.r ?? 8.r),
      border: Border.all(
        color: color.withAlpha(90),
        width: 1,
      ),
    );
  }

  // Bottom Navigation Bar Glass Container
  static BoxDecoration bottomNav() {
    return BoxDecoration(
      color: AppColors.surface.withAlpha(240),
      borderRadius: BorderRadius.circular(24.r),
      border: Border.all(
        color: AppColors.border,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(120),
          blurRadius: 24,
          offset: const Offset(0, -4),
        ),
      ],
    );
  }
}
