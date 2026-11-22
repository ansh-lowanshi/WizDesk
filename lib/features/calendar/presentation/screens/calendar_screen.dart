import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../../../core/widgets/responsive_wrapper.dart';
import '../../../notes/domain/entities/note_entity.dart';
import '../../../notes/presentation/bloc/note_bloc.dart';
import '../../../notes/presentation/bloc/note_event.dart';
import '../../../notes/presentation/bloc/note_state.dart';
import '../../../notes/presentation/screens/note_editor_screen.dart';
import '../../../notes/presentation/widgets/note_card.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/domain/entities/task_enums.dart';
import '../../../tasks/presentation/bloc/task_bloc.dart';
import '../../../tasks/presentation/bloc/task_event.dart';
import '../../../tasks/presentation/bloc/task_state.dart';
import '../../../tasks/presentation/screens/add_edit_task_screen.dart';
import '../../../tasks/presentation/widgets/task_card.dart';
import '../widgets/month_calendar_view.dart';

/// Full Month Calendar & Daily Task Schedule & Notes Screen
class CalendarScreen extends StatefulWidget {
  final ValueChanged<TaskEntity>? onStartTaskFocus;

  const CalendarScreen({super.key, this.onStartTaskFocus});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _selectedDate;
  late DateTime _focusedMonth;
  int _selectedTabIndex = 0; // 0: Tasks, 1: Notes

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

