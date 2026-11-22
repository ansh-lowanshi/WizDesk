import 'package:equatable/equatable.dart';
import 'task_enums.dart';

/// Domain entity representing a task in Wiz Desk
class TaskEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String categoryId;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime? dueDate;
  final DateTime? endDate;
  final TaskFrequency frequency;
  final TaskProgressMode progressMode;
  final List<int> customDays;
  final List<String> completedDates;
  final Map<String, int> dailyProgress;
  final Map<String, int> dailySpentMinutes;
  final Map<String, String> dailyDescriptions;
  final int estimatedMinutes;
  final int pomodoroWorkMinutes;
  final int spentMinutes;
  final int progressPercent;
  final bool isFocusModeEnabled;
  final DateTime createdAt;
  final DateTime? completedAt;

  const TaskEntity({
    required this.id,
    required this.title,
    this.description = '',
    required this.categoryId,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.todo,
    this.dueDate,
    this.endDate,
    this.frequency = TaskFrequency.once,
    this.progressMode = TaskProgressMode.individual,
    this.customDays = const [],
    this.completedDates = const [],
    this.dailyProgress = const {},
    this.dailySpentMinutes = const {},
    this.dailyDescriptions = const {},
    this.estimatedMinutes = 25,
    this.pomodoroWorkMinutes = 25,
    this.spentMinutes = 0,
    this.progressPercent = 0,
    this.isFocusModeEnabled = true,
    required this.createdAt,
    this.completedAt,
  });

  /// Check if the task is completed overall or today
  bool get isCompleted =>
      status == TaskStatus.completed ||
      (estimatedMinutes > 0 && spentMinutes >= estimatedMinutes);

  /// Format date to YYYY-MM-DD key for daily maps
  static String formatDateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Check if the task is completed on a specific calendar date
  bool isCompletedOn(DateTime date) {
    final dateStr = formatDateKey(date);
    if (completedDates.contains(dateStr)) return true;
    if (status == TaskStatus.completed) {
      if (dueDate != null && frequency == TaskFrequency.once) {
        return date.year == dueDate!.year &&
            date.month == dueDate!.month &&
            date.day == dueDate!.day;
      }
      return true;
    }
    if (estimatedMinutes > 0 && getSpentMinutesFor(date) >= estimatedMinutes) {
      return true;
    }
    return false;
  }

  /// Check if the task is due today
  bool get isDueToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startRaw = dueDate ?? createdAt;
    final startDate = DateTime(startRaw.year, startRaw.month, startRaw.day);

    if (today.isBefore(startDate)) return false;
    if (endDate != null) {
      final end = DateTime(endDate!.year, endDate!.month, endDate!.day);
      if (today.isAfter(end)) return false;
    }

    switch (frequency) {
      case TaskFrequency.once:
        return today.isAtSameMomentAs(startDate);
      case TaskFrequency.daily:
        return true;
      case TaskFrequency.weekly:
        return today.weekday == startDate.weekday;
      case TaskFrequency.customDays:
        if (customDays.isEmpty) return today.isAtSameMomentAs(startDate);
        return customDays.contains(today.weekday);
    }
  }

  /// Get the effective progress percentage for a specific date (or overall)
  int getProgressPercentFor([DateTime? date]) {
    final targetDate = date ?? DateTime.now();
    if (isCompletedOn(targetDate)) return 100;

    final spent = getSpentMinutesFor(targetDate);
    if (estimatedMinutes > 0 && spent >= estimatedMinutes) {
      return 100;
    }

    if (progressMode == TaskProgressMode.cumulative ||
        frequency == TaskFrequency.once) {
      return progressPercent;
    }

    final key = formatDateKey(targetDate);
    if (dailyProgress.containsKey(key)) {
      final recorded = dailyProgress[key]!;
      if (dailyProgress.length <= 1 && progressPercent > recorded) {
        return progressPercent;
      }
      return recorded;
    }
    if (estimatedMinutes > 0 && spent > 0) {
      final calc = ((spent / estimatedMinutes) * 100).round();
      return calc > 100 ? 100 : calc;
    }
    if (dailyProgress.isEmpty && progressPercent > 0) {
      return progressPercent;
    }
    return 0;
  }

  /// Remaining focus minutes for the task on a target date (estimated - spent)
  int getRemainingMinutesFor([DateTime? date]) {
    final spent = getSpentMinutesFor(date);
    final remaining = estimatedMinutes - spent;
    return remaining > 0 ? remaining : 0;
  }

  /// Get the spent minutes for a specific date (or overall)
  int getSpentMinutesFor([DateTime? date]) {
    final targetDate = date ?? DateTime.now();
    if (progressMode == TaskProgressMode.cumulative || frequency == TaskFrequency.once) {
      return spentMinutes;
    }

    final key = formatDateKey(targetDate);
    if (dailySpentMinutes.containsKey(key)) {
      final recorded = dailySpentMinutes[key]!;
      if (dailySpentMinutes.length <= 1 && spentMinutes > recorded) {
        return spentMinutes;
      }
      return recorded;
    }
    if (dailySpentMinutes.isEmpty && spentMinutes > 0) {
      return spentMinutes;
    }
    return 0;
  }

  /// Get the task description for a specific date (custom override if set, else base)
  String getDescriptionFor([DateTime? date]) {
    if (date != null) {
      final key = formatDateKey(date);
      if (dailyDescriptions.containsKey(key) &&
          dailyDescriptions[key]!.trim().isNotEmpty) {
        return dailyDescriptions[key]!;
      }
    }
    return description;
  }

  /// Overall completion percentage (0.0 to 1.0) based on base progress/spent
  double get progressPercentage {
    if (isCompleted) return 1.0;
    if (progressPercent > 0) {
      return (progressPercent / 100.0).clamp(0.0, 1.0);
    }
    if (estimatedMinutes <= 0) return 0.0;
    final ratio = spentMinutes / estimatedMinutes;
    return ratio > 1.0 ? 1.0 : ratio;
  }

  /// Completion percentage ratio for a specific date
  double getProgressPercentageFor([DateTime? date]) {
    final targetDate = date ?? DateTime.now();
    if (isCompletedOn(targetDate)) return 1.0;

    final currentPercent = getProgressPercentFor(targetDate);
    if (currentPercent > 0) {
      return (currentPercent / 100.0).clamp(0.0, 1.0);
    }

    final currentSpent = getSpentMinutesFor(targetDate);
    if (estimatedMinutes <= 0) return 0.0;
    final ratio = currentSpent / estimatedMinutes;
    return ratio > 1.0 ? 1.0 : ratio;
  }

  TaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? categoryId,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
    DateTime? endDate,
    TaskFrequency? frequency,
    TaskProgressMode? progressMode,
    List<int>? customDays,
    List<String>? completedDates,
    Map<String, int>? dailyProgress,
    Map<String, int>? dailySpentMinutes,
    Map<String, String>? dailyDescriptions,
    int? estimatedMinutes,
    int? pomodoroWorkMinutes,
    int? spentMinutes,
    int? progressPercent,
    bool? isFocusModeEnabled,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      endDate: endDate ?? this.endDate,
      frequency: frequency ?? this.frequency,
      progressMode: progressMode ?? this.progressMode,
      customDays: customDays ?? this.customDays,
      completedDates: completedDates ?? this.completedDates,
      dailyProgress: dailyProgress ?? this.dailyProgress,
      dailySpentMinutes: dailySpentMinutes ?? this.dailySpentMinutes,
      dailyDescriptions: dailyDescriptions ?? this.dailyDescriptions,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      pomodoroWorkMinutes: pomodoroWorkMinutes ?? this.pomodoroWorkMinutes,
      spentMinutes: spentMinutes ?? this.spentMinutes,
      progressPercent: progressPercent ?? this.progressPercent,
      isFocusModeEnabled: isFocusModeEnabled ?? this.isFocusModeEnabled,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        categoryId,
        priority,
        status,
        dueDate,
        endDate,
        frequency,
        progressMode,
        customDays,
        completedDates,
        dailyProgress,
        dailySpentMinutes,
        dailyDescriptions,
        estimatedMinutes,
        pomodoroWorkMinutes,
        spentMinutes,
        progressPercent,
        isFocusModeEnabled,
        createdAt,
        completedAt,
      ];
}
