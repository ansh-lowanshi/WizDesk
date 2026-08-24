import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../../features/tasks/data/datasources/task_local_datasource.dart';
import '../../features/tasks/data/repositories/task_repository_impl.dart';
import '../../features/tasks/domain/repositories/task_repository.dart';
import '../../features/tasks/domain/usecases/add_task_usecase.dart';
import '../../features/tasks/domain/usecases/delete_task_usecase.dart';
import '../../features/tasks/domain/usecases/get_categories_usecase.dart';
import '../../features/tasks/domain/usecases/get_tasks_usecase.dart';
import '../../features/tasks/domain/usecases/log_focus_session_usecase.dart';
import '../../features/tasks/domain/usecases/update_task_usecase.dart';
import '../../features/tasks/presentation/bloc/task_bloc.dart';

final sl = GetIt.instance;

/// Initialize all core dependencies and service locator
Future<void> initServiceLocator({bool isTesting = false}) async {
  if (!isTesting) {
    // 1. External & Local Storage Initialization
    await Hive.initFlutter();

    // Open Hive Boxes
    final taskBox = await Hive.openBox(AppConstants.taskBoxName);
    final categoryBox = await Hive.openBox(AppConstants.categoryBoxName);
    final sessionBox = await Hive.openBox(AppConstants.sessionBoxName);
    final preferencesBox = await Hive.openBox(AppConstants.userPreferencesBoxName);

    if (!sl.isRegistered<Box>(instanceName: AppConstants.taskBoxName)) {
      sl.registerLazySingleton<Box>(() => taskBox, instanceName: AppConstants.taskBoxName);
    }
    if (!sl.isRegistered<Box>(instanceName: AppConstants.categoryBoxName)) {
      sl.registerLazySingleton<Box>(() => categoryBox, instanceName: AppConstants.categoryBoxName);
    }
    if (!sl.isRegistered<Box>(instanceName: AppConstants.sessionBoxName)) {
      sl.registerLazySingleton<Box>(() => sessionBox, instanceName: AppConstants.sessionBoxName);
    }
    if (!sl.isRegistered<Box>(instanceName: AppConstants.userPreferencesBoxName)) {
      sl.registerLazySingleton<Box>(() => preferencesBox, instanceName: AppConstants.userPreferencesBoxName);
    }
  }

  if (!sl.isRegistered<SharedPreferences>()) {
    final sharedPreferences = await SharedPreferences.getInstance();
    sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  }

  // 2. Data Sources
  if (!sl.isRegistered<TaskLocalDataSource>()) {
    final taskLocalDataSource = TaskLocalDataSourceImpl(
      tasksBox: sl<Box>(instanceName: AppConstants.taskBoxName),
      categoriesBox: sl<Box>(instanceName: AppConstants.categoryBoxName),
      sessionsBox: sl<Box>(instanceName: AppConstants.sessionBoxName),
    );
    // Seed sample data if empty
    await taskLocalDataSource.seedInitialDataIfEmpty();
    sl.registerLazySingleton<TaskLocalDataSource>(() => taskLocalDataSource);
  }

  // 3. Repositories
  if (!sl.isRegistered<TaskRepository>()) {
    sl.registerLazySingleton<TaskRepository>(
      () => TaskRepositoryImpl(localDataSource: sl<TaskLocalDataSource>()),
    );
  }

  // 4. Use Cases
  if (!sl.isRegistered<GetTasksUseCase>()) {
    sl.registerLazySingleton(() => GetTasksUseCase(sl<TaskRepository>()));
  }
  if (!sl.isRegistered<AddTaskUseCase>()) {
    sl.registerLazySingleton(() => AddTaskUseCase(sl<TaskRepository>()));
  }
  if (!sl.isRegistered<UpdateTaskUseCase>()) {
    sl.registerLazySingleton(() => UpdateTaskUseCase(sl<TaskRepository>()));
  }
  if (!sl.isRegistered<DeleteTaskUseCase>()) {
    sl.registerLazySingleton(() => DeleteTaskUseCase(sl<TaskRepository>()));
  }
  if (!sl.isRegistered<GetCategoriesUseCase>()) {
    sl.registerLazySingleton(() => GetCategoriesUseCase(sl<TaskRepository>()));
  }
  if (!sl.isRegistered<LogFocusSessionUseCase>()) {
    sl.registerLazySingleton(() => LogFocusSessionUseCase(sl<TaskRepository>()));
  }

  // 5. Presentation Layer (BLoCs)
  if (!sl.isRegistered<TaskBloc>()) {
    sl.registerFactory(
      () => TaskBloc(
        getTasksUseCase: sl<GetTasksUseCase>(),
        addTaskUseCase: sl<AddTaskUseCase>(),
        updateTaskUseCase: sl<UpdateTaskUseCase>(),
        deleteTaskUseCase: sl<DeleteTaskUseCase>(),
        getCategoriesUseCase: sl<GetCategoriesUseCase>(),
      ),
    );
  }
}

