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
import '../../../focus/presentation/screens/focus_timer_screen.dart';

/// Interactive Task Card component with expandable description on demand
class TaskCard extends StatefulWidget {
  final TaskEntity task;
  final TaskCategoryEntity? category;
  final VoidCallback onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onStartFocus;
  final DateTime? date;

  const TaskCard({
    super.key,
    required this.task,
    this.category,
    required this.onToggle,
    this.onEdit,
    this.onDelete,
    this.onStartFocus,
    this.date,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late final AnimationController _swipeController;
  late final Animation<double> _swipeAnimation;
  bool _isSwipedOpen = false;

  @override
  void initState() {
    super.initState();
    _swipeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _swipeAnimation = CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void didUpdateWidget(TaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final isDone = widget.date != null
        ? widget.task.isCompletedOn(widget.date!)
        : widget.task.isCompleted;
    if (isDone && _swipeController.value > 0) {
      _closeSwipe();
    }
  }

  @override
  void dispose() {
    _swipeController.dispose();
    super.dispose();
  }

  void _openSwipe() {
    setState(() => _isSwipedOpen = true);
    _swipeController.forward();
  }

  void _closeSwipe() {
    _swipeController.reverse().then((_) {
      if (mounted) setState(() => _isSwipedOpen = false);
    });
  }

  Future<void> _confirmAndDelete(BuildContext context) async {
    if (widget.onDelete == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: BorderSide(color: AppColors.border, width: 1.2),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(40),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: 22.r,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Delete Task?',
                style: AppTypography.heading3.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${widget.task.title}"? This action cannot be undone.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        actions: [
          TextButton(
            key: const ValueKey('cancel_delete_btn'),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: AppTypography.buttonMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
          ElevatedButton(
            key: const ValueKey('confirm_delete_btn'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Delete',
              style: AppTypography.buttonMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      widget.onDelete!();
    }
  }

  void _startTimerDirect() {
    if (widget.onStartFocus != null) {
      widget.onStartFocus!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => FocusTimerScreen(initialTask: widget.task),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDone = widget.date != null
        ? widget.task.isCompletedOn(widget.date!)
        : widget.task.isCompleted;
    final categoryColor = widget.category != null
        ? Color(widget.category!.colorValue)
        : AppColors.primary;
    final String effectiveDescription =
        widget.task.getDescriptionFor(widget.date);
    final bool hasDescription = effectiveDescription.trim().isNotEmpty;

    final cardWidget = GlassmorphicCard(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      borderColor: isDone
          ? AppColors.border.withAlpha(80)
          : widget.task.priority == TaskPriority.urgent
              ? AppColors.priorityUrgent.withAlpha(120)
              : AppColors.border,
      backgroundColor: isDone
          ? AppColors.surface.withAlpha(120)
          : AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Checkbox + Title + Expand Icon (if description present) + More Menu
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Checkbox
              GestureDetector(
                onTap: () {
                  if (_swipeController.value > 0) {
                    _closeSwipe();
                  }
                  widget.onToggle();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 22.r,
                  height: 22.r,
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
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: isDone
                      ? Icon(
                          Icons.check_rounded,
                          size: 14.r,
                          color: AppColors.background,
                        )
                      : null,
                ),
              ),

              SizedBox(width: 12.w),

              // Title & Category & Sub-details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.task.title,
                      style: AppTypography.heading3.copyWith(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        decoration:
                            isDone ? TextDecoration.lineThrough : null,
                        color: isDone
                            ? AppColors.textMuted
                            : AppColors.textPrimary,
                      ),
                    ),

                    if (hasDescription && _isExpanded) ...[
                      SizedBox(height: 6.h),
                      Text(
                        effectiveDescription,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.35,
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
                  side: BorderSide(color: AppColors.border),
                ),
                onSelected: (value) {
                  if (value == 'delete') {
                    _confirmAndDelete(context);
                  } else if (value == 'edit' && widget.onEdit != null) {
                    widget.onEdit!();
                  } else if (value == 'timer') {
                    if (widget.onStartFocus != null) {
                      widget.onStartFocus!();
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => FocusTimerScreen(initialTask: widget.task),
                        ),
                      );
                    }
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'timer',
                    child: Row(
                      children: [
                        Icon(Icons.timer_outlined,
                            size: 18.r, color: AppColors.accentCyan),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Focus Timer',
                            style: AppTypography.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined,
                            size: 18.r, color: AppColors.textPrimary),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Edit Task',
                            style: AppTypography.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded,
                            size: 18.r, color: AppColors.error),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Delete',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.error,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
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
                    child: Builder(
                      builder: (context) {
                        final currentPct = widget.task.getProgressPercentFor(widget.date);
                        final currentSpent = widget.task.getSpentMinutesFor(widget.date);
                        final currentRatio = widget.task.getProgressPercentageFor(widget.date);
                        final displayPct = currentPct > 0
                            ? currentPct
                            : (currentRatio * 100).round();

                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.play_circle_filled_rounded,
                              size: 13.r,
                              color: AppColors.accentCyan,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '$displayPct% • $currentSpent/${widget.task.estimatedMinutes}m',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxSwipeWidth = constraints.maxWidth * 0.40;

        return Stack(
          children: [
            // Background Action Card revealed on swipe (only when not completed)
            if (!isDone)
              Positioned.fill(
                child: FadeTransition(
                  opacity: _swipeAnimation,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accentCyan.withAlpha(45),
                          AppColors.primary.withAlpha(20),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(
                        color: AppColors.accentCyan.withAlpha(100),
                        width: 1.2,
                      ),
                    ),
                    alignment: Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxSwipeWidth - 8.w),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Action confirmation button directly inside the revealed swipe space
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14.r),
                                onTap: () {
                                  _closeSwipe();
                                  _startTimerDirect();
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 8.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentCyan,
                                    borderRadius: BorderRadius.circular(14.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.accentCyan.withAlpha(160),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.play_arrow_rounded,
                                        color: Colors.black,
                                        size: 18.r,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        'Start',
                                        style: AppTypography.buttonSmall.copyWith(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            // Cancel / dismiss button
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: Icon(
                                Icons.close_rounded,
                                color: AppColors.textMuted,
                                size: 18.r,
                              ),
                              tooltip: 'Cancel',
                              onPressed: _closeSwipe,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Foreground Card sliding horizontally up to 40% of card width
            AnimatedBuilder(
              animation: _swipeAnimation,
              builder: (context, child) {
                final double currentOffset =
                    _swipeAnimation.value * maxSwipeWidth;
                return Transform.translate(
                  offset: Offset(currentOffset, 0),
                  child: child,
                );
              },
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (_swipeController.value > 0) {
                    _closeSwipe();
                  }
                },
                onHorizontalDragUpdate: isDone
                    ? null
                    : (details) {
                        // Only allow dragging to the right (positive delta) or back
                        final delta = details.primaryDelta ?? 0;
                        final double change = delta / maxSwipeWidth;
                        _swipeController.value =
                            (_swipeController.value + change).clamp(0.0, 1.0);
                        if (_swipeController.value > 0.05 && !_isSwipedOpen) {
                          setState(() => _isSwipedOpen = true);
                        }
                      },
                onHorizontalDragEnd: isDone
                    ? null
                    : (details) {
                        final velocity = details.primaryVelocity ?? 0;
                        // If flung right or dragged more than 35%, snap open to 40%
                        if (velocity > 300 || _swipeController.value > 0.35) {
                          _openSwipe();
                        } else {
                          _closeSwipe();
                        }
                      },
                child: cardWidget,
              ),
            ),
          ],
        );
      },
    );
  }
}
