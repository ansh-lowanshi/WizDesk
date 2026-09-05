import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glassmorphic_card.dart';

/// About App Section with Branding & Feature Highlights
class AboutAppSection extends StatelessWidget {
  const AboutAppSection({super.key});

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
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  width: 46.r,
                  height: 46.r,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: Image.asset(
                    AppConstants.appLogo,
                    width: 46.r,
                    height: 46.r,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                      ),
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        size: 22.r,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppConstants.appName, style: AppTypography.heading3),
                    SizedBox(height: 2.h),
                    Text(
                      '${AppConstants.appTagline} • v1.0.0',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.isDarkMode
                            ? AppColors.accentCyan
                            : AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _buildFeatureBullet(
                  icon: Icons.shield_outlined,
                  text: '100% Offline-First & Private (Hive Storage)',
                ),
                SizedBox(height: 8.h),
                _buildFeatureBullet(
                  icon: Icons.timer_outlined,
                  text: 'Deep Focus Pomodoro Engine & Zen Mode',
                ),
                SizedBox(height: 8.h),
                _buildFeatureBullet(
                  icon: Icons.insights_rounded,
                  text: 'Rich FL Chart Productivity Analytics',
                ),
                SizedBox(height: 8.h),
                _buildFeatureBullet(
                  icon: Icons.font_download_outlined,
                  text: 'Dynamic Google Typography Engine',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBullet({
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14.r, color: AppColors.accentCyan),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11.sp,
            ),
          ),
        ),
      ],
    );
  }
}
