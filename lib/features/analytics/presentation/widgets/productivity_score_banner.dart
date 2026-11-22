import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../../../core/widgets/glow_container.dart';
import '../../domain/models/analytics_data.dart';

/// Hero Banner displaying Productivity Score & Streak Highlights
class ProductivityScoreBanner extends StatelessWidget {
  final AnalyticsSummary summary;

  const ProductivityScoreBanner({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final score = summary.productivityScore;
    final streak = summary.currentStreakDays;

    final Color scoreColor = score >= 80
        ? AppColors.accentCyan
        : score >= 50
            ? AppColors.primary
            : AppColors.accentPurple;

    final String scoreTitle = score >= 85
        ? context.l10n.peakProductivity
        : score >= 70
            ? context.l10n.strongMomentum
            : score >= 50
                ? context.l10n.steadyProgress
                : context.l10n.gettingStarted;

    return GlowContainer(
      glowColor: scoreColor,
      blurRadius: 20,
      spreadRadius: 0,
      borderRadius: 20,
      child: GlassmorphicCard(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
        borderRadius: 20.r,
        borderColor: scoreColor.withAlpha(90),
        child: Row(
          children: [
            // Glowing Circular Score Indicator
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 72.r,
                  height: 72.r,
                  child: CircularProgressIndicator(
                    value: (score / 100).clamp(0.0, 1.0),
                    strokeWidth: 6.r,
                    backgroundColor: AppColors.surfaceElevated,
                    valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$score',
                      style: AppTypography.heading2.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '/100',
                      style: AppTypography.caption.copyWith(
                        fontSize: 9.sp,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(width: 16.w),

            // Score description and streak
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          scoreTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${summary.totalTasksCompleted} ${context.l10n.tasksDone.toLowerCase()} • ${summary.formattedTotalFocusTime} ${context.l10n.focusTime.toLowerCase()}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // Streak and Best Day Pills
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 6.h,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration: AppDecorations.badge(
                          color: AppColors.warning,
                          borderRadius: 12.r,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🔥'),
                            SizedBox(width: 4.w),
                            Text(
                              '$streak ${context.l10n.streakDays}',
                              style: AppTypography.badge.copyWith(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (summary.bestDayLabel != 'N/A')
                        Container(
                          constraints: BoxConstraints(maxWidth: 180.w),
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: AppDecorations.badge(
                            color: AppColors.primary,
                            borderRadius: 12.r,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star_rounded,
                                  size: 13.r, color: AppColors.primaryLight),
                              SizedBox(width: 4.w),
                              Flexible(
                                child: Text(
                                  'Top: ${summary.bestDayLabel}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.badge.copyWith(
                                    color: AppColors.primaryLight,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
