import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/domain/entities/task_enums.dart';

/// Interactive Month Calendar Grid with Task Indicators
class MonthCalendarView extends StatelessWidget {
  final DateTime focusedMonth;
  final DateTime selectedDate;
  final List<TaskEntity> allTasks;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onTodayPressed;

  const MonthCalendarView({
    super.key,
    required this.focusedMonth,
    required this.selectedDate,
    required this.allTasks,
    required this.onDateSelected,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onTodayPressed,
  });

  static const List<String> _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];

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
      final end =
          DateTime(task.endDate!.year, task.endDate!.month, task.endDate!.day);
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

  /// Extracts all tasks scheduled or due on a given calendar day
  List<TaskEntity> _getTasksForDay(DateTime day) {
    return allTasks.where((task) => _isTaskScheduledForDay(task, day)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isCurrentMonth =
        focusedMonth.year == now.year && focusedMonth.month == now.month;

    final firstDayOfMonth =
        DateTime(focusedMonth.year, focusedMonth.month, 1);
    final daysInMonth =
        DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;

    // Weekday of 1st day (1 = Mon, 7 = Sun)
    final startingWeekday = firstDayOfMonth.weekday; // 1 to 7

    // Previous month filler days count
    final prevMonthDaysCount = startingWeekday - 1;
    final prevMonthLastDay =
        DateTime(focusedMonth.year, focusedMonth.month, 0).day;

    // Calculate total grid cells (multiple of 7: 35 or 42)
    final totalDaysShown =
        ((prevMonthDaysCount + daysInMonth) > 35) ? 42 : 35;

    return GlassmorphicCard(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      borderRadius: 22.r,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Month Header & Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Month & Year Title
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        DateFormat('MMMM yyyy').format(focusedMonth),
                        style: AppTypography.heading3.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!_isSameDay(selectedDate, now) || !isCurrentMonth) ...[
                      SizedBox(width: 8.w),
                      InkWell(
                        key: const ValueKey('cal_go_to_today_btn'),
                        onTap: onTodayPressed,
                        borderRadius: BorderRadius.circular(10.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(40),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: AppColors.isDarkMode
                                  ? AppColors.accentCyan.withAlpha(140)
                                  : AppColors.primary.withAlpha(140),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.today_rounded,
                                size: 12.r,
                                color: AppColors.isDarkMode
                                    ? AppColors.accentCyan
                                    : AppColors.primary,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'Today',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.isDarkMode
                                      ? AppColors.accentCyan
                                      : AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Prev / Next Month Arrows
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    key: const ValueKey('cal_prev_month_btn'),
                    icon: Icon(Icons.chevron_left_rounded,
                        size: 24.r, color: AppColors.textPrimary),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    onPressed: onPreviousMonth,
                  ),
                  IconButton(
                    key: const ValueKey('cal_next_month_btn'),
                    icon: Icon(Icons.chevron_right_rounded,
                        size: 24.r, color: AppColors.textPrimary),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    onPressed: onNextMonth,
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // 2. Weekday Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _weekdays.map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                      fontSize: 11.sp,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 8.h),

          // 3. Days Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalDaysShown,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              DateTime dayDate;
              bool isOtherMonth = false;

              if (index < prevMonthDaysCount) {
                // Previous month filler days
                final dayNum =
                    prevMonthLastDay - prevMonthDaysCount + index + 1;
                dayDate = DateTime(
                    focusedMonth.year, focusedMonth.month - 1, dayNum);
                isOtherMonth = true;
              } else if (index < prevMonthDaysCount + daysInMonth) {
                // Current month days
                final dayNum = index - prevMonthDaysCount + 1;
                dayDate = DateTime(
                    focusedMonth.year, focusedMonth.month, dayNum);
              } else {
                // Next month filler days
                final dayNum =
                    index - (prevMonthDaysCount + daysInMonth) + 1;
                dayDate = DateTime(
                    focusedMonth.year, focusedMonth.month + 1, dayNum);
                isOtherMonth = true;
              }

              final isSelected = _isSameDay(dayDate, selectedDate);
              final isToday = _isSameDay(dayDate, now);
              final dayTasks = _getTasksForDay(dayDate);
              final hasPending =
                  dayTasks.any((t) => !t.isCompletedOn(dayDate));
              final hasCompleted =
                  dayTasks.any((t) => t.isCompletedOn(dayDate));

              return InkWell(
                key: ValueKey('cal_day_${dayDate.year}_${dayDate.month}_${dayDate.day}'),
                onTap: () => onDateSelected(dayDate),
                borderRadius: BorderRadius.circular(14.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (AppColors.isDarkMode
                            ? AppColors.primary.withAlpha(80)
                            : AppColors.primary)
                        : (isToday
                            ? AppColors.surfaceElevated
                            : Colors.transparent),
                    borderRadius: BorderRadius.circular(14.r),
                    border: isSelected
                        ? Border.all(
                            color: AppColors.isDarkMode
                                ? AppColors.accentCyan
                                : AppColors.primary,
                            width: 1.5,
                          )
                        : (isToday
                            ? Border.all(
                                color: AppColors.isDarkMode
                                    ? AppColors.accentCyan.withAlpha(100)
                                    : AppColors.primary.withAlpha(100),
                                width: 1,
                              )
                            : null),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: (AppColors.isDarkMode
                                      ? AppColors.accentCyan
                                      : AppColors.primary)
                                  .withAlpha(70),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${dayDate.day}',
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 12.sp,
                          fontWeight: isSelected || isToday
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : (isOtherMonth
                                  ? AppColors.textMuted.withAlpha(120)
                                  : (isToday
                                      ? (AppColors.isDarkMode
                                          ? AppColors.accentCyan
                                          : AppColors.primary)
                                      : AppColors.textPrimary)),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      // Task Status Dots
                      if (dayTasks.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (hasPending)
                              Container(
                                width: 4.5.r,
                                height: 4.5.r,
                                margin: EdgeInsets.symmetric(horizontal: 1.w),
                                decoration: const BoxDecoration(
                                  color: AppColors.accentCyan,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            if (hasCompleted)
                              Container(
                                width: 4.5.r,
                                height: 4.5.r,
                                margin: EdgeInsets.symmetric(horizontal: 1.w),
                                decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        )
                      else
                        SizedBox(height: 4.5.r),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
