import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:wizdesk/features/focus/domain/models/pomodoro_enums.dart';
import 'package:wizdesk/features/focus/domain/services/timer_ticker.dart';
import 'package:wizdesk/features/focus/presentation/bloc/focus_bloc.dart';
import 'package:wizdesk/features/focus/presentation/bloc/focus_event.dart';
import 'package:wizdesk/features/focus/presentation/bloc/focus_state.dart';
import 'package:wizdesk/features/tasks/domain/entities/task_entity.dart';
import 'package:wizdesk/features/tasks/domain/entities/task_enums.dart';
import 'package:wizdesk/features/tasks/domain/usecases/log_focus_session_usecase.dart';
import 'package:wizdesk/features/tasks/domain/usecases/update_task_usecase.dart';

import '../tasks/task_bloc_test.dart';

class ControlledTicker extends TimerTicker {
  final StreamController<int> _controller = StreamController<int>.broadcast();

  ControlledTicker();

  @override
  Stream<int> tick({required int ticks}) => _controller.stream;

  void emitTick(int remaining) => _controller.add(remaining);

  void dispose() => _controller.close();
}

void main() {
  late MockTaskRepository repository;
  late ControlledTicker ticker;
  late FocusBloc focusBloc;

  setUp(() {
    repository = MockTaskRepository();
    ticker = ControlledTicker();
    focusBloc = FocusBloc(
      ticker: ticker,
      logFocusSessionUseCase: LogFocusSessionUseCase(repository),
      updateTaskUseCase: UpdateTaskUseCase(repository),
    );
  });

  tearDown(() {
    focusBloc.close();
    ticker.dispose();
  });

  group('FocusBloc Pomodoro Engine Tests', () {
    test('initial state should be 25m work in initial status', () {
      expect(focusBloc.state.status, TimerStatus.initial);
      expect(focusBloc.state.mode, PomodoroMode.work);
      expect(focusBloc.state.totalSeconds, 25 * 60);
      expect(focusBloc.state.remainingSeconds, 25 * 60);
      expect(focusBloc.state.formattedTime, '25:00');
      expect(focusBloc.state.progress, 0.0);
    });

    test('StartFocusSessionEvent updates state to running with custom duration',
        () async {
      focusBloc.add(const StartFocusSessionEvent(customDurationMinutes: 10));

      await expectLater(
        focusBloc.stream,
        emits(
          predicate<FocusState>((state) =>
              state.status == TimerStatus.running &&
              state.totalSeconds == 600 &&
              state.remainingSeconds == 600),
        ),
      );
    });

    test('PauseFocusSessionEvent and ResumeFocusSessionEvent manage status',
        () async {
      focusBloc.emit(
        const FocusState(
          status: TimerStatus.running,
          mode: PomodoroMode.work,
          totalSeconds: 1500,
          remainingSeconds: 1200,
        ),
      );

      focusBloc.add(const PauseFocusSessionEvent());
      await expectLater(
        focusBloc.stream,
        emits(predicate<FocusState>((state) => state.isPaused)),
      );

      focusBloc.add(const ResumeFocusSessionEvent());
      await expectLater(
        focusBloc.stream,
        emits(predicate<FocusState>((state) => state.isRunning)),
      );
    });

    test('ResetFocusSessionEvent resets remaining time to totalSeconds',
        () async {
      focusBloc.emit(
        const FocusState(
          status: TimerStatus.running,
          mode: PomodoroMode.work,
          totalSeconds: 1500,
          remainingSeconds: 400,
        ),
      );

      focusBloc.add(const ResetFocusSessionEvent());
      await expectLater(
        focusBloc.stream,
        emits(predicate<FocusState>(
          (state) =>
              state.isInitial && state.remainingSeconds == state.totalSeconds,
        )),
      );
    });

    test('TimerTickedEvent with remaining 0 logs session and triggers completion',
        () async {
      final task = TaskEntity(
        id: 'task_focus_1',
        title: 'Focus Sprint',
        description: 'Testing timer integration',
        categoryId: 'cat_work',
        priority: TaskPriority.high,
        status: TaskStatus.inProgress,
        dueDate: DateTime.now(),
        frequency: TaskFrequency.once,
        estimatedMinutes: 25,
        spentMinutes: 0,
        isFocusModeEnabled: true,
        createdAt: DateTime.now(),
      );

      await repository.addTask(task);

      focusBloc.emit(
        FocusState(
          status: TimerStatus.running,
          mode: PomodoroMode.work,
          totalSeconds: 1500,
          remainingSeconds: 1,
          activeTask: task,
        ),
      );

      focusBloc.add(const TimerTickedEvent(remainingSeconds: 0));

      await expectLater(
        focusBloc.stream,
        emits(predicate<FocusState>(
          (state) =>
              state.isCompleted &&
              state.remainingSeconds == 0 &&
              state.completedCycles == 1,
        )),
      );

      // Verify task spentMinutes was updated
      final updatedTask = await repository.getTaskById(task.id);
      expect(updatedTask?.spentMinutes, 25);
    });

    test('TimerTickedEvent periodically updates task spentMinutes every 2 minutes',
        () async {
      final task = TaskEntity(
        id: 'task_periodic_1',
        title: 'Real-time Focus',
        description: 'Testing periodic 2 min update',
        categoryId: 'cat_work',
        priority: TaskPriority.high,
        status: TaskStatus.inProgress,
        dueDate: DateTime.now(),
        frequency: TaskFrequency.once,
        estimatedMinutes: 25,
        spentMinutes: 0,
        isFocusModeEnabled: true,
        createdAt: DateTime.now(),
      );

      await repository.addTask(task);

      focusBloc.add(StartFocusSessionEvent(task: task));

      await expectLater(
        focusBloc.stream,
        emits(predicate<FocusState>(
          (state) => state.isRunning && state.totalSeconds == 1500,
        )),
      );

      // Simulate 2 minutes (120 seconds) passing -> remaining = 1500 - 120 = 1380
      focusBloc.add(const TimerTickedEvent(remainingSeconds: 1380));

      await expectLater(
        focusBloc.stream,
        emits(predicate<FocusState>(
          (state) =>
              state.remainingSeconds == 1380 &&
              state.activeTask?.spentMinutes == 2,
        )),
      );

      // Verify task spentMinutes in repository is updated to 2
      final taskAfter2Min = await repository.getTaskById(task.id);
      expect(taskAfter2Min?.spentMinutes, 2);

      // Simulate another 2 minutes passing (total 4 min) -> remaining = 1500 - 240 = 1260
      focusBloc.add(const TimerTickedEvent(remainingSeconds: 1260));

      await expectLater(
        focusBloc.stream,
        emits(predicate<FocusState>(
          (state) =>
              state.remainingSeconds == 1260 &&
              state.activeTask?.spentMinutes == 4,
        )),
      );

      final taskAfter4Min = await repository.getTaskById(task.id);
      expect(taskAfter4Min?.spentMinutes, 4);
    });

    test('Pause and Reset flush unsynced minutes to the task', () async {
      final task = TaskEntity(
        id: 'task_periodic_2',
        title: 'Flush Test',
        description: 'Testing pause flush',
        categoryId: 'cat_work',
        priority: TaskPriority.medium,
        status: TaskStatus.inProgress,
        dueDate: DateTime.now(),
        frequency: TaskFrequency.once,
        estimatedMinutes: 25,
        spentMinutes: 0,
        isFocusModeEnabled: true,
        createdAt: DateTime.now(),
      );

      await repository.addTask(task);
      focusBloc.add(StartFocusSessionEvent(task: task));

      await expectLater(
        focusBloc.stream,
        emits(predicate<FocusState>((state) => state.isRunning)),
      );

      // Simulate 3 minutes passing -> remaining = 1500 - 180 = 1320
      // 2 minutes get synced at 1380
      focusBloc.add(const TimerTickedEvent(remainingSeconds: 1380));
      await expectLater(
        focusBloc.stream,
        emits(predicate<FocusState>(
          (state) => state.activeTask?.spentMinutes == 2,
        )),
      );

      // 1 more minute passes -> remaining = 1320 (not 2 min yet, so no periodic sync)
      focusBloc.add(const TimerTickedEvent(remainingSeconds: 1320));
      await expectLater(
        focusBloc.stream,
        emits(predicate<FocusState>(
          (state) => state.remainingSeconds == 1320,
        )),
      );

      // Now pause -> flushes the remaining 1 minute -> total 3 minutes
      focusBloc.add(const PauseFocusSessionEvent());
      await expectLater(
        focusBloc.stream,
        emitsThrough(predicate<FocusState>(
          (state) =>
              state.isPaused && state.activeTask?.spentMinutes == 3,
        )),
      );

      final taskAfterPause = await repository.getTaskById(task.id);
      expect(taskAfterPause?.spentMinutes, 3);
    });

    test('SkipPhaseEvent alternates between work and break phases', () async {
      focusBloc.emit(
        const FocusState(
          status: TimerStatus.initial,
          mode: PomodoroMode.work,
          totalSeconds: 1500,
          remainingSeconds: 1500,
          completedCycles: 0,
        ),
      );

      focusBloc.add(const SkipPhaseEvent());

      await expectLater(
        focusBloc.stream,
        emitsThrough(
          predicate<FocusState>((state) =>
              state.mode == PomodoroMode.shortBreak &&
              state.totalSeconds == 5 * 60),
        ),
      );
    });
  });
}
