import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wizdesk/core/constants/app_constants.dart';
import 'package:wizdesk/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:wizdesk/features/analytics/presentation/bloc/analytics_state.dart';
import 'package:wizdesk/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:wizdesk/features/tasks/domain/entities/focus_session_entity.dart';
import 'package:wizdesk/features/tasks/domain/entities/task_category_entity.dart';
import 'package:wizdesk/features/tasks/domain/entities/task_entity.dart';
import 'package:wizdesk/features/tasks/domain/entities/task_enums.dart';
import 'package:wizdesk/features/tasks/domain/usecases/get_categories_usecase.dart';
import 'package:wizdesk/features/tasks/domain/usecases/get_focus_sessions_usecase.dart';
import 'package:wizdesk/features/tasks/domain/usecases/get_tasks_usecase.dart';

import '../tasks/task_bloc_test.dart';

void main() {
  late MockTaskRepository repository;
  late AnalyticsBloc analyticsBloc;

  final now = DateTime.now();

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
      initialTasks: [
        TaskEntity(
          id: 'task_1',
          title: 'Complete project report',
          categoryId: 'cat_work',
          priority: TaskPriority.urgent,
          frequency: TaskFrequency.daily,
          estimatedMinutes: 50,
          spentMinutes: 50,
          status: TaskStatus.completed,
          createdAt: now,
          dueDate: now,
        ),
      ],
      initialSessions: [
        FocusSessionEntity(
          id: 'session_1',
          startTime: now.subtract(const Duration(minutes: 30)),
          endTime: now.subtract(const Duration(minutes: 5)),
          durationMinutes: 25,
          sessionType: 'work',
          taskId: 'task_1',
        ),
      ],
    );

    analyticsBloc = AnalyticsBloc(
      getTasksUseCase: GetTasksUseCase(repository),
      getFocusSessionsUseCase: GetFocusSessionsUseCase(repository),
      getCategoriesUseCase: GetCategoriesUseCase(repository),
    );
  });

  tearDown(() {
    analyticsBloc.close();
  });

  testWidgets('AnalyticsScreen renders all metric sections & switches tabs',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize:
            const Size(AppConstants.designWidth, AppConstants.designHeight),
        child: BlocProvider<AnalyticsBloc>(
          create: (_) => analyticsBloc,
          child: const MaterialApp(
            home: AnalyticsScreen(),
          ),
        ),
      ),
    );

    await tester.runAsync(() async {
      await analyticsBloc.stream.firstWhere((s) => s is AnalyticsLoaded);
    });
    await tester.pump();

    expect(find.text('Productivity Analytics'), findsOneWidget);
    expect(find.text('Total Focus'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Focus Activity'), findsOneWidget);
    expect(find.text('Category Breakdown'), findsOneWidget);
    expect(find.text('Recent Focus Logs'), findsOneWidget);

    // Switch to Weekly tab
    await tester.tap(find.byKey(const ValueKey('analytics_range_weekly')));
    await tester.runAsync(() async {
      await analyticsBloc.stream.firstWhere((s) => s is AnalyticsLoaded);
    });
    await tester.pump();

    expect(find.text('Weekly'), findsWidgets);
  });
}
