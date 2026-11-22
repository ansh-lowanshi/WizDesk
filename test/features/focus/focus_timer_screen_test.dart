import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wizdesk/core/constants/app_constants.dart';
import 'package:wizdesk/features/focus/domain/models/pomodoro_enums.dart';
import 'package:wizdesk/features/focus/domain/services/timer_ticker.dart';
import 'package:wizdesk/features/focus/presentation/bloc/focus_bloc.dart';
import 'package:wizdesk/features/focus/presentation/bloc/focus_event.dart';
import 'package:wizdesk/features/focus/presentation/screens/focus_timer_screen.dart';
import 'package:wizdesk/features/focus/presentation/screens/fullscreen_timer_screen.dart';
import 'package:wizdesk/features/tasks/domain/entities/task_category_entity.dart';
import 'package:wizdesk/features/tasks/domain/entities/task_entity.dart';
import 'package:wizdesk/features/tasks/domain/entities/task_enums.dart';
import 'package:wizdesk/features/tasks/domain/usecases/add_task_usecase.dart';
import 'package:wizdesk/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:wizdesk/features/tasks/domain/usecases/get_categories_usecase.dart';
import 'package:wizdesk/features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'package:wizdesk/features/tasks/domain/usecases/log_focus_session_usecase.dart';
import 'package:wizdesk/features/tasks/domain/usecases/update_task_usecase.dart';
import 'package:wizdesk/features/tasks/presentation/bloc/task_bloc.dart';

import '../tasks/task_bloc_test.dart';

