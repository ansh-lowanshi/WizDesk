import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../../../core/widgets/glow_container.dart';
import '../../domain/models/user_preferences_model.dart';

/// User Profile Hero Banner with Avatar, Name, Title, and Badges
class ProfileHeroCard extends StatelessWidget {
  final UserPreferencesModel preferences;
  final int totalCompletedTasks;
  final int totalFocusMinutes;
  final VoidCallback onEditProfile;

  const ProfileHeroCard({
    super.key,
    required this.preferences,
    required this.totalCompletedTasks,
    required this.totalFocusMinutes,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    final focusHours = (totalFocusMinutes / 60).toStringAsFixed(1);

    return GlowContainer(
      glowColor: AppColors.primary,
      blurRadius: 18,
      spreadRadius: 0,
      borderRadius: 20,
      child: GlassmorphicCard(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
        borderRadius: 20.r,
        borderColor: AppColors.borderLight,
        child: Column(
          children: [
            Row(
              children: [
                // Avatar with Neon Ring
                GlowContainer(
                  isCircle: true,
                  glowColor: AppColors.accentCyan,
                  blurRadius: 12,
                  spreadRadius: 1,
                  child: Container(
                    width: 58.r,
                    height: 58.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                    ),
                    child: Center(
                      child: Text(
                        preferences.userName.isNotEmpty
                            ? preferences.userName[0].toUpperCase()
                            : 'W',
                        style: AppTypography.heading1.copyWith(
                          fontSize: 24.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 16.w),

                // Name & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              preferences.userName,
                              style: AppTypography.heading2.copyWith(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.edit_rounded,
                              size: 18.r,
                              color: AppColors.accentCyan,
                            ),
                            tooltip: 'Edit Profile',
                            onPressed: onEditProfile,
                          ),
                        ],
                      ),
                      Text(
                        preferences.userTitle,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.accentCyan,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Metrics Summary Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TASKS COMPLETED',
                          style: AppTypography.caption.copyWith(
                            fontSize: 9.5.sp,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '$totalCompletedTasks',
                          style: AppTypography.heading3.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL FOCUS',
                          style: AppTypography.caption.copyWith(
                            fontSize: 9.5.sp,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '${focusHours}h',
                          style: AppTypography.heading3.copyWith(
                            color: AppColors.accentCyan,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
