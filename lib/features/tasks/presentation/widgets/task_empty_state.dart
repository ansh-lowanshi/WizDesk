import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glow_container.dart';

/// Distraction-free empty state display for empty task lists
class TaskEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onActionTap;
  final String? actionLabel;

  const TaskEmptyState({
    super.key,
    this.title = 'No Tasks Found',
    this.subtitle =
        'Everything looks clear! Create a task or switch your active filters.',
    this.icon = Icons.check_circle_outline_rounded,
    this.onActionTap,
    this.actionLabel = 'Add New Task',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GlowContainer(
              isCircle: true,
              padding: EdgeInsets.all(18.r),
              glowColor: AppColors.accentCyan,
              blurRadius: 24,
              backgroundColor: AppColors.surfaceElevated,
              child: Icon(icon, size: 34.r, color: AppColors.accentCyan),
            ),
            SizedBox(height: 14.h),
            Text(
              title,
              style: AppTypography.heading3.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6.h),
            Text(
              subtitle,
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
            if (onActionTap != null && actionLabel != null) ...[
              SizedBox(height: 16.h),
              ElevatedButton.icon(
                onPressed: onActionTap,
                icon: Icon(Icons.add_rounded, size: 18.r),
                label: Text(
                  actionLabel!.replaceFirst(RegExp(r'^\+\s*'), ''),
                  style: AppTypography.buttonMedium,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
