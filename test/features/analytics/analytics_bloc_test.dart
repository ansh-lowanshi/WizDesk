import 'package:flutter_test/flutter_test.dart';
import 'package:wizdesk/features/analytics/domain/models/analytics_time_range.dart';
import 'package:wizdesk/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:wizdesk/features/analytics/presentation/bloc/analytics_event.dart';
import 'package:wizdesk/features/analytics/presentation/bloc/analytics_state.dart';
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
        TaskEntity(
          id: 'task_2',
          title: 'Review pull requests',
          categoryId: 'cat_work',
          priority: TaskPriority.medium,
          frequency: TaskFrequency.once,
          estimatedMinutes: 25,
          spentMinutes: 0,
          status: TaskStatus.todo,
          createdAt: now,
          dueDate: now,
        ),
      ],
      initialSessions: [
        FocusSessionEntity(
          id: 'session_1',
          startTime: now.subtract(const Duration(minutes: 60)),
          endTime: now.subtract(const Duration(minutes: 35)),
          durationMinutes: 25,
          sessionType: 'work',
          taskId: 'task_1',
        ),
        FocusSessionEntity(
          id: 'session_2',
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

  group('AnalyticsBloc Tests', () {
    test('initial state is AnalyticsInitial', () {
      expect(analyticsBloc.state, isA<AnalyticsInitial>());
    });

    test('LoadAnalyticsEvent calculates Daily summary metrics correctly',
        () async {
      analyticsBloc.add(const LoadAnalyticsEvent(timeRange: AnalyticsTimeRange.daily));

      await expectLater(
        analyticsBloc.stream,
        emitsInOrder([
          isA<AnalyticsLoading>(),
          isA<AnalyticsLoaded>().having(
            (s) => s.summary.totalFocusMinutes,
            'totalFocusMinutes',
            50,
          ).having(
            (s) => s.summary.totalTasksCompleted,
            'totalTasksCompleted',
            1,
          ).having(
            (s) => s.summary.totalFocusSessions,
            'totalFocusSessions',
            2,
          ).having(
            (s) => s.summary.chartPoints.length,
            '7 daily chart points',
            7,
          ),
        ]),
      );
    });

    test('ChangeAnalyticsTimeRangeEvent switches to weekly and monthly',
        () async {
      analyticsBloc.add(const ChangeAnalyticsTimeRangeEvent(AnalyticsTimeRange.weekly));

      await expectLater(
        analyticsBloc.stream,
        emitsInOrder([
          isA<AnalyticsLoading>(),
          isA<AnalyticsLoaded>().having(
            (s) => s.summary.timeRange,
            'timeRange is weekly',
            AnalyticsTimeRange.weekly,
          ).having(
            (s) => s.summary.chartPoints.length,
            '4 weekly chart points',
            4,
          ),
        ]),
      );
    });
  });
}
