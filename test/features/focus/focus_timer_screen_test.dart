import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wizdesk/core/constants/app_constants.dart';
import 'package:wizdesk/features/focus/domain/services/timer_ticker.dart';
import 'package:wizdesk/features/focus/presentation/bloc/focus_bloc.dart';
import 'package:wizdesk/features/focus/presentation/screens/focus_timer_screen.dart';
import 'package:wizdesk/features/focus/presentation/screens/fullscreen_timer_screen.dart';
import 'package:wizdesk/features/tasks/domain/entities/task_category_entity.dart';
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
    expect(find.text('Deep Focus'), findsOneWidget);
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
}
