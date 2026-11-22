import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../domain/models/analytics_data.dart';

/// 4-Grid Responsive KPI Metrics Cards
class ProductivityMetricCards extends StatelessWidget {
  final AnalyticsSummary summary;

  const ProductivityMetricCards({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = (constraints.maxWidth - 12.w) / 2;

        return Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: [
            // 1. Focus Time
            _buildMetricCard(
              width: cardWidth,
              icon: Icons.timer_outlined,
              iconColor: AppColors.accentCyan,
              label: context.l10n.totalFocus,
              value: summary.formattedTotalFocusTime,
              subtitle: '${summary.totalFocusSessions} ${context.l10n.sessionsCompleted.toLowerCase()}',
            ),

            // 2. Tasks Completed
            _buildMetricCard(
              width: cardWidth,
              icon: Icons.check_circle_outline_rounded,
              iconColor: AppColors.success,
              label: context.l10n.completed,
              value: '${summary.totalTasksCompleted}',
              subtitle: 'of ${summary.totalTasksCreated} ${context.l10n.tasksWord.toLowerCase()}',
            ),

            // 3. Completion Rate
            _buildMetricCard(
              width: cardWidth,
              icon: Icons.pie_chart_outline_rounded,
              iconColor: AppColors.primary,
              label: context.l10n.completionRate,
              value:
                  '${summary.completionRatePercentage.toStringAsFixed(0)}%',
              subtitle: summary.completionRatePercentage >= 80
                  ? context.l10n.highEfficiency
                  : context.l10n.targetEfficiency,
            ),

            // 4. Focus Cycles
            _buildMetricCard(
              width: cardWidth,
              icon: Icons.bolt_rounded,
              iconColor: AppColors.warning,
              label: context.l10n.round,
              value: '${summary.totalFocusSessions}',
              subtitle: '${summary.currentStreakDays} ${context.l10n.streakDays.toLowerCase()}',
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard({
    required double width,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String subtitle,
  }) {
    return SizedBox(
      width: width,
      child: GlassmorphicCard(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        borderRadius: 16.r,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(7.r),
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha(35),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(icon, size: 18.r, color: iconColor),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 11.sp,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              value,
              style: AppTypography.heading2.copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              subtitle,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10.5.sp,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
