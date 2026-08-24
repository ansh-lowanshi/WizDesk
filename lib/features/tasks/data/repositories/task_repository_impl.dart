import '../../domain/entities/focus_session_entity.dart';
import '../../domain/entities/task_category_entity.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_enums.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_datasource.dart';
import '../models/focus_session_model.dart';
import '../models/task_category_model.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;

  TaskRepositoryImpl({required this.localDataSource});

  @override
  Future<List<TaskEntity>> getTasks() async {
    return await localDataSource.getTasks();
  }

  @override
  Future<TaskEntity?> getTaskById(String taskId) async {
    return await localDataSource.getTaskById(taskId);
  }

  @override
  Future<void> addTask(TaskEntity task) async {
    final model = TaskModel.fromEntity(task);
    await localDataSource.saveTask(model);
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    final model = TaskModel.fromEntity(task);
    await localDataSource.saveTask(model);
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await localDataSource.deleteTask(taskId);
  }

  @override
  Future<void> updateTaskStatus(String taskId, TaskStatus newStatus) async {
    final existingTask = await localDataSource.getTaskById(taskId);
    if (existingTask != null) {
      final updated = existingTask.copyWith(
        status: newStatus,
        completedAt: newStatus == TaskStatus.completed ? DateTime.now() : null,
      );
      await localDataSource.saveTask(TaskModel.fromEntity(updated));
    }
  }

  @override
  Future<List<TaskCategoryEntity>> getCategories() async {
    return await localDataSource.getCategories();
  }

  @override
  Future<void> addCategory(TaskCategoryEntity category) async {
    final model = TaskCategoryModel.fromEntity(category);
    await localDataSource.saveCategory(model);
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    await localDataSource.deleteCategory(categoryId);
  }

  @override
  Future<void> logFocusSession(FocusSessionEntity session) async {
    final model = FocusSessionModel.fromEntity(session);
    await localDataSource.logFocusSession(model);
  }

  @override
  Future<List<FocusSessionEntity>> getFocusSessions() async {
    return await localDataSource.getFocusSessions();
  }
}
