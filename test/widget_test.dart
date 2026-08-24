import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wizdesk/core/di/injection_container.dart' as di;
import 'package:wizdesk/features/tasks/data/datasources/task_local_datasource.dart';
import 'package:wizdesk/features/tasks/data/models/focus_session_model.dart';
import 'package:wizdesk/features/tasks/data/models/task_category_model.dart';
import 'package:wizdesk/features/tasks/data/models/task_model.dart';
import 'package:wizdesk/features/tasks/domain/entities/task_enums.dart';
import 'package:wizdesk/main.dart';

void main() {
  setUp(() async {
    await di.sl.reset();
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    di.sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

    // Initialize mock in-memory data source for widget testing
    final mockLocalDataSource = MockTestTaskLocalDataSource();
    await mockLocalDataSource.seedInitialDataIfEmpty();

    di.sl.registerLazySingleton<TaskLocalDataSource>(() => mockLocalDataSource);
    await di.initServiceLocator(isTesting: true);
  });

  testWidgets('Wiz Desk HomeDashboardScreen builds and displays tasks',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const WizDeskApp());
    await tester.pumpAndSettle();

    expect(find.byType(WizDeskApp), findsOneWidget);
    expect(find.text('Good Day, Creator 👋'), findsOneWidget);
    expect(find.text('TODAY\'S PROGRESS'), findsOneWidget);
  });
}

class MockTestTaskLocalDataSource implements TaskLocalDataSource {
  final List<TaskModel> _tasks = [];
  final List<TaskCategoryModel> _categories = [];

  @override
  Future<List<TaskModel>> getTasks() async => List.from(_tasks);

  @override
  Future<TaskModel?> getTaskById(String taskId) async {
    try {
      return _tasks.firstWhere((t) => t.id == taskId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveTask(TaskModel task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
    } else {
      _tasks.add(task);
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((t) => t.id == taskId);
  }

  @override
  Future<List<TaskCategoryModel>> getCategories() async => List.from(_categories);

  @override
  Future<void> saveCategory(TaskCategoryModel category) async {
    _categories.add(category);
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    _categories.removeWhere((c) => c.id == categoryId);
  }

  @override
  Future<void> logFocusSession(FocusSessionModel session) async {}

  @override
  Future<List<FocusSessionModel>> getFocusSessions() async => [];

  @override
  Future<void> seedInitialDataIfEmpty() async {
    _categories.addAll([
      const TaskCategoryModel(
        id: 'cat_design',
        name: 'Design',
        iconCode: 0xe471,
        colorValue: 0xFFFF6B6B,
      ),
      const TaskCategoryModel(
        id: 'cat_coding',
        name: 'Coding',
        iconCode: 0xe194,
        colorValue: 0xFF00F0FF,
      ),
    ]);

    _tasks.add(
      TaskModel(
        id: 'test_1',
        title: 'Design high-fidelity UI components',
        description: 'Refine dark mode glow effects',
        categoryId: 'cat_design',
        priority: TaskPriority.high,
        status: TaskStatus.inProgress,
        dueDate: DateTime.now(),
        frequency: TaskFrequency.daily,
        estimatedMinutes: 50,
        spentMinutes: 25,
        isFocusModeEnabled: true,
        createdAt: DateTime.now(),
      ),
    );
  }
}
