import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wizdesk/core/constants/app_constants.dart';
import 'package:wizdesk/features/calendar/presentation/screens/calendar_screen.dart';
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

class MockTaskRepository implements TaskRepository {
  final List<TaskEntity> _tasks = [];
  final List<TaskCategoryEntity> _categories = [];
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
  late MockTaskRepository taskRepo;
  late TaskBloc taskBloc;

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    taskRepo = MockTaskRepository();

    final now = DateTime.now();
    taskRepo._categories.add(
      const TaskCategoryEntity(
        id: 'cat_work',
        name: 'Work',
        colorValue: 0xFF3B82F6,
        iconCode: 0xe6f2,
      ),
    );

    taskRepo._tasks.add(
      TaskEntity(
        id: 'task_cal_1',
        title: 'Calendar Scheduled Task',
        description: 'Prepare schedule notes',
        categoryId: 'cat_work',
        dueDate: DateTime(now.year, now.month, now.day, 14, 0),
        priority: TaskPriority.high,
        status: TaskStatus.todo,
        frequency: TaskFrequency.once,
        estimatedMinutes: 30,
        spentMinutes: 0,
        isFocusModeEnabled: true,
        createdAt: now,
      ),
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
    taskBloc.close();
  });

  Widget buildTestWidget() {
    return ScreenUtilInit(
      designSize: const Size(AppConstants.designWidth, AppConstants.designHeight),
      minTextAdapt: true,
      builder: (context, child) {
        return BlocProvider<TaskBloc>.value(
          value: taskBloc,
          child: const MaterialApp(
            home: CalendarScreen(),
          ),
        );
      },
    );
  }

  testWidgets('CalendarScreen renders month calendar and scheduled tasks',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.runAsync(() async {
      final taskLoadedFuture =
          taskBloc.stream.firstWhere((s) => s is TaskLoaded);
      taskBloc.add(const LoadTasksEvent());
      await taskLoadedFuture;
    });

    await tester.pumpWidget(buildTestWidget());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Verify Calendar Header & Task
    expect(find.text('Schedule Calendar'), findsOneWidget);
    expect(find.text('Calendar Scheduled Task'), findsOneWidget);
    expect(find.byKey(const ValueKey('cal_header_add_task_btn')), findsOneWidget);

    // Verify Next / Previous month buttons exist and are tappable
    final nextMonthBtn = find.byKey(const ValueKey('cal_next_month_btn'));
    expect(nextMonthBtn, findsOneWidget);
    await tester.tap(nextMonthBtn);
    await tester.pump();

    // Verify Prev Month button
    final prevMonthBtn = find.byKey(const ValueKey('cal_prev_month_btn'));
    expect(prevMonthBtn, findsOneWidget);
    await tester.tap(prevMonthBtn);
    await tester.pump();
  });

  testWidgets('CalendarScreen reflects recurring daily and custom days tasks',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime.now();
    taskRepo._tasks.add(
      TaskEntity(
        id: 'task_daily',
        title: 'Daily Standup Routine',
        categoryId: 'cat_work',
        dueDate: now.subtract(const Duration(days: 2)),
        frequency: TaskFrequency.daily,
        priority: TaskPriority.medium,
        status: TaskStatus.todo,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    );

    await tester.runAsync(() async {
      final taskLoadedFuture =
          taskBloc.stream.firstWhere((s) => s is TaskLoaded);
      taskBloc.add(const LoadTasksEvent());
      await taskLoadedFuture;
    });

    await tester.pumpWidget(buildTestWidget());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Daily task scheduled in the past should reflect on today's calendar selection
    expect(find.text('Daily Standup Routine'), findsOneWidget);
  });

  testWidgets('TaskCard shows confirmation dialog before deleting task',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.runAsync(() async {
      final taskLoadedFuture =
          taskBloc.stream.firstWhere((s) => s is TaskLoaded);
      taskBloc.add(const LoadTasksEvent());
      await taskLoadedFuture;
    });

    await tester.pumpWidget(buildTestWidget());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Open popup menu on task card
    final moreMenuBtn = find.byIcon(Icons.more_horiz_rounded);
    expect(moreMenuBtn, findsOneWidget);
    await tester.tap(moreMenuBtn);
    await tester.pumpAndSettle();

    // Select delete
    final deleteOption = find.text('Delete');
    expect(deleteOption, findsOneWidget);
    await tester.tap(deleteOption);
    await tester.pumpAndSettle();

    // Verify confirmation dialog appeared
    expect(find.text('Delete Task?'), findsOneWidget);
    expect(find.byKey(const ValueKey('cancel_delete_btn')), findsOneWidget);
    expect(find.byKey(const ValueKey('confirm_delete_btn')), findsOneWidget);

    // Tap confirm delete
    await tester.tap(find.byKey(const ValueKey('confirm_delete_btn')));
    await tester.pumpAndSettle();

    // Verify task is removed
    expect(taskRepo._tasks.where((t) => t.id == 'task_cal_1'), isEmpty);
  });

  testWidgets('CalendarScreen shows Today button when browsing other months/days and jumps back',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.runAsync(() async {
      final taskLoadedFuture =
          taskBloc.stream.firstWhere((s) => s is TaskLoaded);
      taskBloc.add(const LoadTasksEvent());
      await taskLoadedFuture;
    });

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Initially on Today -> Month header Today button is hidden
    expect(find.byKey(const ValueKey('cal_go_to_today_btn')), findsNothing);

    // Navigate to next month
    await tester.tap(find.byKey(const ValueKey('cal_next_month_btn')));
    await tester.pumpAndSettle();

    // Now Month header Today button is visible
    expect(find.byKey(const ValueKey('cal_go_to_today_btn')), findsOneWidget);

    // Tap the Today button
    await tester.tap(find.byKey(const ValueKey('cal_go_to_today_btn')));
    await tester.pumpAndSettle();

    // Should return to today and hide the Today jump button
    expect(find.byKey(const ValueKey('cal_go_to_today_btn')), findsNothing);
  });
}
