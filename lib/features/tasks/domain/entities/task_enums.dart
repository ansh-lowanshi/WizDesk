import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';

/// Priority levels for tasks
enum TaskPriority {
  urgent('Urgent', 4, AppColors.priorityUrgent),
  high('High', 3, AppColors.priorityHigh),
  medium('Medium', 2, AppColors.priorityMedium),
  low('Low', 1, AppColors.priorityLow);

  final String label;
  final int rank;
  final Color color;

  const TaskPriority(this.label, this.rank, this.color);

  String localizedLabel(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case TaskPriority.urgent:
        return l10n.priorityUrgent;
      case TaskPriority.high:
        return l10n.priorityHigh;
      case TaskPriority.medium:
        return l10n.priorityMedium;
      case TaskPriority.low:
        return l10n.priorityLow;
    }
  }

  static TaskPriority fromString(String value) {
    return TaskPriority.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase() || e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => TaskPriority.medium,
    );
  }
}

/// Lifecycle status of a task
enum TaskStatus {
  todo('To Do', AppColors.statusTodo),
  inProgress('In Progress', AppColors.statusInProgress),
  completed('Completed', AppColors.statusCompleted),
  archived('Archived', AppColors.statusArchived);

  final String label;
  final Color color;

  const TaskStatus(this.label, this.color);

  static TaskStatus fromString(String value) {
    return TaskStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase() || e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => TaskStatus.todo,
    );
  }
}

/// Recurrence / Frequency of a task
enum TaskFrequency {
  once('Once'),
  daily('Daily'),
  weekly('Weekly'),
  customDays('Custom Days');

  final String label;

  const TaskFrequency(this.label);

  String localizedLabel(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case TaskFrequency.once:
        return l10n.frequencyOnce;
      case TaskFrequency.daily:
        return l10n.frequencyDaily;
      case TaskFrequency.weekly:
        return l10n.frequencyWeekly;
      case TaskFrequency.customDays:
        return l10n.frequencyCustomDays;
    }
  }

  static TaskFrequency fromString(String value) {
    return TaskFrequency.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase() || e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => TaskFrequency.once,
    );
  }
}

/// Progress Tracking Mode for tasks
enum TaskProgressMode {
  individual('Individual / Daily', 'Each day tracks progress independently (0-100%)'),
  cumulative('Cumulative', 'Progress accumulates across all days towards total completion');

  final String label;
  final String description;

  const TaskProgressMode(this.label, this.description);

  static TaskProgressMode fromString(String value) {
    return TaskProgressMode.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase() || e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => TaskProgressMode.individual,
    );
  }
}

