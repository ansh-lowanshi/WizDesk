import 'package:equatable/equatable.dart';
import '../../domain/entities/task_category_entity.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_enums.dart';
import 'task_event.dart';

/// Base abstract state for Task BLoC
abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

/// Initial uninitialized state
class TaskInitial extends TaskState {
  const TaskInitial();
}

/// Loading state
class TaskLoading extends TaskState {
  const TaskLoading();
}

/// Loaded state containing complete datasets and active filters
class TaskLoaded extends TaskState {
  final List<TaskEntity> allTasks;
  final List<TaskEntity> filteredTasks;
  final List<TaskCategoryEntity> categories;
  final TaskStatusFilter statusFilter;
  final String? categoryFilterId; // null = all
  final TaskPriority? priorityFilter; // null = all
  final TaskDateFilter dateFilter;
  final String searchQuery;

  const TaskLoaded({
    required this.allTasks,
    required this.filteredTasks,
    required this.categories,
    this.statusFilter = TaskStatusFilter.all,
    this.categoryFilterId,
    this.priorityFilter,
    this.dateFilter = TaskDateFilter.today,
    this.searchQuery = '',
  });

  // Analytics & Summary Getters
  int get totalTasksCount => allTasks.length;

  int get completedTasksCount =>
      allTasks.where((t) => t.isCompleted).length;

  int get pendingTasksCount =>
      allTasks.where((t) => !t.isCompleted && t.status == TaskStatus.todo).length;

  int get inProgressTasksCount =>
      allTasks.where((t) => !t.isCompleted && t.status == TaskStatus.inProgress).length;

  int get todayTasksCount => allTasks.where((t) => t.isDueToday).length;

  List<TaskEntity> get todayTasks =>
      allTasks.where((t) => t.isDueToday).toList();

  int get todayCompletedTasksCount {
    final now = DateTime.now();
    return todayTasks.where((t) => t.isCompletedOn(now)).length;
  }

  int get todayFocusMinutes {
    final now = DateTime.now();
    return todayTasks.fold<int>(0, (sum, t) => sum + t.getSpentMinutesFor(now));
  }

  double get completionRatePercentage {
    if (allTasks.isEmpty) return 0.0;
    return completedTasksCount / allTasks.length;
  }

  /// Get count of tasks in a specific category
  int countTasksInCategory(String categoryId) {
    return allTasks.where((t) => t.categoryId == categoryId).length;
  }

  /// Find Category Entity by ID
  TaskCategoryEntity? getCategoryById(String categoryId) {
    try {
      return categories.firstWhere((c) => c.id == categoryId);
    } catch (_) {
      return null;
    }
  }

  TaskLoaded copyWith({
    List<TaskEntity>? allTasks,
    List<TaskEntity>? filteredTasks,
    List<TaskCategoryEntity>? categories,
    TaskStatusFilter? statusFilter,
    String? Function()? categoryFilterId,
    TaskPriority? Function()? priorityFilter,
    TaskDateFilter? dateFilter,
    String? searchQuery,
  }) {
    return TaskLoaded(
      allTasks: allTasks ?? this.allTasks,
      filteredTasks: filteredTasks ?? this.filteredTasks,
      categories: categories ?? this.categories,
      statusFilter: statusFilter ?? this.statusFilter,
      categoryFilterId: categoryFilterId != null
          ? categoryFilterId()
          : this.categoryFilterId,
      priorityFilter: priorityFilter != null
          ? priorityFilter()
          : this.priorityFilter,
      dateFilter: dateFilter ?? this.dateFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        allTasks,
        filteredTasks,
        categories,
        statusFilter,
        categoryFilterId,
        priorityFilter,
        dateFilter,
        searchQuery,
      ];
}

/// Error state with failure message
class TaskError extends TaskState {
  final String message;

  const TaskError(this.message);

  @override
  List<Object?> get props => [message];
}
