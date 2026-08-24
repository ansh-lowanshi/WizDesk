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

  void _onPauseFocusSession(
    PauseFocusSessionEvent event,
    Emitter<FocusState> emit,
  ) {
    if (state.isRunning) {
      _tickerSubscription?.pause();
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

  void _onResetFocusSession(
    ResetFocusSessionEvent event,
    Emitter<FocusState> emit,
  ) {
    _tickerSubscription?.cancel();
    emit(state.copyWith(
      status: TimerStatus.initial,
      remainingSeconds: state.totalSeconds,
    ));
  }

  void _onSwitchPomodoroMode(
    SwitchPomodoroModeEvent event,
    Emitter<FocusState> emit,
  ) {
    _tickerSubscription?.cancel();

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

  void _onSkipPhase(
    SkipPhaseEvent event,
    Emitter<FocusState> emit,
  ) {
    _tickerSubscription?.cancel();

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
      emit(state.copyWith(remainingSeconds: event.remainingSeconds));
    } else {
      _tickerSubscription?.cancel();

      // Session finished
      if (state.isWorkMode) {
        final int elapsedMinutes = state.totalSeconds ~/ 60;

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

        // 2. Update task spentMinutes if linked
        TaskEntity? updatedTask = state.activeTask;
        if (state.activeTask != null) {
          updatedTask = state.activeTask!.copyWith(
            spentMinutes: state.activeTask!.spentMinutes + elapsedMinutes,
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

  void _onSetActiveTask(
    SetActiveTaskEvent event,
    Emitter<FocusState> emit,
  ) {
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
