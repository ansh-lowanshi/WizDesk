import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wizdesk/core/constants/app_constants.dart';
import 'package:wizdesk/core/localization/app_language.dart';
import 'package:wizdesk/core/localization/app_localizations.dart';
import 'package:wizdesk/core/localization/bloc/locale_bloc.dart';
import 'package:wizdesk/core/theme/bloc/theme_bloc.dart';
import 'package:wizdesk/features/settings/domain/models/user_preferences_model.dart';
import 'package:wizdesk/features/settings/domain/repositories/settings_repository.dart';
import 'package:wizdesk/features/settings/domain/usecases/clear_all_data_usecase.dart';
import 'package:wizdesk/features/settings/domain/usecases/get_settings_usecase.dart';
import 'package:wizdesk/features/settings/domain/usecases/reset_settings_usecase.dart';
import 'package:wizdesk/features/settings/domain/usecases/save_settings_usecase.dart';
import 'package:wizdesk/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:wizdesk/features/settings/presentation/bloc/settings_event.dart';
import 'package:wizdesk/features/settings/presentation/bloc/settings_state.dart';
import 'package:wizdesk/features/settings/presentation/screens/settings_screen.dart';
import 'package:wizdesk/features/tasks/domain/entities/focus_session_entity.dart';
import 'package:wizdesk/features/tasks/domain/entities/task_category_entity.dart';
import 'package:wizdesk/features/tasks/domain/entities/task_entity.dart';
import 'package:wizdesk/features/tasks/domain/entities/task_enums.dart';
import 'package:wizdesk/features/tasks/domain/repositories/task_repository.dart';
import 'package:wizdesk/features/tasks/domain/usecases/add_task_usecase.dart';
import 'package:wizdesk/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:wizdesk/features/tasks/domain/usecases/get_categories_usecase.dart';
import 'package:wizdesk/features/tasks/domain/usecases/get_tasks_usecase.dart';
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
  final List<TaskEntity> _tasks = [];
  final List<TaskCategoryEntity> _categories = [
    const TaskCategoryEntity(
      id: 'work',
      name: 'Work',
      colorValue: 0xFF3B82F6,
      iconCode: 0xe6f2,
    ),
  ];
  final List<FocusSessionEntity> _sessions = [];

  @override
  Future<List<TaskEntity>> getTasks() async => List.from(_tasks);

  @override
  Future<TaskEntity?> getTaskById(String taskId) async {
    try {
      return _tasks.firstWhere((t) => t.id == taskId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addTask(TaskEntity task) async {
    _tasks.add(task);
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) _tasks[index] = task;
  }

  @override
  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((t) => t.id == taskId);
  }

  @override
  Future<void> updateTaskStatus(String taskId, TaskStatus newStatus) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(status: newStatus);
    }
  }

  @override
  Future<List<TaskCategoryEntity>> getCategories() async =>
      List.from(_categories);

  @override
  Future<void> addCategory(TaskCategoryEntity category) async {
    _categories.add(category);
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    _categories.removeWhere((c) => c.id == categoryId);
  }

  @override
  Future<void> logFocusSession(FocusSessionEntity session) async {
    _sessions.add(session);
  }

  @override
  Future<List<FocusSessionEntity>> getFocusSessions() async =>
      List.from(_sessions);
}

void main() {
  late MockSettingsRepository settingsRepo;
  late MockTaskRepository taskRepo;
  late SettingsBloc settingsBloc;
  late TaskBloc taskBloc;

  setUp(() {
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
  });

  tearDown(() {
    settingsBloc.close();
    taskBloc.close();
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
            BlocProvider<LocaleBloc>(
              create: (_) => LocaleBloc(settingsRepository: settingsRepo),
            ),
            BlocProvider<SettingsBloc>.value(value: settingsBloc),
            BlocProvider<TaskBloc>.value(value: taskBloc),
          ],
          child: MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLanguage.supportedLocales,
            home: SettingsScreen(),
          ),
        );
      },
    );
  }

  testWidgets('SettingsScreen renders all sections and switches font',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // 1. Trigger initial event load
    settingsBloc.add(const LoadSettingsEvent());
    taskBloc.add(const LoadTasksEvent());

    await tester.pumpWidget(buildTestWidget());

    // 2. Wait for BLoC stream transitions
    await tester.runAsync(() async {
      await settingsBloc.stream.firstWhere((s) => s is SettingsLoaded);
      await taskBloc.stream.firstWhere((s) => s is TaskLoaded);
    });

    await tester.pump();

    // 3. Verify screen title and section headers
    expect(find.text('Profile & Settings'), findsOneWidget);
    expect(find.text('Creator'), findsOneWidget);
    expect(find.text('Timer Customization'), findsOneWidget);
    expect(find.text('Day Rollover Time'), findsOneWidget);
    expect(find.text('Daily Targets'), findsOneWidget);
    expect(find.text('Data Management'), findsOneWidget);
    expect(find.text('Wiz Desk'), findsOneWidget);
  });
}
