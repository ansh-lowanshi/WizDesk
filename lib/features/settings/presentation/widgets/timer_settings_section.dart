import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../domain/models/user_preferences_model.dart';

/// Timer Configuration Card for Work, Short Break, Long Break, Interval & Auto-Start
class TimerSettingsSection extends StatelessWidget {
  final UserPreferencesModel preferences;
  final ValueChanged<UserPreferencesModel> onChanged;

  const TimerSettingsSection({
    super.key,
    required this.preferences,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
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
                  color: AppColors.accentCyan.withAlpha(30),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.timer_rounded,
                  size: 18.r,
                  color: AppColors.accentCyan,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Focus Timer Setup', style: AppTypography.heading3),
                    Text(
                      'Customize your Pomodoro intervals',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // 1. Work Duration Slider
          _buildDurationSlider(
            label: 'Deep Focus Duration',
            subtitle: 'Target concentration block',
            valueMinutes: preferences.workDurationMinutes,
            min: 5,
            max: 60,
            step: 5,
            accentColor: AppColors.primary,
            onChanged: (val) {
              onChanged(preferences.copyWith(workDurationMinutes: val));
            },
          ),

          Divider(color: AppColors.divider, height: 24),

          // 2. Short Break Duration Slider
          _buildDurationSlider(
            label: 'Short Break Duration',
            subtitle: 'Rest between focus sessions',
            valueMinutes: preferences.shortBreakMinutes,
            min: 1,
            max: 15,
            step: 1,
            accentColor: AppColors.accentCyan,
            onChanged: (val) {
              onChanged(preferences.copyWith(shortBreakMinutes: val));
            },
          ),

          Divider(color: AppColors.divider, height: 24),

          // 3. Long Break Duration Slider
          _buildDurationSlider(
            label: 'Long Break Duration',
            subtitle: 'Extended rest after a complete cycle set',
            valueMinutes: preferences.longBreakMinutes,
            min: 5,
            max: 45,
            step: 5,
            accentColor: AppColors.accentPurple,
            onChanged: (val) {
              onChanged(preferences.copyWith(longBreakMinutes: val));
            },
          ),

          Divider(color: AppColors.divider, height: 24),

          // 4. Long Break Interval (Cycles)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Long Break Interval', style: AppTypography.titleSmall),
                    Text(
                      'Number of focus sessions before long break',
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
                    onTap: preferences.longBreakInterval > 2
                        ? () => onChanged(preferences.copyWith(
                            longBreakInterval:
                                preferences.longBreakInterval - 1))
                        : null,
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    '${preferences.longBreakInterval} cycles',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.accentCyan,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  _buildStepperButton(
                    icon: Icons.add_rounded,
                    onTap: preferences.longBreakInterval < 8
                        ? () => onChanged(preferences.copyWith(
                            longBreakInterval:
                                preferences.longBreakInterval + 1))
                        : null,
                  ),
                ],
              ),
            ],
          ),

          Divider(color: AppColors.divider, height: 24),

          // 5. Auto-start Breaks Toggle
          _buildSwitchRow(
            title: 'Auto-Start Breaks',
            subtitle: 'Automatically start break timer when focus completes',
            value: preferences.autoStartBreaks,
            onChanged: (val) {
              onChanged(preferences.copyWith(autoStartBreaks: val));
            },
          ),

          SizedBox(height: 12.h),

          // 6. Auto-start Pomodoros Toggle
          _buildSwitchRow(
            title: 'Auto-Start Focus',
            subtitle: 'Automatically start focus timer when break completes',
            value: preferences.autoStartPomodoros,
            onChanged: (val) {
              onChanged(preferences.copyWith(autoStartPomodoros: val));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSlider({
    required String label,
    required String subtitle,
    required int valueMinutes,
    required int min,
    required int max,
    required int step,
    required Color accentColor,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.titleSmall),
                  Text(subtitle, style: AppTypography.caption),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: accentColor.withAlpha(30),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                '$valueMinutes min',
                style: AppTypography.titleSmall.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: accentColor,
            inactiveTrackColor: AppColors.surfaceLight,
            thumbColor: Colors.white,
            overlayColor: accentColor.withAlpha(40),
            trackHeight: 4.h,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7.r),
          ),
          child: Slider(
            value: valueMinutes.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: (max - min) ~/ step,
            onChanged: (val) => onChanged(val.round()),
          ),
        ),
      ],
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

  Widget _buildSwitchRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.bodyMedium),
              Text(subtitle, style: AppTypography.caption),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          activeThumbColor: AppColors.accentCyan,
          activeTrackColor: AppColors.accentCyan.withAlpha(100),
          inactiveTrackColor: AppColors.surfaceElevated,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
