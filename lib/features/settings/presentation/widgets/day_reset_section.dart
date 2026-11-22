import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glassmorphic_card.dart';

/// Day Reset / Night Owl Cutoff Configuration Section
class DayResetSection extends StatelessWidget {
  final int selectedResetHour;
  final ValueChanged<int> onResetHourSelected;

  const DayResetSection({
    super.key,
    required this.selectedResetHour,
    required this.onResetHourSelected,
  });

  static const List<Map<String, dynamic>> _resetOptions = [
    {'hour': 0, 'label': '12:00 AM', 'subtitle': 'Default Midnight'},
    {'hour': 1, 'label': '1:00 AM', 'subtitle': '+1h cutoff'},
    {'hour': 2, 'label': '2:00 AM', 'subtitle': 'Night Owl'},
    {'hour': 3, 'label': '3:00 AM', 'subtitle': '+3h cutoff'},
    {'hour': 4, 'label': '4:00 AM', 'subtitle': '+4h cutoff'},
    {'hour': 5, 'label': '5:00 AM', 'subtitle': 'Early Riser'},
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

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
                  color: AppColors.accentCyan.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.nightlight_round,
                  color: AppColors.accentCyan,
                  size: 18.r,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.dayResetTitle, style: AppTypography.heading3),
                    SizedBox(height: 2.h),
                    Text(
                      l10n.dayResetSubtitle,
                      style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // Horizontal choices for Reset Hour
          SizedBox(
            height: 58.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _resetOptions.length,
              separatorBuilder: (context, index) => SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                final option = _resetOptions[index];
                final int hour = option['hour'] as int;
                final String label = option['label'] as String;
                final String subtitle = option['subtitle'] as String;
                final isSelected = selectedResetHour == hour;

                return GestureDetector(
                  key: ValueKey('reset_hour_opt_$hour'),
                  onTap: () => onResetHourSelected(hour),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          label,
                          style: AppTypography.buttonMedium.copyWith(
                            color: isSelected
                                ? (AppColors.isDarkMode
                                    ? Colors.white
                                    : AppColors.primary)
                                : AppColors.textSecondary,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 12.sp,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          subtitle,
                          style: AppTypography.caption.copyWith(
                            color: isSelected
                                ? (AppColors.isDarkMode
                                    ? AppColors.accentCyan
                                    : AppColors.primary)
                                : AppColors.textMuted,
                            fontSize: 9.5.sp,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
