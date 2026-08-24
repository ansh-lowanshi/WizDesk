import 'package:equatable/equatable.dart';
import '../../domain/entities/task_category_entity.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_enums.dart';

/// Status Filter Tab options
enum TaskStatusFilter {
  all('All'),
  inProgress('In Progress'),
  pending('Pending'),
  completed('Completed');

  final String label;
  const TaskStatusFilter(this.label);
}

/// Date Filter options
enum TaskDateFilter {
  all('All Dates'),
  today('Today'),
  upcoming('Upcoming'),
  overdue('Overdue');

  final String label;
  const TaskDateFilter(this.label);
}

/// Base abstract class for Task Events
abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

/// Load or refresh all tasks and categories from storage
class LoadTasksEvent extends TaskEvent {
  const LoadTasksEvent();
}

/// Add a new task
class AddTaskEvent extends TaskEvent {
  final TaskEntity task;

  const AddTaskEvent(this.task);

  @override
  List<Object?> get props => [task];
}

/// Update an existing task
class UpdateTaskEvent extends TaskEvent {
  final TaskEntity task;

  const UpdateTaskEvent(this.task);

  @override
  List<Object?> get props => [task];
}

/// Delete a task by ID
class DeleteTaskEvent extends TaskEvent {
  final String taskId;

  const DeleteTaskEvent(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

/// Toggle task completion status
class ToggleTaskStatusEvent extends TaskEvent {
  final String taskId;

  const ToggleTaskStatusEvent(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

/// Set a specific status directly (e.g. In Progress, Todo, Completed)
class UpdateTaskStatusDirectEvent extends TaskEvent {
  final String taskId;
  final TaskStatus status;

  const UpdateTaskStatusDirectEvent({
    required this.taskId,
    required this.status,
  });

  @override
  List<Object?> get props => [taskId, status];
}

/// Filter by status tab (All, In Progress, Pending, Completed)
class FilterByStatusEvent extends TaskEvent {
  final TaskStatusFilter statusFilter;

  const FilterByStatusEvent(this.statusFilter);

  @override
  List<Object?> get props => [statusFilter];
}

/// Filter by specific category
class FilterByCategoryEvent extends TaskEvent {
  final String? categoryId; // null represents "All Categories"

  const FilterByCategoryEvent(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

/// Filter by priority level
class FilterByPriorityEvent extends TaskEvent {
  final TaskPriority? priority; // null represents "All Priorities"

  const FilterByPriorityEvent(this.priority);

  @override
  List<Object?> get props => [priority];
}

/// Filter by date timeframe
class FilterByDateEvent extends TaskEvent {
  final TaskDateFilter dateFilter;

  const FilterByDateEvent(this.dateFilter);

  @override
  List<Object?> get props => [dateFilter];
}

/// Search tasks by keyword in title or description
class SearchTasksEvent extends TaskEvent {
  final String query;

  const SearchTasksEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Add a new custom user category
class AddCategoryEvent extends TaskEvent {
  final TaskCategoryEntity category;

  const AddCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}
