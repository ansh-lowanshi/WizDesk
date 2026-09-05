import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../../../core/widgets/responsive_wrapper.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/domain/entities/task_enums.dart';
import '../../../tasks/presentation/bloc/task_bloc.dart';
import '../../../tasks/presentation/bloc/task_event.dart';
import '../../../tasks/presentation/bloc/task_state.dart';
import '../../../tasks/presentation/screens/add_edit_task_screen.dart';
import '../../../tasks/presentation/widgets/task_card.dart';
import '../widgets/month_calendar_view.dart';

/// Full Month Calendar & Daily Task Schedule Screen
class CalendarScreen extends StatefulWidget {
  final ValueChanged<TaskEntity>? onStartTaskFocus;

  const CalendarScreen({super.key, this.onStartTaskFocus});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _selectedDate;
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _focusedMonth = DateTime(now.year, now.month, 1);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Checks if a task is scheduled for a given day taking its frequency into account
  bool _isTaskScheduledForDay(TaskEntity task, DateTime targetDay) {
    final target = DateTime(targetDay.year, targetDay.month, targetDay.day);
    final startRaw = task.dueDate ?? task.createdAt;
    final startDate = DateTime(startRaw.year, startRaw.month, startRaw.day);

    // If the target day is strictly before the task's starting date, don't show it
    if (target.isBefore(startDate)) {
      return false;
    }

    // If task has an end date and target is after end date, don't show it
    if (task.endDate != null) {
      final end = DateTime(
        task.endDate!.year,
        task.endDate!.month,
        task.endDate!.day,
      );
      if (target.isAfter(end)) {
        return false;
      }
    }

    switch (task.frequency) {
      case TaskFrequency.once:
        return target.isAtSameMomentAs(startDate);

      case TaskFrequency.daily:
        return true;

      case TaskFrequency.weekly:
        return target.weekday == startDate.weekday;

      case TaskFrequency.customDays:
        if (task.customDays.isEmpty) {
          return target.isAtSameMomentAs(startDate);
        }
        return task.customDays.contains(target.weekday);
    }
  }

  List<TaskEntity> _filterTasksForSelectedDate(List<TaskEntity> allTasks) {
    return allTasks
        .where((task) => _isTaskScheduledForDay(task, _selectedDate))
        .toList();
  }

