import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../tasks/domain/entities/focus_session_entity.dart';
import '../../../tasks/domain/entities/task_entity.dart';
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
        final dateKey = TaskEntity.formatDateKey(DateTime.now());
        final updatedDailySpent =
            Map<String, int>.from(state.activeTask!.dailySpentMinutes);
        updatedDailySpent[dateKey] =
            (updatedDailySpent[dateKey] ?? 0) + unsyncedMinutes;

        final updatedTask = state.activeTask!.copyWith(
          spentMinutes: state.activeTask!.spentMinutes + unsyncedMinutes,
          dailySpentMinutes: updatedDailySpent,
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
    final int durationMinutes = event.customDurationMinutes ??
        (mode == PomodoroMode.work
            ? (event.task?.estimatedMinutes ?? state.workDurationMinutes)
            : mode == PomodoroMode.shortBreak
                ? state.shortBreakDurationMinutes
                : state.longBreakDurationMinutes);

    final int totalSec = durationMinutes * 60;

    _tickerSubscription?.cancel();
    _lastSyncedElapsedMinutes = 0;

    emit(state.copyWith(
      status: TimerStatus.running,
      mode: mode,
      totalSeconds: totalSec,
      remainingSeconds: totalSec,
      activeTask: event.task ?? state.activeTask,
    ));

    _tickerSubscription = ticker
        .tick(ticks: totalSec)
        .listen((remaining) => add(TimerTickedEvent(remainingSeconds: remaining)));
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
    emit(state.copyWith(
      status: TimerStatus.initial,
      remainingSeconds: state.totalSeconds,
    ));
  }

  Future<void> _onSwitchPomodoroMode(
    SwitchPomodoroModeEvent event,
    Emitter<FocusState> emit,
  ) async {
    _tickerSubscription?.cancel();
    await _syncUnsyncedMinutes(emit);
    _lastSyncedElapsedMinutes = 0;

    final int durationMinutes = event.customDurationMinutes ??
        (event.mode == PomodoroMode.work
            ? (state.activeTask?.estimatedMinutes ?? state.workDurationMinutes)
            : event.mode == PomodoroMode.shortBreak
                ? state.shortBreakDurationMinutes
                : state.longBreakDurationMinutes);

    final int totalSec = durationMinutes * 60;

    emit(state.copyWith(
      status: TimerStatus.initial,
      mode: event.mode,
      totalSeconds: totalSec,
      remainingSeconds: totalSec,
    ));
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
      nextMode =
          (newCycles % 4 == 0) ? PomodoroMode.longBreak : PomodoroMode.shortBreak;
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

      // Real-time periodic update: Update task spentMinutes every 2 minutes during active work
      if (state.isWorkMode && currentActiveTask != null) {
        final int elapsedSeconds = state.totalSeconds - event.remainingSeconds;
        final int elapsedMinutes = elapsedSeconds ~/ 60;
        final int unsyncedMinutes = elapsedMinutes - _lastSyncedElapsedMinutes;

        if (unsyncedMinutes >= syncIntervalMinutes) {
          _lastSyncedElapsedMinutes = elapsedMinutes;
          final dateKey = TaskEntity.formatDateKey(DateTime.now());
          final updatedDailySpent =
              Map<String, int>.from(currentActiveTask.dailySpentMinutes);
          updatedDailySpent[dateKey] =
              (updatedDailySpent[dateKey] ?? 0) + unsyncedMinutes;

          final updatedTask = currentActiveTask.copyWith(
            spentMinutes: currentActiveTask.spentMinutes + unsyncedMinutes,
            dailySpentMinutes: updatedDailySpent,
          );
          await updateTaskUseCase(updatedTask);
          currentActiveTask = updatedTask;
        }
      }

      emit(state.copyWith(
        remainingSeconds: event.remainingSeconds,
        activeTask: currentActiveTask,
      ));
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

        // 2. Update task spentMinutes with any remaining unsynced minutes
        TaskEntity? updatedTask = state.activeTask;
        if (state.activeTask != null && unsyncedMinutes > 0) {
          final dateKey = TaskEntity.formatDateKey(DateTime.now());
          final updatedDailySpent =
              Map<String, int>.from(state.activeTask!.dailySpentMinutes);
          updatedDailySpent[dateKey] =
              (updatedDailySpent[dateKey] ?? 0) + unsyncedMinutes;

          updatedTask = state.activeTask!.copyWith(
            spentMinutes: state.activeTask!.spentMinutes + unsyncedMinutes,
            dailySpentMinutes: updatedDailySpent,
          );
          await updateTaskUseCase(updatedTask);
        }

        final int newCycles = state.completedCycles + 1;
        emit(state.copyWith(
          status: TimerStatus.completed,
          remainingSeconds: 0,
          completedCycles: newCycles,
          activeTask: updatedTask,
        ));
      } else {
        emit(state.copyWith(
          status: TimerStatus.completed,
          remainingSeconds: 0,
        ));
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
    } else {
      emit(state.copyWith(
        activeTask: event.task,
        totalSeconds: event.task!.estimatedMinutes * 60,
        remainingSeconds: event.task!.estimatedMinutes * 60,
        status: TimerStatus.initial,
      ));
    }
  }

  void _onSetCustomDurations(
    SetCustomDurationsEvent event,
    Emitter<FocusState> emit,
  ) {
    emit(state.copyWith(
      workDurationMinutes: event.workMinutes,
      shortBreakDurationMinutes: event.shortBreakMinutes,
      longBreakDurationMinutes: event.longBreakMinutes,
    ));
  }
}
