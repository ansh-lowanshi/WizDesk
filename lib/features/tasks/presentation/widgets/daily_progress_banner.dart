import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../../../core/widgets/glow_container.dart';

/// Top Dashboard Banner displaying daily goal progress, task completion metrics & focus minutes
class DailyProgressBanner extends StatelessWidget {
  final int completedTasks;
  final int totalTasks;
  final int totalFocusMinutes;
  final VoidCallback? onBannerTap;

  const DailyProgressBanner({
    super.key,
    required this.completedTasks,
    required this.totalTasks,
    this.totalFocusMinutes = 0,
    this.onBannerTap,
  });

  @override
  Widget build(BuildContext context) {
    final double percentage = totalTasks > 0
        ? (completedTasks / totalTasks).clamp(0.0, 1.0)
        : 0.0;
    final int percentInt = (percentage * 100).toInt();

    final accentColor = AppColors.isDarkMode
        ? AppColors.accentCyan
        : AppColors.primary;

    return GlassmorphicCard(
      gradient: AppColors.cardGradient,
      borderColor: AppColors.borderLight,
      padding: EdgeInsets.all(18.r),
      onTap: onBannerTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Column: Progress text & metric pills
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: AppDecorations.badge(color: accentColor),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome_rounded,
                              size: 13.r,
                              color: accentColor,
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              'TODAY\'S PROGRESS',
                              style: AppTypography.badge.copyWith(
                                color: accentColor,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      '$completedTasks of $totalTasks Tasks Done',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 16.w),

              // Right: Glowing Circular Progress Indicator
              Stack(
                alignment: Alignment.center,
                children: [
                  GlowContainer(
                    isCircle: true,
                    glowColor: accentColor,
                    blurRadius: 18,
                    spreadRadius: 1,
                    backgroundColor: AppColors.surfaceElevated,
                    child: SizedBox(
                      width: 68.r,
                      height: 68.r,
                      child: CircularProgressIndicator(
                        value: percentage,
                        strokeWidth: 6.r,
                        backgroundColor: AppColors.surfaceLight,
                        valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                  ),
                  Text(
                    '$percentInt%',
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 14.h),

          // Bottom Metric Pills
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.background.withAlpha(140),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border, width: 0.8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    icon: Icons.check_circle_outline_rounded,
                    color: AppColors.success,
                    label: 'Completed',
                    value: '$completedTasks',
                  ),
                ),
                Container(width: 1, height: 20.h, color: AppColors.divider),
                Expanded(
                  child: _buildMetricItem(
                    icon: Icons.pending_actions_rounded,
                    color: AppColors.warning,
                    label: 'Remaining',
                    value: '${totalTasks - completedTasks}',
                  ),
                ),
                Container(width: 1, height: 20.h, color: AppColors.divider),
                Expanded(
                  child: _buildMetricItem(
                    icon: Icons.timer_outlined,
                    color: AppColors.primaryLight,
                    label: 'Focus Time',
                    value: DateTimeFormatter.formatDurationMinutes(
                      totalFocusMinutes,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16.r, color: color),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  label,
                  style: AppTypography.caption.copyWith(fontSize: 10.sp),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