  void _openAddTaskScreen({DateTime? date}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditTaskScreen(initialDate: date ?? _selectedDate),
      ),
    );
  }

  void _openEditTaskScreen(TaskEntity task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditTaskScreen(
          taskToEdit: task,
          initialDate: _selectedDate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('Schedule Calendar', style: AppTypography.heading3),
        actions: [
          IconButton(
            key: const ValueKey('cal_header_add_task_btn'),
            icon: Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(120),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.add_rounded, color: Colors.white, size: 18.r),
            ),
            tooltip: 'Add Task for this Date',
            onPressed: () => _openAddTaskScreen(date: _selectedDate),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SafeArea(
        child: ResponsiveWrapper(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: BlocBuilder<TaskBloc, TaskState>(
            builder: (context, state) {
              final allTasks = state is TaskLoaded
                  ? state.allTasks
                  : <TaskEntity>[];
              final dateTasks = _filterTasksForSelectedDate(allTasks);
              final pendingCount = dateTasks
                  .where((t) => !t.isCompletedOn(_selectedDate))
                  .length;
              final completedCount = dateTasks
                  .where((t) => t.isCompletedOn(_selectedDate))
                  .length;

              final isToday = _isSameDay(_selectedDate, DateTime.now());
              final formattedDate = DateFormat(
                'EEEE, MMMM d',
              ).format(_selectedDate);

              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  // 1. Month Calendar Card
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MonthCalendarView(
                          focusedMonth: _focusedMonth,
                          selectedDate: _selectedDate,
                          allTasks: allTasks,
                          onDateSelected: (date) {
                            setState(() {
                              _selectedDate = date;
                              _focusedMonth = DateTime(
                                date.year,
                                date.month,
                                1,
                              );
                            });
                          },
                          onPreviousMonth: () {
                            setState(() {
                              _focusedMonth = DateTime(
                                _focusedMonth.year,
                                _focusedMonth.month - 1,
                                1,
                              );
                            });
                          },
                          onNextMonth: () {
                            setState(() {
                              _focusedMonth = DateTime(
                                _focusedMonth.year,
                                _focusedMonth.month + 1,
                                1,
                              );
                            });
                          },
                          onTodayPressed: () {
                            final now = DateTime.now();
                            setState(() {
                              _selectedDate = DateTime(
                                now.year,
                                now.month,
                                now.day,
                              );
                              _focusedMonth = DateTime(now.year, now.month, 1);
                            });
                          },
                        ),

                        SizedBox(height: 18.h),

                        // 2. Selected Date Header & Metrics Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    isToday ? 'Today, ' : '',
                                    style: AppTypography.heading3.copyWith(
                                      color: AppColors.isDarkMode
                                          ? AppColors.accentCyan
                                          : AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      formattedDate,
                                      style: AppTypography.heading3.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Tasks count pill
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: AppDecorations.badge(
                                color: dateTasks.isNotEmpty
                                    ? AppColors.primary
                                    : AppColors.surfaceLight,
                                borderRadius: 12.r,
                              ),
                              child: Text(
                                '${dateTasks.length} Task${dateTasks.length == 1 ? '' : 's'}',
                                style: AppTypography.badge.copyWith(
                                  color: dateTasks.isNotEmpty
                                      ? Colors.white
                                      : AppColors.textMuted,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),

                        if (dateTasks.isNotEmpty) ...[
                          SizedBox(height: 6.h),
                          Text(
                            '$completedCount completed • $pendingCount pending',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],

                        SizedBox(height: 14.h),
                      ],
                    ),
                  ),

                  // 3. Task List for Selected Date or Empty State
                  if (dateTasks.isEmpty)
                    SliverToBoxAdapter(
                      child: GlassmorphicCard(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 24.h,
                        ),
                        borderRadius: 20.r,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.event_available_rounded,
                              size: 44.r,
                              color: AppColors.accentCyan.withAlpha(150),
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              'No tasks scheduled',
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'You have no tasks due on ${DateFormat('MMM d').format(_selectedDate)}.',
                              textAlign: TextAlign.center,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 14.h),
                            InkWell(
                              key: const ValueKey('cal_empty_add_task_btn'),
                              onTap: () =>
                                  _openAddTaskScreen(date: _selectedDate),
                              borderRadius: BorderRadius.circular(12.r),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(60),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: AppColors.accentCyan.withAlpha(140),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.add_rounded,
                                      size: 18.r,
                                      color: AppColors.accentCyan,
                                    ),
                                    SizedBox(width: 6.w),
                                    Flexible(
                                      child: Text(
                                        'Add Task for this Date',
                                        style: AppTypography.buttonMedium
                                            .copyWith(
                                              color: AppColors.accentCyan,
                                              fontWeight: FontWeight.w700,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final task = dateTasks[index];
                        final category = state is TaskLoaded
                            ? state.getCategoryById(task.categoryId)
                            : null;

                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: TaskCard(
                            task: task,
                            category: category,
                            date: _selectedDate,
                            onToggle: () {
                              context.read<TaskBloc>().add(
                                ToggleTaskStatusEvent(
                                  task.id,
                                  date: _selectedDate,
                                ),
                              );
                            },
                            onEdit: () => _openEditTaskScreen(task),
                            onDelete: () {
                              context.read<TaskBloc>().add(
                                DeleteTaskEvent(task.id),
                              );
                            },
                            onStartFocus: () {
                              if (widget.onStartTaskFocus != null) {
                                widget.onStartTaskFocus!(task);
                              }
                            },
                          ),
                        );
                      }, childCount: dateTasks.length),
                    ),

                  // Bottom padding for floating navigation bar
                  SliverToBoxAdapter(child: SizedBox(height: 90.h)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
