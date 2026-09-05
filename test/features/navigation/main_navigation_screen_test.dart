import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wizdesk/core/constants/app_constants.dart';
import 'package:wizdesk/core/theme/bloc/theme_bloc.dart';
import 'package:wizdesk/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:wizdesk/features/analytics/presentation/bloc/analytics_event.dart';
import 'package:wizdesk/features/analytics/presentation/bloc/analytics_state.dart';
import 'package:wizdesk/features/focus/domain/services/timer_ticker.dart';
import 'package:wizdesk/features/focus/presentation/bloc/focus_bloc.dart';
import 'package:wizdesk/features/navigation/presentation/screens/main_navigation_screen.dart';
import 'package:wizdesk/features/settings/domain/models/user_preferences_model.dart';
import 'package:wizdesk/features/settings/domain/repositories/settings_repository.dart';
import 'package:wizdesk/features/settings/domain/usecases/clear_all_data_usecase.dart';
import 'package:wizdesk/features/settings/domain/usecases/get_settings_usecase.dart';
import 'package:wizdesk/features/settings/domain/usecases/reset_settings_usecase.dart';
import 'package:wizdesk/features/settings/domain/usecases/save_settings_usecase.dart';
import 'package:wizdesk/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:wizdesk/features/settings/presentation/bloc/settings_event.dart';
import 'package:wizdesk/features/settings/presentation/bloc/settings_state.dart';
import 'package:wizdesk/features/tasks/domain/entities/focus_session_entity.dart';
import 'package:wizdesk/features/tasks/domain/entities/task_category_entity.dart';
import 'package:wizdesk/features/tasks/domain/entities/task_entity.dart';
import 'package:wizdesk/features/tasks/domain/entities/task_enums.dart';
import 'package:wizdesk/features/tasks/domain/repositories/task_repository.dart';
import 'package:wizdesk/features/tasks/domain/usecases/add_task_usecase.dart';
import 'package:wizdesk/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:wizdesk/features/tasks/domain/usecases/get_categories_usecase.dart';
import 'package:wizdesk/features/tasks/domain/usecases/get_focus_sessions_usecase.dart';
import 'package:wizdesk/features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'package:wizdesk/features/tasks/domain/usecases/log_focus_session_usecase.dart';
import 'package:wizdesk/features/tasks/domain/usecases/update_task_usecase.dart';
import 'package:wizdesk/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:wizdesk/features/tasks/presentation/bloc/task_event.dart';
import 'package:wizdesk/features/tasks/presentation/bloc/task_state.dart';

class MockSettingsRepository implements SettingsRepository {
  UserPreferencesModel prefs = const UserPreferencesModel();

  @override
  Future<UserPreferencesModel> getPreferences() async => prefs;
  @override
  Future<void> savePreferences(UserPreferencesModel p) async => prefs = p;
  @override
  Future<void> resetToDefaults() async => prefs = const UserPreferencesModel();
  @override
  Future<void> clearAllData() async => prefs = const UserPreferencesModel();
}

class MockTaskRepository implements TaskRepository {
  final List<TaskEntity> _tasks = [
    TaskEntity(
      id: 'task_1',
      title: 'Navigation Integration Task',
      categoryId: 'cat_work',
      priority: TaskPriority.high,
      status: TaskStatus.todo,
      createdAt: DateTime.now(),
      estimatedMinutes: 30,
    ),
  ];
  final List<TaskCategoryEntity> _categories = [
    const TaskCategoryEntity(
      id: 'cat_work',
      name: 'Work',
      colorValue: 0xFF3B82F6,
      iconCode: 0xe6f2,
    ),
  ];
  final List<FocusSessionEntity> _sessions = [];

  @override
  Future<List<TaskEntity>> getTasks() async => List.from(_tasks);
  @override
  Future<TaskEntity?> getTaskById(String id) async =>
      _tasks.firstWhere((t) => t.id == id);
  @override
  Future<void> addTask(TaskEntity task) async => _tasks.add(task);
  @override
  Future<void> updateTask(TaskEntity task) async {
    final i = _tasks.indexWhere((t) => t.id == task.id);
    if (i != -1) _tasks[i] = task;
  }
  @override
  Future<void> deleteTask(String id) async =>
      _tasks.removeWhere((t) => t.id == id);
  @override
  Future<void> updateTaskStatus(String id, TaskStatus s) async {
    final i = _tasks.indexWhere((t) => t.id == id);
    if (i != -1) _tasks[i] = _tasks[i].copyWith(status: s);
  }
  @override
  Future<List<TaskCategoryEntity>> getCategories() async =>
      List.from(_categories);
  @override
  Future<void> addCategory(TaskCategoryEntity c) async => _categories.add(c);
  @override
  Future<void> deleteCategory(String id) async =>
      _categories.removeWhere((c) => c.id == id);
  @override
  Future<void> logFocusSession(FocusSessionEntity s) async => _sessions.add(s);
  @override
  Future<List<FocusSessionEntity>> getFocusSessions() async =>
      List.from(_sessions);
}