void main() {
  late MockTaskRepository repository;
  late FocusBloc focusBloc;
  late TaskBloc taskBloc;

  setUp(() {
    repository = MockTaskRepository(
      initialCategories: const [
        TaskCategoryEntity(
          id: 'cat_work',
          name: 'Work',
          iconCode: 0xe6f2,
          colorValue: 0xFF3874FF,
        ),
      ],
    );

    focusBloc = FocusBloc(
      ticker: const TimerTicker(),
      logFocusSessionUseCase: LogFocusSessionUseCase(repository),
      updateTaskUseCase: UpdateTaskUseCase(repository),
    );

    taskBloc = TaskBloc(
      getTasksUseCase: GetTasksUseCase(repository),
      addTaskUseCase: AddTaskUseCase(repository),
      updateTaskUseCase: UpdateTaskUseCase(repository),
      deleteTaskUseCase: DeleteTaskUseCase(repository),
      getCategoriesUseCase: GetCategoriesUseCase(repository),
    );
  });

  tearDown(() {
    focusBloc.close();
    taskBloc.close();
  });

  testWidgets('FocusTimerScreen renders controls and switches mode',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize:
            const Size(AppConstants.designWidth, AppConstants.designHeight),
        child: MultiBlocProvider(
          providers: [
            BlocProvider<FocusBloc>(create: (_) => focusBloc),
            BlocProvider<TaskBloc>(create: (_) => taskBloc),
          ],
          child: const MaterialApp(
            home: FocusTimerScreen(),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Focus Timer'), findsOneWidget);
    expect(find.text('25:00'), findsOneWidget);
    expect(find.text('START'), findsOneWidget);
    expect(find.text('Focus Session'), findsOneWidget);
    expect(find.text('Short Break'), findsOneWidget);
    expect(find.text('Long Break'), findsOneWidget);
    expect(find.text('Free Focus Session'), findsOneWidget);
    expect(find.byIcon(Icons.fullscreen_rounded), findsOneWidget);
    expect(find.byIcon(Icons.replay_rounded), findsOneWidget);
    expect(find.byIcon(Icons.skip_next_rounded), findsOneWidget);
  });

  testWidgets('FullscreenTimerScreen renders digital timer and controls',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize:
            const Size(AppConstants.designWidth, AppConstants.designHeight),
        child: BlocProvider<FocusBloc>(
          create: (_) => focusBloc,
          child: const MaterialApp(
            home: FullscreenTimerScreen(enablePulseAnimation: false),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('25:00'), findsOneWidget);
    expect(find.byIcon(Icons.fullscreen_exit_rounded), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

    // Unmount widget so looping pulse controller is disposed
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
      'FocusTimerScreen with initialTask displays remaining time, celebration banner, and CONTINUE button when completed',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() => tester.view.resetPhysicalSize());

    final now = DateTime.now();
    final dateKey = TaskEntity.formatDateKey(now);
    final task = TaskEntity(
      id: 'task_ui_focus_1',
      title: 'Design high-fidelity UI components',
      categoryId: 'cat_work',
      priority: TaskPriority.high,
      dueDate: now,
      frequency: TaskFrequency.daily,
      estimatedMinutes: 50,
      spentMinutes: 35,
      dailySpentMinutes: {dateKey: 35},
      createdAt: now,
    );

    focusBloc.add(SetActiveTaskEvent(task));

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize:
            const Size(AppConstants.designWidth, AppConstants.designHeight),
        child: MultiBlocProvider(
          providers: [
            BlocProvider<FocusBloc>.value(value: focusBloc),
            BlocProvider<TaskBloc>.value(value: taskBloc),
          ],
          child: MaterialApp(
            home: FocusTimerScreen(initialTask: task),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // The remaining time is 50 - 35 = 15m (15:00)
    expect(find.text('15:00'), findsOneWidget);
    expect(find.text('Design high-fidelity UI components'), findsOneWidget);

    // Simulate completion
    focusBloc.emit(focusBloc.state.copyWith(
      status: TimerStatus.completed,
      remainingSeconds: 0,
      activeTask: task.copyWith(
        status: TaskStatus.completed,
        progressPercent: 100,
        completedDates: [dateKey],
        dailyProgress: {dateKey: 100},
      ),
    ));

    await tester.pump();
    await tester.pumpAndSettle();

    // Stays on Focus screen, shows celebration banner and CONTINUE button
    expect(find.text('Task Completed! 🎉'), findsOneWidget);
    expect(find.text('CONTINUE'), findsOneWidget);
    expect(find.text('COMPLETED'), findsOneWidget);
    expect(find.text('Done'), findsWidgets);
  });

  testWidgets(
      'FocusTimerScreen when a single cycle completes displays cycle banner and START NEXT CYCLE button',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() => tester.view.resetPhysicalSize());

    final now = DateTime.now();
    final dateKey = TaskEntity.formatDateKey(now);
    final task = TaskEntity(
      id: 'task_temp_1',
      title: 'Temp 1',
      categoryId: 'cat_work',
      priority: TaskPriority.high,
      dueDate: now,
      frequency: TaskFrequency.daily,
      estimatedMinutes: 30,
      pomodoroWorkMinutes: 15,
      spentMinutes: 0,
      dailySpentMinutes: {dateKey: 0},
      isFocusModeEnabled: true,
      createdAt: now,
    );

    focusBloc.add(SetActiveTaskEvent(task));

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize:
            const Size(AppConstants.designWidth, AppConstants.designHeight),
        child: MultiBlocProvider(
          providers: [
            BlocProvider<FocusBloc>.value(value: focusBloc),
            BlocProvider<TaskBloc>.value(value: taskBloc),
          ],
          child: MaterialApp(
            home: FocusTimerScreen(initialTask: task),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Target is 30m with 15m intervals -> 2 cycles total
    expect(find.text('Cycle 1 of 2'), findsOneWidget);

    // Simulate cycle 1 completion (15m spent out of 30m)
    focusBloc.emit(focusBloc.state.copyWith(
      status: TimerStatus.completed,
      remainingSeconds: 0,
      completedCycles: 1,
      activeTask: task.copyWith(
        status: TaskStatus.inProgress,
        progressPercent: 50,
        spentMinutes: 15,
        dailySpentMinutes: {dateKey: 15},
        dailyProgress: {dateKey: 50},
      ),
    ));

    await tester.pump();
    await tester.pumpAndSettle();

    // Does NOT show Task Completed
    expect(find.text('Task Completed! 🎉'), findsNothing);
    // Shows Cycle Completed Banner
    expect(find.text('Cycle 1 of 2 Completed! 👏'), findsOneWidget);
    // Shows next cycle ready
    expect(find.text('Cycle 2 of 2'), findsOneWidget);
    // Shows START NEXT CYCLE
    expect(find.text('START NEXT CYCLE'), findsOneWidget);
    // Shows 50% in progress, NOT Done badge
    expect(find.textContaining('50%'), findsOneWidget);
    expect(find.text('Done'), findsNothing);
  });
}
