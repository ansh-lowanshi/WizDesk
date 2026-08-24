import '../entities/focus_session_entity.dart';
import '../entities/task_category_entity.dart';
import '../entities/task_entity.dart';
import '../entities/task_enums.dart';

/// Abstract contract for Task and Category persistence & retrieval
abstract class TaskRepository {
  /// Fetch all tasks from storage
  Future<List<TaskEntity>> getTasks();

  /// Fetch a single task by its unique ID
  Future<TaskEntity?> getTaskById(String taskId);

  /// Add a newly created task
  Future<void> addTask(TaskEntity task);

  /// Update an existing task
  Future<void> updateTask(TaskEntity task);

  /// Delete a task by ID
  Future<void> deleteTask(String taskId);

  /// Change task lifecycle status
  Future<void> updateTaskStatus(String taskId, TaskStatus newStatus);

  /// Fetch all configured categories
  Future<List<TaskCategoryEntity>> getCategories();

  /// Add a custom category
  Future<void> addCategory(TaskCategoryEntity category);

  /// Delete a category by ID
  Future<void> deleteCategory(String categoryId);

  /// Log a focus session
  Future<void> logFocusSession(FocusSessionEntity session);

  /// Fetch all recorded focus sessions
  Future<List<FocusSessionEntity>> getFocusSessions();
}
