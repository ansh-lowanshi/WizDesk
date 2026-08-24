import 'package:equatable/equatable.dart';
import '../../domain/models/pomodoro_enums.dart';
import '../../../tasks/domain/entities/task_entity.dart';

abstract class FocusEvent extends Equatable {
  const FocusEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize or start a focus countdown session
class StartFocusSessionEvent extends FocusEvent {
  final TaskEntity? task;
  final int? customDurationMinutes;
  final PomodoroMode? mode;

  const StartFocusSessionEvent({
    this.task,
    this.customDurationMinutes,
    this.mode,
  });

  @override
  List<Object?> get props => [task, customDurationMinutes, mode];
}

/// Pause the currently active countdown
class PauseFocusSessionEvent extends FocusEvent {
  const PauseFocusSessionEvent();
}

/// Resume a paused countdown
class ResumeFocusSessionEvent extends FocusEvent {
  const ResumeFocusSessionEvent();
}

/// Reset current countdown to initial phase duration
class ResetFocusSessionEvent extends FocusEvent {
  const ResetFocusSessionEvent();
}

/// Switch Pomodoro Mode (Deep Focus, Short Break, Long Break)
class SwitchPomodoroModeEvent extends FocusEvent {
  final PomodoroMode mode;
  final int? customDurationMinutes;

  const SwitchPomodoroModeEvent({
    required this.mode,
    this.customDurationMinutes,
  });

  @override
  List<Object?> get props => [mode, customDurationMinutes];
}

/// Skip the current phase to the next Pomodoro cycle
class SkipPhaseEvent extends FocusEvent {
  const SkipPhaseEvent();
}

/// Periodic internal tick event
class TimerTickedEvent extends FocusEvent {
  final int remainingSeconds;

  const TimerTickedEvent({required this.remainingSeconds});

  @override
  List<Object?> get props => [remainingSeconds];
}

/// Attach or detach a task to the focus session
class SetActiveTaskEvent extends FocusEvent {
  final TaskEntity? task;

  const SetActiveTaskEvent(this.task);

  @override
  List<Object?> get props => [task];
}

/// Customize standard work/break durations
class SetCustomDurationsEvent extends FocusEvent {
  final int workMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;

  const SetCustomDurationsEvent({
    required this.workMinutes,
    required this.shortBreakMinutes,
    required this.longBreakMinutes,
  });

  @override
  List<Object?> get props => [workMinutes, shortBreakMinutes, longBreakMinutes];
}
