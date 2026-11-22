import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../../tasks/domain/entities/focus_session_entity.dart';

/// Card listing recent focus session entries
class RecentSessionsCard extends StatelessWidget {
  final List<FocusSessionEntity> sessions;

  const RecentSessionsCard({
    super.key,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      borderRadius: 20.r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  context.l10n.recentFocusLogs,
                  style: AppTypography.heading3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              Text('${sessions.length}', style: AppTypography.caption),
            ],
          ),
          SizedBox(height: 14.h),
          if (sessions.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Center(
                child: Text(
                  context.l10n.noSessionsRecorded,
                  style: AppTypography.caption,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sessions.length,
              separatorBuilder: (context, index) => SizedBox(height: 8.h),
              itemBuilder: (context, index) {
                final session = sessions[index];
                final isWork = session.sessionType.toLowerCase().contains('work') ||
                    session.sessionType.toLowerCase().contains('focus');
                final Color badgeColor =
                    isWork ? AppColors.accentCyan : AppColors.accentPurple;

                final timeStr =
                    DateFormat('MMM d, h:mm a').format(session.startTime);

                return Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.border, width: 0.8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(7.r),
                        decoration: BoxDecoration(
                          color: badgeColor.withAlpha(30),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isWork
                              ? Icons.bolt_rounded
                              : Icons.coffee_rounded,
                          size: 14.r,
                          color: badgeColor,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isWork ? 'Deep Focus Session' : 'Rest Break',
                              style: AppTypography.titleSmall.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(timeStr, style: AppTypography.caption),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.h),
                        decoration: AppDecorations.badge(
                          color: badgeColor,
                          borderRadius: 8.r,
                        ),
                        child: Text(
                          '+${session.durationMinutes}m',
                          style: AppTypography.badge.copyWith(
                            color: badgeColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
