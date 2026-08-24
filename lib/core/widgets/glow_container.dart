import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';

/// A sleek container with configurable neon glow effects
class GlowContainer extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final Color? backgroundColor;
  final double blurRadius;
  final double spreadRadius;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Border? border;
  final bool isCircle;

  const GlowContainer({
    super.key,
    required this.child,
    this.glowColor = AppColors.primary,
    this.backgroundColor,
    this.blurRadius = 16,
    this.spreadRadius = 1,
    this.borderRadius,
    this.padding,
    this.margin,
    this.border,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(borderRadius?.r ?? 16.r),
        border: border ??
            Border.all(
              color: glowColor.withAlpha(80),
              width: 1.0,
            ),
        boxShadow: [
          BoxShadow(
            color: glowColor.withAlpha(50),
            blurRadius: blurRadius,
            spreadRadius: spreadRadius,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