  void _openAddNoteScreen({DateTime? date}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NoteEditorScreen(
          initialDate: date ?? _selectedDate,
        ),
      ),
    );
  }

  void _openEditNoteScreen(NoteEntity note) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NoteEditorScreen(
          noteToEdit: note,
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
        title: Text(context.l10n.calendarSchedule, style: AppTypography.heading3),
        actions: [
          IconButton(
            key: const ValueKey('cal_header_add_task_btn'),
            icon: Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                gradient: _selectedTabIndex == 0
                    ? AppColors.primaryGradient
                    : const LinearGradient(
                        colors: [AppColors.accentIndigo, AppColors.accentCyan],
                      ),
                borderRadius: BorderRadius.circular(10.r),
                boxShadow: [
                  BoxShadow(
                    color: (_selectedTabIndex == 0
                            ? AppColors.primary
                            : AppColors.accentIndigo)
                        .withAlpha(120),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.add_rounded, color: Colors.white, size: 18.r),
            ),
            tooltip: _selectedTabIndex == 0
                ? context.l10n.addTaskForThisDate
                : context.l10n.addNoteForThisDate,
            onPressed: () {
              if (_selectedTabIndex == 0) {
                _openAddTaskScreen(date: _selectedDate);
              } else {
                _openAddNoteScreen(date: _selectedDate);
              }
            },
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SafeArea(
        child: ResponsiveWrapper(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: BlocBuilder<TaskBloc, TaskState>(
            builder: (context, taskState) {
              final allTasks = taskState is TaskLoaded
                  ? taskState.allTasks
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
                Localizations.localeOf(context).languageCode,
              ).format(_selectedDate);

              return BlocBuilder<NoteBloc, NoteState>(
                builder: (context, noteState) {
                  final allNotes = noteState is NoteLoaded
                      ? noteState.allNotes
                      : <NoteEntity>[];
                  final dateNotes = noteState is NoteLoaded
                      ? noteState.getNotesForDate(
                          _selectedDate,
                          scheduledTasks: dateTasks,
                        )
                      : <NoteEntity>[];

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
                              allNotes: allNotes,
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
                                  _focusedMonth =
                                      DateTime(now.year, now.month, 1);
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
                                        isToday ? '${context.l10n.today}, ' : '',
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

                                // Count badge for the active tab
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: AppDecorations.badge(
                                    color: _selectedTabIndex == 0
                                        ? (dateTasks.isNotEmpty
                                            ? AppColors.primary
                                            : AppColors.surfaceLight)
                                        : (dateNotes.isNotEmpty
                                            ? AppColors.accentIndigo
                                            : AppColors.surfaceLight),
                                    borderRadius: 12.r,
                                  ),
                                  child: Text(
                                    _selectedTabIndex == 0
                                        ? '${dateTasks.length} ${dateTasks.length == 1 ? context.l10n.taskWord : context.l10n.tasksWord}'
                                        : '${dateNotes.length} ${dateNotes.length == 1 ? "note" : "notes"}',
                                    style: AppTypography.badge.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            if (_selectedTabIndex == 0 && dateTasks.isNotEmpty) ...[
                              SizedBox(height: 6.h),
                              Text(
                                '$completedCount ${context.l10n.completed.toLowerCase()} • $pendingCount ${context.l10n.pending.toLowerCase()}',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],

                            SizedBox(height: 14.h),

                            // 3. Tab Selector after Calendar & Date mentioned for [Tasks | Notes]
                            Row(
                              children: [
                                // Tab 0: Tasks
                                Expanded(
                                  child: InkWell(
                                    key: const ValueKey('cal_tab_tasks'),
                                    onTap: () =>
                                        setState(() => _selectedTabIndex = 0),
                                    borderRadius: BorderRadius.circular(14.r),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding:
                                          EdgeInsets.symmetric(vertical: 9.h),
                                      decoration: BoxDecoration(
                                        color: _selectedTabIndex == 0
                                            ? AppColors.primary
                                            : AppColors.surfaceElevated,
                                        borderRadius:
                                            BorderRadius.circular(14.r),
                                        border: Border.all(
                                          color: _selectedTabIndex == 0
                                              ? AppColors.accentCyan
                                              : AppColors.border,
                                          width: 1.2,
                                        ),
                                        boxShadow: _selectedTabIndex == 0
                                            ? [
                                                BoxShadow(
                                                  color: AppColors.primary
                                                      .withAlpha(120),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.check_circle_outline_rounded,
                                            size: 16.r,
                                            color: _selectedTabIndex == 0
                                                ? Colors.white
                                                : AppColors.textSecondary,
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            'Tasks (${dateTasks.length})',
                                            style: AppTypography.buttonMedium
                                                .copyWith(
                                              color: _selectedTabIndex == 0
                                                  ? Colors.white
                                                  : AppColors.textSecondary,
                                              fontWeight: _selectedTabIndex == 0
                                                  ? FontWeight.w700
                                                  : FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(width: 10.w),

                                // Tab 1: Notes
                                Expanded(
                                  child: InkWell(
                                    key: const ValueKey('cal_tab_notes'),
                                    onTap: () =>
                                        setState(() => _selectedTabIndex = 1),
                                    borderRadius: BorderRadius.circular(14.r),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding:
                                          EdgeInsets.symmetric(vertical: 9.h),
                                      decoration: BoxDecoration(
                                        color: _selectedTabIndex == 1
                                            ? (AppColors.isDarkMode
                                                ? AppColors.accentIndigo
                                                : AppColors.primary)
                                            : AppColors.surfaceElevated,
                                        borderRadius:
                                            BorderRadius.circular(14.r),
                                        border: Border.all(
                                          color: _selectedTabIndex == 1
                                              ? AppColors.accentCyan
                                              : AppColors.border,
                                          width: 1.2,
                                        ),
                                        boxShadow: _selectedTabIndex == 1
                                            ? [
                                                BoxShadow(
                                                  color: AppColors.accentIndigo
                                                      .withAlpha(120),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.description_outlined,
                                            size: 16.r,
                                            color: _selectedTabIndex == 1
                                                ? Colors.white
                                                : AppColors.textSecondary,
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            'Notes (${dateNotes.length})',
                                            style: AppTypography.buttonMedium
                                                .copyWith(
                                              color: _selectedTabIndex == 1
                                                  ? Colors.white
                                                  : AppColors.textSecondary,
                                              fontWeight: _selectedTabIndex == 1
                                                  ? FontWeight.w700
                                                  : FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 16.h),
                          ],
                        ),
                      ),

                      // 4. Content Area Based on Active Tab
                      if (_selectedTabIndex == 0) ...[
                        // --- TASKS TAB ---
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
                                    context.l10n.noTasksScheduled,
                                    style: AppTypography.titleMedium.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    context.l10n.noTasksOnDate,
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
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                        border: Border.all(
                                          color: AppColors.accentCyan
                                              .withAlpha(140),
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
                                              context.l10n.addTaskForThisDate,
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
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final task = dateTasks[index];
                              final category = taskState is TaskLoaded
                                  ? taskState.getCategoryById(task.categoryId)
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
                      ] else ...[
                        // --- NOTES TAB ---
                        if (dateNotes.isEmpty)
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
                                    Icons.note_alt_outlined,
                                    size: 44.r,
                                    color:
                                        AppColors.accentIndigo.withAlpha(180),
                                  ),
                                  SizedBox(height: 10.h),
                                  Text(
                                    context.l10n.noNotesScheduled,
                                    style: AppTypography.titleMedium.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'Capture ideas, attach notes to tasks, or document daily progress.',
                                    textAlign: TextAlign.center,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  SizedBox(height: 14.h),
                                  InkWell(
                                    key: const ValueKey('cal_empty_add_note_btn'),
                                    onTap: () =>
                                        _openAddNoteScreen(date: _selectedDate),
                                    borderRadius: BorderRadius.circular(12.r),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 8.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentIndigo
                                            .withAlpha(60),
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                        border: Border.all(
                                          color: AppColors.accentCyan
                                              .withAlpha(140),
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
                                              context.l10n.addNoteForThisDate,
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
                        else ...[
                          // Action button above notes
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 10.h),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Notes on this Date',
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => _openAddNoteScreen(
                                      date: _selectedDate,
                                    ),
                                    borderRadius: BorderRadius.circular(8.r),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6.w,
                                        vertical: 2.h,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.add_circle_outline_rounded,
                                            size: 14.r,
                                            color: AppColors.accentCyan,
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            'Add Note',
                                            style: AppTypography.caption
                                                .copyWith(
                                              color: AppColors.accentCyan,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final note = dateNotes[index];

                              return Padding(
                                padding: EdgeInsets.only(bottom: 12.h),
                                child: NoteCard(
                                  note: note,
                                  onTap: () => _openEditNoteScreen(note),
                                  onDelete: () {
                                    context
                                        .read<NoteBloc>()
                                        .add(DeleteNoteEvent(note.id));
                                  },
                                  onTogglePin: () {
                                    context
                                        .read<NoteBloc>()
                                        .add(ToggleNotePinEvent(note.id));
                                  },
                                ),
                              );
                            }, childCount: dateNotes.length),
                          ),
                        ],
                      ],

                      // Bottom padding for floating navigation bar
                      SliverToBoxAdapter(child: SizedBox(height: 90.h)),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
