import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../domain/models/user_preferences_model.dart';

/// Productivity Goals Settings Section (Daily Task Goal & Focus Time Target)
class GoalsSettingsSection extends StatelessWidget {
  final UserPreferencesModel preferences;
  final ValueChanged<UserPreferencesModel> onChanged;

  const GoalsSettingsSection({
    super.key,
    required this.preferences,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final focusHours = (preferences.dailyFocusMinutesGoal / 60).toStringAsFixed(1);

    return GlassmorphicCard(
      padding: EdgeInsets.all(16.r),
      borderRadius: 20.r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha(30),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.flag_rounded,
                  size: 18.r,
                  color: AppColors.success,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.goalsTargetsTitle, style: AppTypography.heading3),
                    Text(
                      l10n.goalsTargetsSubtitle,
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // 1. Daily Task Completion Goal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.dailyTaskGoal, style: AppTypography.titleSmall),
                    Text(
                      l10n.completedTasksMilestonePerDay,
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStepperButton(
                    icon: Icons.remove_rounded,
                    onTap: preferences.dailyTaskGoal > 1
                        ? () => onChanged(preferences.copyWith(
                            dailyTaskGoal: preferences.dailyTaskGoal - 1))
                        : null,
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    '${preferences.dailyTaskGoal} ${l10n.tasksWord.toLowerCase()}',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  _buildStepperButton(
                    icon: Icons.add_rounded,
                    onTap: preferences.dailyTaskGoal < 20
                        ? () => onChanged(preferences.copyWith(
                            dailyTaskGoal: preferences.dailyTaskGoal + 1))
                        : null,
                  ),
                ],
              ),
            ],
          ),

          Divider(color: AppColors.divider, height: 24),

          // 2. Daily Focus Time Target
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.dailyFocusGoal, style: AppTypography.titleSmall),
                    Text(
                      l10n.targetDeepWorkHoursPerDay,
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStepperButton(
                    icon: Icons.remove_rounded,
                    onTap: preferences.dailyFocusMinutesGoal > 30
                        ? () => onChanged(preferences.copyWith(
                            dailyFocusMinutesGoal:
                                preferences.dailyFocusMinutesGoal - 30))
                        : null,
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    '${focusHours}h',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.accentCyan,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  _buildStepperButton(
                    icon: Icons.add_rounded,
                    onTap: preferences.dailyFocusMinutesGoal < 480
                        ? () => onChanged(preferences.copyWith(
                            dailyFocusMinutesGoal:
                                preferences.dailyFocusMinutesGoal + 30))
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    final isEnabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.all(6.r),
        decoration: BoxDecoration(
          color: isEnabled
              ? AppColors.surfaceElevated
              : AppColors.surfaceElevated.withAlpha(50),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isEnabled ? AppColors.border : AppColors.border.withAlpha(50),
          ),
        ),
        child: Icon(
          icon,
          size: 16.r,
          color: isEnabled ? AppColors.textPrimary : AppColors.textMuted,
        ),
      ),
    );
  }
}