void main() {
  late MockSettingsRepository settingsRepo;
  late MockTaskRepository taskRepo;
  late SettingsBloc settingsBloc;
  late TaskBloc taskBloc;
  late FocusBloc focusBloc;
  late AnalyticsBloc analyticsBloc;

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    settingsRepo = MockSettingsRepository();
    taskRepo = MockTaskRepository();

    settingsBloc = SettingsBloc(
      getSettingsUseCase: GetSettingsUseCase(settingsRepo),
      saveSettingsUseCase: SaveSettingsUseCase(settingsRepo),
      resetSettingsUseCase: ResetSettingsUseCase(settingsRepo),
      clearAllDataUseCase: ClearAllDataUseCase(settingsRepo),
    );

    taskBloc = TaskBloc(
      getTasksUseCase: GetTasksUseCase(taskRepo),
      addTaskUseCase: AddTaskUseCase(taskRepo),
      updateTaskUseCase: UpdateTaskUseCase(taskRepo),
      deleteTaskUseCase: DeleteTaskUseCase(taskRepo),
      getCategoriesUseCase: GetCategoriesUseCase(taskRepo),
    );

    focusBloc = FocusBloc(
      ticker: const TimerTicker(),
      logFocusSessionUseCase: LogFocusSessionUseCase(taskRepo),
      updateTaskUseCase: UpdateTaskUseCase(taskRepo),
    );

    analyticsBloc = AnalyticsBloc(
      getTasksUseCase: GetTasksUseCase(taskRepo),
      getFocusSessionsUseCase: GetFocusSessionsUseCase(taskRepo),
      getCategoriesUseCase: GetCategoriesUseCase(taskRepo),
    );
  });

  tearDown(() {
    settingsBloc.close();
    taskBloc.close();
    focusBloc.close();
    analyticsBloc.close();
  });

  Widget buildTestWidget() {
    return ScreenUtilInit(
      designSize:
          const Size(AppConstants.designWidth, AppConstants.designHeight),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<ThemeBloc>(
              create: (_) => ThemeBloc(settingsRepository: settingsRepo),
            ),
            BlocProvider<SettingsBloc>.value(value: settingsBloc),
            BlocProvider<TaskBloc>.value(value: taskBloc),
            BlocProvider<FocusBloc>.value(value: focusBloc),
            BlocProvider<AnalyticsBloc>.value(value: analyticsBloc),
          ],
          child: const MaterialApp(
            home: MainNavigationScreen(),
          ),
        );
      },
    );
  }

  testWidgets('MainNavigationScreen transitions across all 4 tabs seamlessly',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    await tester.runAsync(() async {
      final taskLoadedFuture =
          taskBloc.stream.firstWhere((s) => s is TaskLoaded);
      final settingsLoadedFuture =
          settingsBloc.stream.firstWhere((s) => s is SettingsLoaded);
      final analyticsLoadedFuture =
          analyticsBloc.stream.firstWhere((s) => s is AnalyticsLoaded);

      taskBloc.add(const LoadTasksEvent());
      settingsBloc.add(const LoadSettingsEvent());
      analyticsBloc.add(const LoadAnalyticsEvent());

      await Future.wait([
        taskLoadedFuture,
        settingsLoadedFuture,
        analyticsLoadedFuture,
      ]);
    });

    await tester.pumpWidget(buildTestWidget());

    // 1. Tab 0: Verify Today (Home Tasks Dashboard) loaded
    expect(find.byType(MainNavigationScreen), findsOneWidget);

    // 2. Switch to Tab 1: Calendar
    final calendarTab = find.byKey(const ValueKey('nav_item_1'));
    expect(calendarTab, findsOneWidget);
    await tester.tap(calendarTab);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Schedule Calendar'), findsOneWidget);
    expect(find.text('Navigation Integration Task'), findsOneWidget);

    // 3. Switch to Tab 2: Focus Timer
    final focusTab = find.byKey(const ValueKey('nav_item_2'));
    expect(focusTab, findsOneWidget);
    await tester.tap(focusTab);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Deep Focus'), findsOneWidget);
    expect(find.text('25:00'), findsOneWidget);

    // 4. Switch to Tab 3: Analytics
    final analyticsTab = find.byKey(const ValueKey('nav_item_3'));
    expect(analyticsTab, findsOneWidget);
    await tester.tap(analyticsTab);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Productivity Analytics'), findsOneWidget);
    expect(find.text('Focus Activity'), findsOneWidget);

    // 5. Switch to Tab 4: Settings
    final settingsTab = find.byKey(const ValueKey('nav_item_4'));
    expect(settingsTab, findsOneWidget);
    await tester.tap(settingsTab);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Profile & Settings'), findsOneWidget);
    expect(find.text('Focus Timer Setup'), findsOneWidget);

    // 6. Switch back to Today and test Header Add Task button
    final todayTab = find.byKey(const ValueKey('nav_item_0'));
    await tester.tap(todayTab);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final headerAddBtn = find.byKey(const ValueKey('today_add_task_header_btn'));
    expect(headerAddBtn, findsOneWidget);
    await tester.tap(headerAddBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Create Task'), findsOneWidget);
  });
}
