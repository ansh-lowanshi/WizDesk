import 'package:hive/hive.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/task_enums.dart';
import '../models/focus_session_model.dart';
import '../models/task_category_model.dart';
import '../models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getTasks();
  Future<TaskModel?> getTaskById(String taskId);
  Future<void> saveTask(TaskModel task);
  Future<void> deleteTask(String taskId);
  Future<List<TaskCategoryModel>> getCategories();
  Future<void> saveCategory(TaskCategoryModel category);
  Future<void> deleteCategory(String categoryId);
  Future<void> logFocusSession(FocusSessionModel session);
  Future<List<FocusSessionModel>> getFocusSessions();
  Future<void> seedInitialDataIfEmpty();
  Future<void> clearAllData();
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final Box tasksBox;
  final Box categoriesBox;
  final Box sessionsBox;

  TaskLocalDataSourceImpl({
    required this.tasksBox,
    required this.categoriesBox,
    required this.sessionsBox,
  });

  @override
  Future<void> clearAllData() async {
    try {
      await tasksBox.clear();
      await categoriesBox.clear();
      await sessionsBox.clear();
    } catch (e) {
      throw CacheException('Failed to clear database: $e');
    }
  }

  @override
  Future<List<TaskModel>> getTasks() async {
    try {
      final List<TaskModel> tasks = [];
      for (final key in tasksBox.keys) {
        final raw = tasksBox.get(key);
        if (raw is Map) {
          tasks.add(TaskModel.fromMap(raw));
        }
      }
      // Sort tasks: Urgent/High first, then by due date
      tasks.sort((a, b) {
        if (a.status == TaskStatus.completed && b.status != TaskStatus.completed) return 1;
        if (a.status != TaskStatus.completed && b.status == TaskStatus.completed) return -1;
        return b.priority.rank.compareTo(a.priority.rank);
      });
      return tasks;
    } catch (e) {
      throw CacheException('Failed to read tasks from local storage: $e');
    }
  }

  @override
  Future<TaskModel?> getTaskById(String taskId) async {
    try {
      final raw = tasksBox.get(taskId);
      if (raw is Map) {
        return TaskModel.fromMap(raw);
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to retrieve task $taskId: $e');
    }
  }

  @override
  Future<void> saveTask(TaskModel task) async {
    try {
      await tasksBox.put(task.id, task.toMap());
    } catch (e) {
      throw CacheException('Failed to save task to local storage: $e');
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      await tasksBox.delete(taskId);
    } catch (e) {
      throw CacheException('Failed to delete task from local storage: $e');
    }
  }

  @override
  Future<List<TaskCategoryModel>> getCategories() async {
    try {
      final List<TaskCategoryModel> categories = [];
      for (final key in categoriesBox.keys) {
        final raw = categoriesBox.get(key);
        if (raw is Map) {
          categories.add(TaskCategoryModel.fromMap(raw));
        }
      }
      return categories;
    } catch (e) {
      throw CacheException('Failed to fetch categories: $e');
    }
  }

  @override
  Future<void> saveCategory(TaskCategoryModel category) async {
    try {
      await categoriesBox.put(category.id, category.toMap());
    } catch (e) {
      throw CacheException('Failed to save category: $e');
    }
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    try {
      await categoriesBox.delete(categoryId);
    } catch (e) {
      throw CacheException('Failed to delete category: $e');
    }
  }

  @override
  Future<void> logFocusSession(FocusSessionModel session) async {
    try {
      await sessionsBox.put(session.id, session.toMap());
    } catch (e) {
      throw CacheException('Failed to log focus session: $e');
    }
  }

  @override
  Future<List<FocusSessionModel>> getFocusSessions() async {
    try {
      final List<FocusSessionModel> sessions = [];
      for (final key in sessionsBox.keys) {
        final raw = sessionsBox.get(key);
        if (raw is Map) {
          sessions.add(FocusSessionModel.fromMap(raw));
        }
      }
      sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
      return sessions;
    } catch (e) {
      throw CacheException('Failed to retrieve focus sessions: $e');
    }
  }

  @override
  Future<void> seedInitialDataIfEmpty() async {
    // Seed default categories if box is empty
    if (categoriesBox.isEmpty) {
      final defaultCategories = [
        const TaskCategoryModel(
          id: 'cat_work',
          name: 'Work',
          iconCode: 0xe6f2, // work outline
          colorValue: 0xFF3874FF,
        ),
        const TaskCategoryModel(
          id: 'cat_study',
          name: 'Study',
          iconCode: 0xe559, // school
          colorValue: 0xFF7F56D9,
        ),
        const TaskCategoryModel(
          id: 'cat_coding',
          name: 'Coding',
          iconCode: 0xe194, // code
          colorValue: 0xFF00F0FF,
        ),
        const TaskCategoryModel(
          id: 'cat_design',
          name: 'Design',
          iconCode: 0xe471, // palette
          colorValue: 0xFFFF6B6B,
        ),
        const TaskCategoryModel(
          id: 'cat_fitness',
          name: 'Fitness',
          iconCode: 0xe294, // fitness_center
          colorValue: 0xFF10B981,
        ),
        const TaskCategoryModel(
          id: 'cat_personal',
          name: 'Personal',
          iconCode: 0xe491, // person
          colorValue: 0xFFFFB020,
        ),
      ];

      for (final cat in defaultCategories) {
        await categoriesBox.put(cat.id, cat.toMap());
      }
    }

    // Seed default starter tasks if tasks box is empty
    if (tasksBox.isEmpty) {
      final now = DateTime.now();
      final starterTasks = [
        TaskModel(
          id: 'task_starter_1',
          title: 'Design high-fidelity UI components',
          description: 'Refine dark mode glow effects, buttons, and responsive cards for Wiz Desk.',
          categoryId: 'cat_design',
          priority: TaskPriority.high,
          status: TaskStatus.inProgress,
          dueDate: now,
          frequency: TaskFrequency.daily,
          estimatedMinutes: 50,
          spentMinutes: 25,
          isFocusModeEnabled: true,
          createdAt: now.subtract(const Duration(hours: 3)),
        ),
        TaskModel(
          id: 'task_starter_2',
          title: 'Morning code review & architecture sync',
          description: 'Check clean architecture boundaries, entities, and use cases.',
          categoryId: 'cat_coding',
          priority: TaskPriority.urgent,
          status: TaskStatus.todo,
          dueDate: now,
          frequency: TaskFrequency.once,
          estimatedMinutes: 30,
          spentMinutes: 0,
          isFocusModeEnabled: true,
          createdAt: now.subtract(const Duration(hours: 1)),
        ),
        TaskModel(
          id: 'task_starter_3',
          title: 'Study Flutter BLoC state management patterns',
          description: 'Read event-driven reactive state transition documentation.',
          categoryId: 'cat_study',
          priority: TaskPriority.medium,
          status: TaskStatus.completed,
          dueDate: now.subtract(const Duration(days: 1)),
          frequency: TaskFrequency.weekly,
          customDays: const [1, 3, 5],
          estimatedMinutes: 25,
          spentMinutes: 25,
          isFocusModeEnabled: true,
          createdAt: now.subtract(const Duration(days: 1)),
          completedAt: now.subtract(const Duration(hours: 5)),
        ),
      ];

      for (final task in starterTasks) {
        await tasksBox.put(task.id, task.toMap());
      }
    }
  }
}
