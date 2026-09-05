import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_icon_helper.dart';
import '../../domain/entities/task_category_entity.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import 'add_category_dialog.dart';

/// Modal bottom sheet to view, add, and delete task categories
class ManageCategoriesSheet extends StatelessWidget {
  const ManageCategoriesSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const ManageCategoriesSheet(),
    );
  }

  void _confirmDeleteCategory(BuildContext context, TaskCategoryEntity category) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: BorderSide(color: AppColors.border),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.delete_outline_rounded,
                  color: AppColors.error, size: 20.r),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'Delete Category?',
                style: AppTypography.heading3,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${category.name}"? Tasks assigned to this category will not be deleted.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            key: const ValueKey('cancel_delete_cat_btn'),
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(
              'Cancel',
              style: AppTypography.buttonMedium.copyWith(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            key: const ValueKey('confirm_delete_cat_btn'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            onPressed: () {
              context.read<TaskBloc>().add(DeleteCategoryEvent(category.id));
              Navigator.of(dialogCtx).pop();
            },
            child: Text(
              'Delete',
              style: AppTypography.buttonMedium.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _openAddCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AddCategoryDialog(
        onCategoryCreated: (newCategory) {
          context.read<TaskBloc>().add(AddCategoryEvent(newCategory));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 14.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      child: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          final categories = state is TaskLoaded ? state.categories : <TaskCategoryEntity>[];
          final allTasks = state is TaskLoaded ? state.allTasks : [];

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pull Bar Indicator
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

              // Title Row & Add Category Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Manage Categories',
                          style: AppTypography.heading3,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '${categories.length} custom and system categories',
                          style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  ElevatedButton.icon(
                    key: const ValueKey('sheet_add_category_btn'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                    ),
                    icon: Icon(Icons.add_rounded, size: 16.r, color: Colors.white),
                    label: Text(
                      'Add New',
                      style: AppTypography.buttonMedium.copyWith(
                        color: Colors.white,
                        fontSize: 12.sp,
                      ),
                    ),
                    onPressed: () => _openAddCategoryDialog(context),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Categories List
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 340.h),
                child: categories.isEmpty
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.h),
                          child: Text(
                            'No categories found.',
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: categories.length,
                        separatorBuilder: (context, index) => SizedBox(height: 10.h),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final taskCount = allTasks
                              .where((t) => t.categoryId == category.id)
                              .length;
                          final color = Color(category.colorValue);

                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 10.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(
                                color: color.withAlpha(60),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Color Icon Circle
                                Container(
                                  width: 36.r,
                                  height: 36.r,
                                  decoration: BoxDecoration(
                                    color: color.withAlpha(35),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: color, width: 1.5),
                                  ),
                                  child: Icon(
                                    AppIconHelper.getCategoryIcon(category.iconCode),
                                    size: 18.r,
                                    color: color,
                                  ),
                                ),
                                SizedBox(width: 12.w),

                                // Name & Task Count
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        category.name,
                                        style: AppTypography.bodyLarge.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        '$taskCount ${taskCount == 1 ? 'task' : 'tasks'}',
                                        style: AppTypography.caption.copyWith(
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Delete Category Icon Button
                                IconButton(
                                  key: ValueKey('delete_cat_${category.id}'),
                                  icon: Icon(
                                    Icons.delete_outline_rounded,
                                    size: 20.r,
                                    color: AppColors.error.withAlpha(200),
                                  ),
                                  tooltip: 'Delete Category',
                                  onPressed: () =>
                                      _confirmDeleteCategory(context, category),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
