import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';

/// Modern semi-translucent card container supporting both dark & light modes
class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;
  final Gradient? gradient;

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.onTap,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBgColor = backgroundColor ??
        (AppColors.isDarkMode
            ? AppColors.surface.withAlpha(220)
            : AppColors.surface);

    final cardContent = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: effectiveBgColor,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius?.r ?? 18.r),
        border: Border.all(
          color: borderColor ?? AppColors.border,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.isDarkMode
                ? Colors.black.withAlpha(70)
                : Colors.black.withAlpha(12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius?.r ?? 18.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius?.r ?? 18.r),
          splashColor: AppColors.primary.withAlpha(35),
          highlightColor: AppColors.primary.withAlpha(15),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
