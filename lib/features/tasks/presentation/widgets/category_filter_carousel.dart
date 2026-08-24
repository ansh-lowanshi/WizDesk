import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_icon_helper.dart';
import '../../domain/entities/task_category_entity.dart';

/// Horizontal scrolling category selector with badges and active state styling
class CategoryFilterCarousel extends StatelessWidget {
  final List<TaskCategoryEntity> categories;
  final String? selectedCategoryId; // null = All
  final int totalAllTasksCount;
  final int Function(String categoryId) countGetter;
  final ValueChanged<String?> onCategorySelected;

  const CategoryFilterCarousel({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.totalAllTasksCount,
    required this.countGetter,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length + 1, // +1 for "All"
        separatorBuilder: (context, index) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          if (index == 0) {
            // "All" Category Pill
            final bool isSelected = selectedCategoryId == null;
            return _buildPill(
              isSelected: isSelected,
              label: 'All',
              count: totalAllTasksCount,
              icon: Icons.grid_view_rounded,
              color: AppColors.accentCyan,
              onTap: () => onCategorySelected(null),
            );
          }

          final category = categories[index - 1];
          final bool isSelected = selectedCategoryId == category.id;
          final int count = countGetter(category.id);
          final Color categoryColor = Color(category.colorValue);

          return _buildPill(
            isSelected: isSelected,
            label: category.name,
            count: count,
            icon: AppIconHelper.getCategoryIcon(category.iconCode),
            color: categoryColor,
            onTap: () => onCategorySelected(category.id),
          );
        },
      ),
    );
  }

  Widget _buildPill({
    required bool isSelected,
    required String label,
    required int count,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: isSelected
            ? BoxDecoration(
                color: color.withAlpha(40),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: color, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: color.withAlpha(80),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              )
            : BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: AppColors.border, width: 1),
              ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15.r,
              color: isSelected ? color : AppColors.textSecondary,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: isSelected
                  ? AppTypography.badge.copyWith(color: Colors.white)
                  : AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            if (count > 0) ...[
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: AppDecorations.badge(
                  color: isSelected ? color : AppColors.borderLight,
                  borderRadius: 10.r,
                ),
                child: Text(
                  '$count',
                  style: AppTypography.caption.copyWith(
                    fontSize: 10.sp,
                    color: isSelected ? Colors.white : AppColors.textMuted,
                    fontWeight: FontWeight.w700,
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
