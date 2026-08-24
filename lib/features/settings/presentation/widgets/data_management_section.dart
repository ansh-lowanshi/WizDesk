import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glassmorphic_card.dart';

/// Data Management & Danger Zone Section (Reset Settings & Clear Data)
class DataManagementSection extends StatelessWidget {
  final VoidCallback onResetSettings;
  final VoidCallback onClearAllData;

  const DataManagementSection({
    super.key,
    required this.onResetSettings,
    required this.onClearAllData,
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
                  color: AppColors.warning.withAlpha(30),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.storage_rounded,
                  size: 18.r,
                  color: AppColors.warning,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Data & Preferences', style: AppTypography.heading3),
                    Text(
                      'Manage local storage and reset configurations',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // 1. Reset Settings to Defaults
          InkWell(
            onTap: () => _confirmResetDialog(context),
            borderRadius: BorderRadius.circular(14.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.restart_alt_rounded,
                      size: 20.r, color: AppColors.textPrimary),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Reset Settings to Defaults',
                            style: AppTypography.titleSmall),
                        Text(
                          'Restore default timers, fonts and targets',
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      size: 20.r, color: AppColors.textMuted),
                ],
              ),
            ),
          ),

          SizedBox(height: 10.h),

          // 2. Clear All Data (Danger)
          InkWell(
            onTap: () => _confirmClearDataDialog(context),
            borderRadius: BorderRadius.circular(14.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(20),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: AppColors.error.withAlpha(60)),
              ),
              child: Row(
                children: [
                  Icon(Icons.delete_forever_rounded,
                      size: 20.r, color: AppColors.error),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Clear All Tasks & Sessions',
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Permanently wipe local tasks, categories & focus history',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.error.withAlpha(180),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      size: 20.r, color: AppColors.error),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
        title: Text('Reset Settings?', style: AppTypography.heading3),
        content: Text(
          'This will reset your Pomodoro timers, typography, and goals back to defaults. Your tasks will not be deleted.',
          style: AppTypography.bodySmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              onResetSettings();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _confirmClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: AppColors.error, size: 24.r),
            SizedBox(width: 8.w),
            Text('Wipe All Data?', style: AppTypography.heading3),
          ],
        ),
        content: Text(
          'This action cannot be undone. All tasks, categories, and focus logs will be completely erased and reset with sample templates.',
          style: AppTypography.bodySmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              onClearAllData();
            },
            child: const Text('Clear Everything'),
          ),
        ],
      ),
    );
  }
}
