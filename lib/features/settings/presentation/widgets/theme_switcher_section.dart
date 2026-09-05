import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../domain/models/app_theme_mode.dart';

/// Theme Switcher Section (Dark, Light, System Default)
class ThemeSwitcherSection extends StatelessWidget {
  final AppThemeMode selectedThemeMode;
  final ValueChanged<AppThemeMode> onThemeSelected;

  const ThemeSwitcherSection({
    super.key,
    required this.selectedThemeMode,
    required this.onThemeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.accentPurple.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.palette_rounded,
                  color: AppColors.accentPurple,
                  size: 18.r,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Appearance & Theme', style: AppTypography.heading3),
                    SizedBox(height: 2.h),
                    Text(
                      'Choose your preferred visual theme',
                      style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Theme Choice Options
          Row(
            children: AppThemeMode.values.map((mode) {
              final isSelected = selectedThemeMode == mode;
              return Expanded(
                child: GestureDetector(
                  key: ValueKey('theme_option_${mode.id}'),
                  onTap: () => onThemeSelected(mode),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withAlpha(35)
                          : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withAlpha(70),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          mode.icon,
                          size: 22.r,
                          color: isSelected
                              ? (AppColors.isDarkMode
                                  ? AppColors.accentCyan
                                  : AppColors.primary)
                              : AppColors.textSecondary,
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          mode.label,
                          style: AppTypography.caption.copyWith(
                            color: isSelected
                                ? (AppColors.isDarkMode
                                    ? Colors.white
                                    : AppColors.primary)
                                : AppColors.textSecondary,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 11.sp,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
