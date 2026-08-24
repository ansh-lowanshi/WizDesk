import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../tasks/domain/entities/focus_session_entity.dart';
import '../../../tasks/domain/entities/task_category_entity.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/domain/usecases/get_categories_usecase.dart';
import '../../../tasks/domain/usecases/get_focus_sessions_usecase.dart';
import '../../../tasks/domain/usecases/get_tasks_usecase.dart';
import '../../domain/models/analytics_data.dart';
import '../../domain/models/analytics_time_range.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';

/// BLoC for calculating and managing Analytics & Productivity Metrics
class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final GetTasksUseCase getTasksUseCase;
  final GetFocusSessionsUseCase getFocusSessionsUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;

  AnalyticsBloc({
    required this.getTasksUseCase,
    required this.getFocusSessionsUseCase,
    required this.getCategoriesUseCase,
  }) : super(AnalyticsInitial()) {
    on<LoadAnalyticsEvent>(_onLoadAnalytics);
    on<ChangeAnalyticsTimeRangeEvent>(_onChangeTimeRange);
  }

  Future<void> _onLoadAnalytics(
    LoadAnalyticsEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading(timeRange: event.timeRange));
    await _computeAndEmitSummary(event.timeRange, emit);
  }

  Future<void> _onChangeTimeRange(
    ChangeAnalyticsTimeRangeEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading(timeRange: event.timeRange));
    await _computeAndEmitSummary(event.timeRange, emit);
  }

  Future<void> _computeAndEmitSummary(
    AnalyticsTimeRange timeRange,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      final tasks = await getTasksUseCase(const NoParams());
      final focusSessions = await getFocusSessionsUseCase();
      final categories = await getCategoriesUseCase(const NoParams());

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Determine date range cutoff
      DateTime startDate;
      switch (timeRange) {
        case AnalyticsTimeRange.daily:
          startDate = today.subtract(const Duration(days: 6));
          break;
        case AnalyticsTimeRange.weekly:
          startDate = today.subtract(const Duration(days: 27));
          break;
        case AnalyticsTimeRange.monthly:
          startDate = DateTime(now.year, now.month - 5, 1);
          break;
      }

      // Filter focus sessions in range
      final filteredSessions = focusSessions.where((s) {
        return !s.startTime.isBefore(startDate);
      }).toList();

      // Filter tasks in range (created or with due date in range)
      final filteredTasks = tasks.where((t) {
        final tDate = t.dueDate ?? t.createdAt;
        return !tDate.isBefore(startDate);
      }).toList();

      final int totalFocusMinutes = filteredSessions.fold<int>(
        0,
        (sum, s) => sum + s.durationMinutes,
      );

      final int totalTasksCompleted =
          filteredTasks.where((t) => t.isCompleted).length;
      final int totalTasksCreated =
          filteredTasks.isEmpty ? tasks.length : filteredTasks.length;
      final int totalFocusSessions = filteredSessions.length;

      // Compute Chart Data Points
      final List<ChartBarPoint> chartPoints = _generateChartPoints(
        timeRange,
        filteredSessions,
        filteredTasks,
        now,
      );

      // Compute Best Day
      String bestDayLabel = 'N/A';
      if (chartPoints.isNotEmpty) {
        final bestPoint = chartPoints.reduce(
            (curr, next) => curr.valueMinutes >= next.valueMinutes ? curr : next);
        if (bestPoint.valueMinutes > 0) {
          bestDayLabel = '${bestPoint.label} (${bestPoint.formattedDuration})';
        }
      }

      // Compute Category Distribution
      final List<CategoryAnalyticsItem> categoryBreakdown =
          _generateCategoryBreakdown(categories, tasks, filteredSessions);

      // Compute Consecutive Active Streak
      final int currentStreakDays =
          _calculateActiveStreak(tasks, focusSessions, today);

      // Compute Productivity Score (0-100)
      final int productivityScore = _calculateProductivityScore(
        totalTasksCompleted: totalTasksCompleted,
        totalTasksCreated: totalTasksCreated,
        totalFocusMinutes: totalFocusMinutes,
        streakDays: currentStreakDays,
        timeRange: timeRange,
      );

      // Recent sessions (up to 5 most recent)
      final sortedSessions = List<FocusSessionEntity>.from(focusSessions)
        ..sort((a, b) => b.startTime.compareTo(a.startTime));
      final recentSessions = sortedSessions.take(5).toList();

      emit(
        AnalyticsLoaded(
          summary: AnalyticsSummary(
            timeRange: timeRange,
            totalFocusMinutes: totalFocusMinutes,
            totalTasksCompleted: totalTasksCompleted,
            totalTasksCreated: totalTasksCreated,
            totalFocusSessions: totalFocusSessions,
            bestDayLabel: bestDayLabel,
            currentStreakDays: currentStreakDays,
            productivityScore: productivityScore,
            chartPoints: chartPoints,
            categoryBreakdown: categoryBreakdown,
            recentSessions: recentSessions,
          ),
        ),
      );
    } catch (e) {
      emit(AnalyticsError('Failed to calculate analytics: $e'));
    }
  }

  List<ChartBarPoint> _generateChartPoints(
    AnalyticsTimeRange timeRange,
    List<FocusSessionEntity> sessions,
    List<TaskEntity> tasks,
    DateTime now,
  ) {
    final List<ChartBarPoint> points = [];

    if (timeRange == AnalyticsTimeRange.daily) {
      // 7 days (today - 6 to today)
      for (int i = 6; i >= 0; i--) {
        final day = DateTime(now.year, now.month, now.day - i);
        final dayEnd = day.add(const Duration(days: 1));

        final dayMinutes = sessions
            .where((s) =>
                !s.startTime.isBefore(day) && s.startTime.isBefore(dayEnd))
            .fold<double>(0.0, (sum, s) => sum + s.durationMinutes);

        final dayTasks = tasks.where((t) {
          final tDate = t.dueDate ?? t.createdAt;
          return t.isCompleted &&
              !tDate.isBefore(day) &&
              tDate.isBefore(dayEnd);
        }).length;

        final label = DateFormat('E').format(day); // e.g. "Mon"
        points.add(
          ChartBarPoint(
            label: label,
            valueMinutes: dayMinutes,
            taskCount: dayTasks,
            date: day,
            isTargetDay: i == 0,
          ),
        );
      }
    } else if (timeRange == AnalyticsTimeRange.weekly) {
      // 4 weeks
      for (int i = 3; i >= 0; i--) {
        final weekStart = DateTime(
            now.year, now.month, now.day - (i * 7 + (now.weekday - 1)));
        final weekEnd = weekStart.add(const Duration(days: 7));

        final weekMinutes = sessions
            .where((s) =>
                !s.startTime.isBefore(weekStart) &&
                s.startTime.isBefore(weekEnd))
            .fold<double>(0.0, (sum, s) => sum + s.durationMinutes);

        final weekTasks = tasks.where((t) {
          final tDate = t.dueDate ?? t.createdAt;
          return t.isCompleted &&
              !tDate.isBefore(weekStart) &&
              tDate.isBefore(weekEnd);
        }).length;

        final label = i == 0 ? 'This Wk' : 'Wk -$i';
        points.add(
          ChartBarPoint(
            label: label,
            valueMinutes: weekMinutes,
            taskCount: weekTasks,
            date: weekStart,
            isTargetDay: i == 0,
          ),
        );
      }
    } else {
      // 6 months
      for (int i = 5; i >= 0; i--) {
        final monthDate = DateTime(now.year, now.month - i, 1);
        final nextMonth = DateTime(now.year, now.month - i + 1, 1);

        final monthMinutes = sessions
            .where((s) =>
                !s.startTime.isBefore(monthDate) &&
                s.startTime.isBefore(nextMonth))
            .fold<double>(0.0, (sum, s) => sum + s.durationMinutes);

        final monthTasks = tasks.where((t) {
          final tDate = t.dueDate ?? t.createdAt;
          return t.isCompleted &&
              !tDate.isBefore(monthDate) &&
              tDate.isBefore(nextMonth);
        }).length;

        final label = DateFormat('MMM').format(monthDate); // e.g. "Aug"
        points.add(
          ChartBarPoint(
            label: label,
            valueMinutes: monthMinutes,
            taskCount: monthTasks,
            date: monthDate,
            isTargetDay: i == 0,
          ),
        );
      }
    }

    return points;
  }

  List<CategoryAnalyticsItem> _generateCategoryBreakdown(
    List<TaskCategoryEntity> categories,
    List<TaskEntity> allTasks,
    List<FocusSessionEntity> sessions,
  ) {
    if (categories.isEmpty) return [];

    final categoryMinutesMap = <String, int>{};
    final categoryTasksCompletedMap = <String, int>{};

    for (final task in allTasks) {
      categoryMinutesMap[task.categoryId] =
          (categoryMinutesMap[task.categoryId] ?? 0) + task.spentMinutes;
      if (task.isCompleted) {
        categoryTasksCompletedMap[task.categoryId] =
            (categoryTasksCompletedMap[task.categoryId] ?? 0) + 1;
      }
    }

    final int totalCategoryMinutes =
        categoryMinutesMap.values.fold<int>(0, (sum, v) => sum + v);

    final items = categories.map((cat) {
      final spent = categoryMinutesMap[cat.id] ?? 0;
      final completed = categoryTasksCompletedMap[cat.id] ?? 0;
      final double share = totalCategoryMinutes > 0
          ? (spent / totalCategoryMinutes)
          : (1.0 / categories.length);

      return CategoryAnalyticsItem(
        categoryId: cat.id,
        categoryName: cat.name,
        iconCode: cat.iconCode,
        colorValue: cat.colorValue,
        spentMinutes: spent,
        tasksCompleted: completed,
        percentageShare: share,
      );
    }).toList();

    // Sort highest percentage first
    items.sort((a, b) => b.spentMinutes.compareTo(a.spentMinutes));
    return items;
  }

  int _calculateActiveStreak(
    List<TaskEntity> tasks,
    List<FocusSessionEntity> sessions,
    DateTime today,
  ) {
    int streak = 0;
    DateTime checkDay = today;

    // Check up to 30 consecutive past days
    for (int i = 0; i < 30; i++) {
      final checkDayEnd = checkDay.add(const Duration(days: 1));

      final hasSession = sessions.any((s) =>
          !s.startTime.isBefore(checkDay) && s.startTime.isBefore(checkDayEnd));
      final hasCompletedTask = tasks.any((t) {
        final tDate = t.dueDate ?? t.createdAt;
        return t.isCompleted &&
            !tDate.isBefore(checkDay) &&
            tDate.isBefore(checkDayEnd);
      });

      if (hasSession || hasCompletedTask) {
        streak++;
        checkDay = checkDay.subtract(const Duration(days: 1));
      } else if (i == 0) {
        // If nothing today yet, check starting from yesterday
        checkDay = checkDay.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  int _calculateProductivityScore({
    required int totalTasksCompleted,
    required int totalTasksCreated,
    required int totalFocusMinutes,
    required int streakDays,
    required AnalyticsTimeRange timeRange,
  }) {
    // 1. Completion Rate component (up to 40 pts)
    double completionScore = 0;
    if (totalTasksCreated > 0) {
      completionScore = (totalTasksCompleted / totalTasksCreated) * 40;
    } else {
      completionScore = 20; // baseline if no tasks created
    }

    // 2. Streak component (up to 30 pts)
    final double streakScore = (streakDays * 5).clamp(0, 30).toDouble();

    // 3. Focus Target component (up to 30 pts)
    int targetMinutes = 120; // 2 hrs default daily target
    if (timeRange == AnalyticsTimeRange.weekly) targetMinutes = 600; // 10 hrs
    if (timeRange == AnalyticsTimeRange.monthly) targetMinutes = 2400; // 40 hrs

    final double focusScore =
        ((totalFocusMinutes / targetMinutes) * 30).clamp(0, 30).toDouble();

    final int total = (completionScore + streakScore + focusScore).round();
    return total.clamp(0, 100);
  }
}
