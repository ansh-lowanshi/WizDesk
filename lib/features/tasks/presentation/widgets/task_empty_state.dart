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
    this.subtitle = 'Everything looks clear! Create a task or switch your active filters.',
    this.icon = Icons.check_circle_outline_rounded,
    this.onActionTap,
    this.actionLabel = '+ Add New Task',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GlowContainer(
              isCircle: true,
              padding: EdgeInsets.all(24.r),
              glowColor: AppColors.accentCyan,
              blurRadius: 28,
              backgroundColor: AppColors.surfaceElevated,
              child: Icon(
                icon,
                size: 40.r,
                color: AppColors.accentCyan,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              title,
              style: AppTypography.heading3.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
            if (onActionTap != null && actionLabel != null) ...[
              SizedBox(height: 20.h),
              ElevatedButton.icon(
                onPressed: onActionTap,
                icon: Icon(Icons.add_rounded, size: 18.r),
                label: Text(actionLabel!, style: AppTypography.buttonMedium),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
