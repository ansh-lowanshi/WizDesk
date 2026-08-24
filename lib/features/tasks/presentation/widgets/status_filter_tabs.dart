import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/task_event.dart';

/// Segmented Status Tabs (All / In Progress / Pending / Completed)
/// Designed with clean gaps and isolated active indicator to prevent any overlap
class StatusFilterTabs extends StatelessWidget {
  final TaskStatusFilter activeFilter;
  final ValueChanged<TaskStatusFilter> onFilterChanged;
  final int allCount;
  final int inProgressCount;
  final int pendingCount;
  final int completedCount;

  const StatusFilterTabs({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
    required this.allCount,
    required this.inProgressCount,
    required this.pendingCount,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          _buildTab(TaskStatusFilter.all, 'All', allCount),
          SizedBox(width: 4.w),
          _buildTab(TaskStatusFilter.inProgress, 'In Progress', inProgressCount),
          SizedBox(width: 4.w),
          _buildTab(TaskStatusFilter.pending, 'Pending', pendingCount),
          SizedBox(width: 4.w),
          _buildTab(TaskStatusFilter.completed, 'Done', completedCount),
        ],
      ),
    );
  }

  Widget _buildTab(TaskStatusFilter filter, String label, int count) {
    final bool isSelected = activeFilter == filter;

    return Expanded(
      child: GestureDetector(
        onTap: () => onFilterChanged(filter),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(80),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: AppTypography.buttonMedium.copyWith(
                    fontSize: 12.sp,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
                SizedBox(width: 4.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withAlpha(50)
                        : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '$count',
                    style: AppTypography.caption.copyWith(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
