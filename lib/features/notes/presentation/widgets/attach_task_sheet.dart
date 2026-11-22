import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/presentation/bloc/task_bloc.dart';
import '../../../tasks/presentation/bloc/task_state.dart';

class TaskAttachmentResult {
  final TaskEntity? task;
  final bool isDateSpecific;

  const TaskAttachmentResult({
    required this.task,
    required this.isDateSpecific,
  });
}

/// Bottom sheet to select a task and choose attachment scope (Single Date vs Throughout Task)
class AttachTaskSheet extends StatefulWidget {
  final String? currentTaskId;
  final bool currentIsDateSpecific;
  final DateTime? targetDate;

  const AttachTaskSheet({
    super.key,
    this.currentTaskId,
    this.currentIsDateSpecific = true,
    this.targetDate,
  });

  static Future<TaskAttachmentResult?> show(
    BuildContext context, {
    String? currentTaskId,
    bool currentIsDateSpecific = true,
    DateTime? targetDate,
  }) {
    return showModalBottomSheet<TaskAttachmentResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AttachTaskSheet(
        currentTaskId: currentTaskId,
        currentIsDateSpecific: currentIsDateSpecific,
        targetDate: targetDate,
      ),
    );
  }

  @override
  State<AttachTaskSheet> createState() => _AttachTaskSheetState();
}

class _AttachTaskSheetState extends State<AttachTaskSheet> {
  late bool _isDateSpecific;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isDateSpecific = widget.currentIsDateSpecific;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = widget.targetDate != null
        ? DateFormat('EEE, MMM d').format(widget.targetDate!)
        : 'Selected date';

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            border: Border.all(color: AppColors.border, width: 1.2),
          ),
          child: Column(
            children: [
              SizedBox(height: 10.h),
              // Handle
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withAlpha(120),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 14.h),

              // Title Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.link_rounded,
                          color: AppColors.accentCyan,
                          size: 22.r,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Attach to Task',
                          style: AppTypography.heading3.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    if (widget.currentTaskId != null)
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop(
                            const TaskAttachmentResult(
                              task: null,
                              isDateSpecific: true,
                            ),
                          );
                        },
                        icon: Icon(Icons.link_off_rounded,
                            size: 16.r, color: AppColors.error),
                        label: Text(
                          'Detach',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              SizedBox(height: 12.h),

              // Attachment Scope Selector: Single Date vs Throughout Task
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: Row(
                    children: [
                      // Scope 1: Single Date
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isDateSpecific = true),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            decoration: BoxDecoration(
                              color: _isDateSpecific
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 14.r,
                                  color: _isDateSpecific
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                                SizedBox(width: 6.w),
                                Flexible(
                                  child: Text(
                                    'Single Date ($dateStr)',
                                    style: AppTypography.caption.copyWith(
                                      color: _isDateSpecific
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                      fontWeight: _isDateSpecific
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Scope 2: Throughout Task
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isDateSpecific = false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            decoration: BoxDecoration(
                              color: !_isDateSpecific
                                  ? AppColors.accentCyan
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.all_inclusive_rounded,
                                  size: 15.r,
                                  color: !_isDateSpecific
                                      ? Colors.black
                                      : AppColors.textSecondary,
                                ),
                                SizedBox(width: 6.w),
                                Flexible(
                                  child: Text(
                                    'Throughout Task',
                                    style: AppTypography.caption.copyWith(
                                      color: !_isDateSpecific
                                          ? Colors.black
                                          : AppColors.textSecondary,
                                      fontWeight: !_isDateSpecific
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(22.w, 6.h, 22.w, 10.h),
                child: Text(
                  _isDateSpecific
                      ? 'Note is linked exclusively to $dateStr of this task.'
                      : 'Note remains visible across all dates and screens for this task.',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11.sp,
                  ),
                ),
              ),

              // Search Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search tasks by title...',
                    hintStyle: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: AppColors.textMuted, size: 20.r),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(
                        color: AppColors.accentCyan,
                        width: 1.2,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // Task List
              Expanded(
                child: BlocBuilder<TaskBloc, TaskState>(
                  builder: (context, state) {
                    if (state is! TaskLoaded) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accentCyan,
                        ),
                      );
                    }

                    var tasks = state.allTasks;
                    if (_searchQuery.isNotEmpty) {
                      tasks = tasks
                          .where((t) => t.title
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()))
                          .toList();
                    }

                    if (tasks.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.task_alt_rounded,
                              size: 40.r,
                              color: AppColors.textMuted,
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'No tasks found',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      controller: scrollController,
                      padding: EdgeInsets.symmetric(
                        horizontal: 18.w,
                        vertical: 6.h,
                      ),
                      itemCount: tasks.length,
                      separatorBuilder: (_, _) => SizedBox(height: 8.h),
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        final isSelected = task.id == widget.currentTaskId;
                        final category = state.getCategoryById(task.categoryId);

                        return InkWell(
                          onTap: () {
                            Navigator.of(context).pop(
                              TaskAttachmentResult(
                                task: task,
                                isDateSpecific: _isDateSpecific,
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(14.r),
                          child: GlassmorphicCard(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 12.h,
                            ),
                            borderRadius: 14.r,
                            borderColor: isSelected
                                ? AppColors.accentCyan
                                : AppColors.border,
                            backgroundColor: isSelected
                                ? AppColors.primary.withAlpha(40)
                                : AppColors.surface,
                            child: Row(
                              children: [
                                // Radio / Check Indicator
                                Container(
                                  width: 20.r,
                                  height: 20.r,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.accentCyan
                                          : AppColors.borderLight,
                                      width: 1.5,
                                    ),
                                    color: isSelected
                                        ? AppColors.accentCyan
                                        : Colors.transparent,
                                  ),
                                  child: isSelected
                                      ? Icon(
                                          Icons.check_rounded,
                                          size: 13.r,
                                          color: Colors.black,
                                        )
                                      : null,
                                ),
                                SizedBox(width: 12.w),

                                // Task details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        task.title,
                                        style: AppTypography.bodyMedium
                                            .copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? AppColors.textPrimary
                                              : AppColors.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4.h),
                                      Row(
                                        children: [
                                          if (category != null) ...[
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 6.w,
                                                vertical: 2.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Color(category.colorValue)
                                                    .withAlpha(40),
                                                borderRadius:
                                                    BorderRadius.circular(6.r),
                                              ),
                                              child: Text(
                                                category.name,
                                                style: AppTypography.caption
                                                    .copyWith(
                                                  color: Color(
                                                      category.colorValue),
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 8.w),
                                          ],
                                          Text(
                                            task.priority.name.toUpperCase(),
                                            style: AppTypography.caption
                                                .copyWith(
                                              color: task.priority.color,
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.textMuted,
                                  size: 18.r,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
