import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_icon_helper.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../domain/entities/task_category_entity.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_enums.dart';

/// Interactive Task Card component with expandable description on demand
class TaskCard extends StatefulWidget {
  final TaskEntity task;
  final TaskCategoryEntity? category;
  final VoidCallback onToggle;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onStartFocus;

  const TaskCard({
    super.key,
    required this.task,
    this.category,
    required this.onToggle,
    this.onTap,
    this.onDelete,
    this.onStartFocus,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final bool isDone = widget.task.isCompleted;
    final categoryColor = widget.category != null
        ? Color(widget.category!.colorValue)
        : AppColors.primary;
    final bool hasDescription = widget.task.description.trim().isNotEmpty;

    return GlassmorphicCard(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      borderColor: isDone
          ? AppColors.border.withAlpha(80)
          : widget.task.priority == TaskPriority.urgent
              ? AppColors.priorityUrgent.withAlpha(120)
              : AppColors.border,
      backgroundColor: isDone
          ? AppColors.surface.withAlpha(120)
          : AppColors.surface,
      onTap: () {
        if (hasDescription) {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        }
        if (widget.onTap != null) {
          widget.onTap!();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Checkbox + Title + Expand Icon (if description present) + More Menu
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Checkbox
              GestureDetector(
                onTap: widget.onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 24.r,
                  height: 24.r,
                  decoration: BoxDecoration(
                    color: isDone
                        ? AppColors.accentCyan
                        : AppColors.surfaceElevated,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDone
                          ? AppColors.accentCyan
                          : AppColors.borderLight,
                      width: 1.5,
                    ),
                    boxShadow: isDone
                        ? [
                            BoxShadow(
                              color: AppColors.accentCyan.withAlpha(120),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: isDone
                      ? Icon(
                          Icons.check_rounded,
                          size: 16.r,
                          color: AppColors.background,
                        )
                      : null,
                ),
              ),

              SizedBox(width: 12.w),

              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.task.title,
                      style: AppTypography.titleMedium.copyWith(
                        color: isDone ? AppColors.textMuted : Colors.white,
                        decoration: isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: AppColors.textMuted,
                        decorationThickness: 2,
                      ),
                    ),
                    // Expandable Description (Hidden by default, shown when user expands)
                    if (hasDescription && _isExpanded && !isDone) ...[
                      SizedBox(height: 8.h),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: _isExpanded ? 1.0 : 0.0,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated.withAlpha(140),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                                color: AppColors.borderLight, width: 0.8),
                          ),
                          child: Text(
                            widget.task.description,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(width: 6.w),

              // Expand Description indicator (if description is available)
              if (hasDescription && !isDone)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.all(4.r),
                    child: Icon(
                      _isExpanded
                          ? Icons.expand_less_rounded
                          : Icons.notes_rounded,
                      size: 18.r,
                      color: _isExpanded
                          ? AppColors.accentCyan
                          : AppColors.textMuted,
                    ),
                  ),
                ),

              // More Popup Menu
              PopupMenuButton<String>(
                icon: Icon(Icons.more_horiz_rounded,
                    size: 20.r, color: AppColors.textSecondary),
                color: AppColors.surfaceElevated,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  side: const BorderSide(color: AppColors.border),
                ),
                onSelected: (value) {
                  if (value == 'delete' && widget.onDelete != null) {
                    widget.onDelete!();
                  } else if (value == 'edit' && widget.onTap != null) {
                    widget.onTap!();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined,
                            size: 18.r, color: AppColors.textPrimary),
                        SizedBox(width: 10.w),
                        Text('Edit Task', style: AppTypography.bodyMedium),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded,
                            size: 18.r, color: AppColors.error),
                        SizedBox(width: 10.w),
                        Text('Delete',
                            style: AppTypography.bodyMedium
                                .copyWith(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Row 2: Badges (Category, Priority, Due Date, Recurrence, Focus Progress)
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Category Badge
              if (widget.category != null)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: AppDecorations.badge(
                    color: categoryColor,
                    borderRadius: 8.r,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        AppIconHelper.getCategoryIcon(widget.category!.iconCode),
                        size: 12.r,
                        color: categoryColor,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        widget.category!.name,
                        style: AppTypography.caption.copyWith(
                          color: categoryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              // Priority Badge
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: AppDecorations.badge(
                  color: widget.task.priority.color,
                  borderRadius: 8.r,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6.r,
                      height: 6.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.task.priority.color,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      widget.task.priority.label,
                      style: AppTypography.caption.copyWith(
                        color: widget.task.priority.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Due Date Tag
              if (widget.task.dueDate != null)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: widget.task.isDueToday
                        ? AppColors.primary.withAlpha(30)
                        : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: widget.task.isDueToday
                          ? AppColors.primary.withAlpha(90)
                          : AppColors.border,
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 11.r,
                        color: widget.task.isDueToday
                            ? AppColors.primaryLight
                            : AppColors.textMuted,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        DateTimeFormatter.formatTaskDueDate(widget.task.dueDate),
                        style: AppTypography.caption.copyWith(
                          color: widget.task.isDueToday
                              ? AppColors.primaryLight
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              // Recurrence Tag
              if (widget.task.frequency != TaskFrequency.once)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColors.border, width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.repeat_rounded,
                          size: 11.r, color: AppColors.accentCyan),
                      SizedBox(width: 4.w),
                      Text(
                        widget.task.frequency.label,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.accentCyan,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              // Focus Time Progress Badge & Action
              if (widget.task.isFocusModeEnabled)
                GestureDetector(
                  onTap: widget.onStartFocus,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withAlpha(60),
                          AppColors.accentCyan.withAlpha(40),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: AppColors.accentCyan.withAlpha(80),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.play_circle_filled_rounded,
                          size: 13.r,
                          color: AppColors.accentCyan,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${widget.task.spentMinutes}/${widget.task.estimatedMinutes}m',
                          style: AppTypography.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
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
    );
  }
}
