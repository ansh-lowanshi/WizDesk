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
  final TaskFrequency frequency;
  final List<int> customDays;
  final int estimatedMinutes;
  final int spentMinutes;
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
    this.frequency = TaskFrequency.once,
    this.customDays = const [],
    this.estimatedMinutes = 25,
    this.spentMinutes = 0,
    this.isFocusModeEnabled = true,
    required this.createdAt,
    this.completedAt,
  });

  /// Check if the task is completed
  bool get isCompleted => status == TaskStatus.completed;

  /// Check if the task is due today
  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  /// Completion percentage based on focus time spent vs estimated
  double get progressPercentage {
    if (isCompleted) return 1.0;
    if (estimatedMinutes <= 0) return 0.0;
    final ratio = spentMinutes / estimatedMinutes;
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
    TaskFrequency? frequency,
    List<int>? customDays,
    int? estimatedMinutes,
    int? spentMinutes,
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
      frequency: frequency ?? this.frequency,
      customDays: customDays ?? this.customDays,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      spentMinutes: spentMinutes ?? this.spentMinutes,
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
        frequency,
        customDays,
        estimatedMinutes,
        spentMinutes,
        isFocusModeEnabled,
        createdAt,
        completedAt,
      ];
}
