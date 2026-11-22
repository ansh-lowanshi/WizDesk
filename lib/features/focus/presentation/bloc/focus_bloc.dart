import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../tasks/domain/entities/focus_session_entity.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/domain/entities/task_enums.dart';
import '../../../tasks/domain/usecases/log_focus_session_usecase.dart';
import '../../../tasks/domain/usecases/update_task_usecase.dart';
import '../../domain/models/pomodoro_enums.dart';
import '../../domain/services/timer_ticker.dart';
import 'focus_event.dart';
import 'focus_state.dart';

/// BLoC managing Pomodoro Focus Timer countdowns, session transitions & Hive session logging
class FocusBloc extends Bloc<FocusEvent, FocusState> {
  final TimerTicker ticker;
  final LogFocusSessionUseCase logFocusSessionUseCase;
  final UpdateTaskUseCase updateTaskUseCase;

  StreamSubscription<int>? _tickerSubscription;
  int _lastSyncedElapsedMinutes = 0;

  /// Periodic update interval for real-time progress syncing (every 2 minutes)
  static const int syncIntervalMinutes = 2;

  FocusBloc({
    required this.ticker,
    required this.logFocusSessionUseCase,
    required this.updateTaskUseCase,
  }) : super(FocusState.initial()) {
    on<StartFocusSessionEvent>(_onStartFocusSession);
    on<PauseFocusSessionEvent>(_onPauseFocusSession);
    on<ResumeFocusSessionEvent>(_onResumeFocusSession);
    on<ResetFocusSessionEvent>(_onResetFocusSession);
    on<SwitchPomodoroModeEvent>(_onSwitchPomodoroMode);
    on<SkipPhaseEvent>(_onSkipPhase);
    on<TimerTickedEvent>(_onTimerTicked);
    on<SetActiveTaskEvent>(_onSetActiveTask);
    on<SetCustomDurationsEvent>(_onSetCustomDurations);
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  Future<void> _syncUnsyncedMinutes(Emitter<FocusState> emit) async {
    if (state.isWorkMode && state.activeTask != null) {
      final int elapsedSeconds = state.totalSeconds - state.remainingSeconds;
      final int elapsedMinutes = elapsedSeconds ~/ 60;
      final int unsyncedMinutes = elapsedMinutes - _lastSyncedElapsedMinutes;
      if (unsyncedMinutes > 0) {
        _lastSyncedElapsedMinutes = elapsedMinutes;
        final now = DateTime.now();
        final dateKey = TaskEntity.formatDateKey(now);
        final int currentTodaySpent = state.activeTask!.getSpentMinutesFor(now);
        final updatedDailySpent = Map<String, int>.from(
          state.activeTask!.dailySpentMinutes,
        );
        final int newSpent = currentTodaySpent + unsyncedMinutes;
        updatedDailySpent[dateKey] = newSpent;

        final bool shouldComplete =
            state.activeTask!.estimatedMinutes > 0 &&
            newSpent >= state.activeTask!.estimatedMinutes;
        final updatedStatus = shouldComplete
            ? TaskStatus.completed
            : (state.activeTask!.status == TaskStatus.todo
                  ? TaskStatus.inProgress
                  : state.activeTask!.status);

        final updatedCompletedDates = List<String>.from(
          state.activeTask!.completedDates,
        );
        final updatedDailyProgress = Map<String, int>.from(
          state.activeTask!.dailyProgress,
        );

        final int progressPct = state.activeTask!.estimatedMinutes > 0
            ? ((newSpent / state.activeTask!.estimatedMinutes) * 100)
                  .clamp(0, 100)
                  .round()
            : 100;

        if (shouldComplete) {
          if (!updatedCompletedDates.contains(dateKey)) {
            updatedCompletedDates.add(dateKey);
          }
          updatedDailyProgress[dateKey] = 100;
        } else {
          updatedDailyProgress[dateKey] = progressPct;
        }

        final updatedTask = state.activeTask!.copyWith(
          status: updatedStatus,
          progressPercent: shouldComplete ? 100 : progressPct,
          spentMinutes: state.activeTask!.spentMinutes + unsyncedMinutes,
          dailySpentMinutes: updatedDailySpent,
          dailyProgress: updatedDailyProgress,
          completedDates: updatedCompletedDates,
          completedAt: shouldComplete
              ? (state.activeTask!.completedAt ?? now)
              : state.activeTask!.completedAt,
        );
        await updateTaskUseCase(updatedTask);
        emit(state.copyWith(activeTask: updatedTask));
      }
    }
  }

  void _onStartFocusSession(
    StartFocusSessionEvent event,
    Emitter<FocusState> emit,
  ) {
    final mode = event.mode ?? state.mode;
    TaskEntity? effectiveTask = event.task ?? state.activeTask;
    if (mode == PomodoroMode.work &&
        effectiveTask != null &&
        effectiveTask.status == TaskStatus.todo) {
      effectiveTask = effectiveTask.copyWith(status: TaskStatus.inProgress);
      updateTaskUseCase(effectiveTask);
    }

    final int defaultWorkMins;
    if (effectiveTask != null) {
      final now = DateTime.now();
      final remaining = effectiveTask.getRemainingMinutesFor(now);
      if (effectiveTask.isFocusModeEnabled &&
          effectiveTask.pomodoroWorkMinutes > 0) {
        defaultWorkMins =
            (remaining > 0 && remaining < effectiveTask.pomodoroWorkMinutes)
            ? remaining
            : effectiveTask.pomodoroWorkMinutes;
      } else {
        defaultWorkMins = remaining > 0 ? remaining : state.workDurationMinutes;
      }
    } else {
      defaultWorkMins = state.workDurationMinutes;
    }

    final int durationMinutes =
        event.customDurationMinutes ??
        (state.status == TimerStatus.initial && state.remainingSeconds > 0
            ? state.remainingSeconds ~/ 60
            : (mode == PomodoroMode.work
                  ? defaultWorkMins
                  : mode == PomodoroMode.shortBreak
                  ? state.shortBreakDurationMinutes
                  : state.longBreakDurationMinutes));

    final int totalSec = durationMinutes * 60;

    _tickerSubscription?.cancel();
    _lastSyncedElapsedMinutes = 0;

    emit(
      state.copyWith(
        status: TimerStatus.running,
        mode: mode,
        totalSeconds: totalSec,
        remainingSeconds: totalSec,
        activeTask: effectiveTask,
      ),
    );

    _tickerSubscription = ticker
        .tick(ticks: totalSec)
        .listen(
          (remaining) => add(TimerTickedEvent(remainingSeconds: remaining)),
        );
  }

  Future<void> _onPauseFocusSession(
    PauseFocusSessionEvent event,
    Emitter<FocusState> emit,
  ) async {
    if (state.isRunning) {
      _tickerSubscription?.pause();
      await _syncUnsyncedMinutes(emit);
      emit(state.copyWith(status: TimerStatus.paused));
    }
  }

  void _onResumeFocusSession(
    ResumeFocusSessionEvent event,
    Emitter<FocusState> emit,
  ) {
    if (state.isPaused) {
      _tickerSubscription?.resume();
      emit(state.copyWith(status: TimerStatus.running));
    }
  }

  Future<void> _onResetFocusSession(
    ResetFocusSessionEvent event,
    Emitter<FocusState> emit,
  ) async {
    _tickerSubscription?.cancel();
    await _syncUnsyncedMinutes(emit);
    _lastSyncedElapsedMinutes = 0;
    emit(
      state.copyWith(
        status: TimerStatus.initial,
        remainingSeconds: state.totalSeconds,
      ),
    );
  }

  Future<void> _onSwitchPomodoroMode(
    SwitchPomodoroModeEvent event,
    Emitter<FocusState> emit,
  ) async {
    _tickerSubscription?.cancel();
    await _syncUnsyncedMinutes(emit);
    _lastSyncedElapsedMinutes = 0;

    final int defaultWorkMins;
    if (state.activeTask != null) {
      final remaining = state.activeTask!.getRemainingMinutesFor(
        DateTime.now(),
      );
      if (state.activeTask!.isFocusModeEnabled &&
          state.activeTask!.pomodoroWorkMinutes > 0) {
        defaultWorkMins =
            (remaining > 0 && remaining < state.activeTask!.pomodoroWorkMinutes)
            ? remaining
            : state.activeTask!.pomodoroWorkMinutes;
      } else {
        defaultWorkMins = remaining > 0 ? remaining : state.workDurationMinutes;
      }
    } else {
      defaultWorkMins = state.workDurationMinutes;
    }

    final int durationMinutes =
        event.customDurationMinutes ??
        (event.mode == PomodoroMode.work
            ? defaultWorkMins
            : event.mode == PomodoroMode.shortBreak
            ? state.shortBreakDurationMinutes
            : state.longBreakDurationMinutes);

    final int totalSec = durationMinutes * 60;

    emit(
      state.copyWith(
        status: TimerStatus.initial,
        mode: event.mode,
        totalSeconds: totalSec,
        remainingSeconds: totalSec,
      ),
    );
  }

  Future<void> _onSkipPhase(
    SkipPhaseEvent event,
    Emitter<FocusState> emit,
  ) async {
    _tickerSubscription?.cancel();
    await _syncUnsyncedMinutes(emit);
    _lastSyncedElapsedMinutes = 0;

    PomodoroMode nextMode;
    if (state.isWorkMode) {
      final int newCycles = state.completedCycles + 1;
      final task = state.activeTask;
      final int cycleMins = (task != null && task.pomodoroWorkMinutes > 0)
          ? task.pomodoroWorkMinutes
          : 25;
      final int targetCycles = (task != null && task.estimatedMinutes > 0)
          ? (task.estimatedMinutes / cycleMins).ceil()
          : 4;

      nextMode = (newCycles >= targetCycles || newCycles % 4 == 0)
          ? PomodoroMode.longBreak
          : PomodoroMode.shortBreak;
      emit(state.copyWith(completedCycles: newCycles));
    } else {
      nextMode = PomodoroMode.work;
    }

    add(SwitchPomodoroModeEvent(mode: nextMode));
  }

  Future<void> _onTimerTicked(
    TimerTickedEvent event,
    Emitter<FocusState> emit,
  ) async {
    if (event.remainingSeconds > 0) {
      TaskEntity? currentActiveTask = state.activeTask;

      // Real-time periodic update: Update task spentMinutes every 1 minute during active work
      if (state.isWorkMode && currentActiveTask != null) {
        final int elapsedSeconds = state.totalSeconds - event.remainingSeconds;
        final int elapsedMinutes = elapsedSeconds ~/ 60;
        final int unsyncedMinutes = elapsedMinutes - _lastSyncedElapsedMinutes;

        if (unsyncedMinutes >= 1) {
          _lastSyncedElapsedMinutes = elapsedMinutes;
          final now = DateTime.now();
          final dateKey = TaskEntity.formatDateKey(now);
          final int currentTodaySpent = currentActiveTask.getSpentMinutesFor(
            now,
          );
          final updatedDailySpent = Map<String, int>.from(
            currentActiveTask.dailySpentMinutes,
          );
          final int newSpent = currentTodaySpent + unsyncedMinutes;
          updatedDailySpent[dateKey] = newSpent;

          final bool shouldComplete =
              currentActiveTask.estimatedMinutes > 0 &&
              newSpent >= currentActiveTask.estimatedMinutes;
          final updatedStatus = shouldComplete
              ? TaskStatus.completed
              : (currentActiveTask.status == TaskStatus.todo
                    ? TaskStatus.inProgress
                    : currentActiveTask.status);

          final updatedCompletedDates = List<String>.from(
            currentActiveTask.completedDates,
          );
          final updatedDailyProgress = Map<String, int>.from(
            currentActiveTask.dailyProgress,
          );

          final int progressPct = currentActiveTask.estimatedMinutes > 0
              ? ((newSpent / currentActiveTask.estimatedMinutes) * 100)
                    .clamp(0, 100)
                    .round()
              : 100;

          if (shouldComplete) {
            if (!updatedCompletedDates.contains(dateKey)) {
              updatedCompletedDates.add(dateKey);
            }
            updatedDailyProgress[dateKey] = 100;
          } else {
            updatedDailyProgress[dateKey] = progressPct;
          }

          final updatedTask = currentActiveTask.copyWith(
            status: updatedStatus,
            progressPercent: shouldComplete ? 100 : progressPct,
            spentMinutes: currentActiveTask.spentMinutes + unsyncedMinutes,
            dailySpentMinutes: updatedDailySpent,
            dailyProgress: updatedDailyProgress,
            completedDates: updatedCompletedDates,
            completedAt: shouldComplete
                ? (currentActiveTask.completedAt ?? now)
                : currentActiveTask.completedAt,
          );
          await updateTaskUseCase(updatedTask);
          currentActiveTask = updatedTask;
        }
      }

      emit(
        state.copyWith(
          remainingSeconds: event.remainingSeconds,
          activeTask: currentActiveTask,
        ),
      );
    } else {
      _tickerSubscription?.cancel();

      // Session finished
      if (state.isWorkMode) {
        final int elapsedMinutes = state.totalSeconds ~/ 60;
        final int unsyncedMinutes = elapsedMinutes - _lastSyncedElapsedMinutes;
        _lastSyncedElapsedMinutes = 0;

        // 1. Log completed focus session in Hive
        final focusSession = FocusSessionEntity(
          id: 'focus_${const Uuid().v4()}',
          taskId: state.activeTask?.id,
          taskTitle: state.activeTask?.title,
          startTime: DateTime.now().subtract(Duration(minutes: elapsedMinutes)),
          endTime: DateTime.now(),
          durationMinutes: elapsedMinutes,
          isCompleted: true,
          sessionType: state.mode.name,
        );
        await logFocusSessionUseCase(focusSession);

        // 2. Update active task spentMinutes and completion status
        TaskEntity? updatedTask = state.activeTask;
        if (state.activeTask != null) {
          final now = DateTime.now();
          final dateKey = TaskEntity.formatDateKey(now);
          final int currentTodaySpent = state.activeTask!.getSpentMinutesFor(
            now,
          );
          final updatedDailySpent = Map<String, int>.from(
            state.activeTask!.dailySpentMinutes,
          );
          final int finalTodaySpent =
              currentTodaySpent + (unsyncedMinutes > 0 ? unsyncedMinutes : 0);
          updatedDailySpent[dateKey] = finalTodaySpent;

          final bool shouldComplete =
              state.activeTask!.estimatedMinutes > 0 &&
              finalTodaySpent >= state.activeTask!.estimatedMinutes;

          final updatedCompletedDates = List<String>.from(
            state.activeTask!.completedDates,
          );
          final updatedDailyProgress = Map<String, int>.from(
            state.activeTask!.dailyProgress,
          );

          final int progressPct = state.activeTask!.estimatedMinutes > 0
              ? ((finalTodaySpent / state.activeTask!.estimatedMinutes) * 100)
                    .clamp(0, 100)
                    .round()
              : 100;

          if (shouldComplete) {
            if (!updatedCompletedDates.contains(dateKey)) {
              updatedCompletedDates.add(dateKey);
            }
            updatedDailyProgress[dateKey] = 100;
          } else {
            updatedDailyProgress[dateKey] = progressPct;
            updatedCompletedDates.remove(dateKey);
          }

          final updatedStatus = shouldComplete
              ? TaskStatus.completed
              : (state.activeTask!.status == TaskStatus.todo
                    ? TaskStatus.inProgress
                    : (state.activeTask!.status == TaskStatus.completed &&
                              !shouldComplete
                          ? TaskStatus.inProgress
                          : state.activeTask!.status));

          updatedTask = state.activeTask!.copyWith(
            status: updatedStatus,
            progressPercent: shouldComplete ? 100 : progressPct,
            spentMinutes:
                state.activeTask!.spentMinutes +
                (unsyncedMinutes > 0 ? unsyncedMinutes : 0),
            dailySpentMinutes: updatedDailySpent,
            dailyProgress: updatedDailyProgress,
            completedDates: updatedCompletedDates,
            completedAt: shouldComplete
                ? (state.activeTask!.completedAt ?? now)
                : null,
          );
          await updateTaskUseCase(updatedTask);
        }

        final int newCycles = state.completedCycles + 1;
        emit(
          state.copyWith(
            status: TimerStatus.completed,
            remainingSeconds: 0,
            completedCycles: newCycles,
            activeTask: updatedTask,
          ),
        );
      } else {
        emit(
          state.copyWith(status: TimerStatus.completed, remainingSeconds: 0),
        );
      }
    }
  }

  Future<void> _onSetActiveTask(
    SetActiveTaskEvent event,
    Emitter<FocusState> emit,
  ) async {
    if (state.isRunning) {
      await _syncUnsyncedMinutes(emit);
    }
    _lastSyncedElapsedMinutes = 0;

    if (event.task == null) {
      emit(state.copyWith(clearActiveTask: true));
    } else if (state.activeTask?.id == event.task!.id &&
        (state.isRunning || state.isPaused)) {
      emit(state.copyWith(activeTask: event.task));
    } else {
      _tickerSubscription?.cancel();
      final now = DateTime.now();
      final remaining = event.task!.getRemainingMinutesFor(now);
      final int durationMins;
      if (event.task!.isFocusModeEnabled &&
          event.task!.pomodoroWorkMinutes > 0) {
        durationMins =
            (remaining > 0 && remaining < event.task!.pomodoroWorkMinutes)
            ? remaining
            : event.task!.pomodoroWorkMinutes;
      } else {
        durationMins = remaining > 0 ? remaining : state.workDurationMinutes;
      }
      final totalSec = durationMins * 60;

      final int taskSpent = event.task!.getSpentMinutesFor(now);
      final int cycleMins = event.task!.pomodoroWorkMinutes > 0
          ? event.task!.pomodoroWorkMinutes
          : 25;
      final int initialCycles = (taskSpent / cycleMins).floor();

      emit(
        state.copyWith(
          activeTask: event.task,
          totalSeconds: totalSec,
          remainingSeconds: totalSec,
          completedCycles: initialCycles,
          status: TimerStatus.initial,
        ),
      );
    }
  }

  void _onSetCustomDurations(
    SetCustomDurationsEvent event,
    Emitter<FocusState> emit,
  ) {
    emit(
      state.copyWith(
        workDurationMinutes: event.workMinutes,
        shortBreakDurationMinutes: event.shortBreakMinutes,
        longBreakDurationMinutes: event.longBreakMinutes,
      ),
    );
  }
}
