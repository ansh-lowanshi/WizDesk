import 'package:equatable/equatable.dart';
import '../../domain/models/pomodoro_enums.dart';
import '../../../tasks/domain/entities/task_entity.dart';

/// State representation for the Pomodoro Focus Engine
class FocusState extends Equatable {
  final TimerStatus status;
  final PomodoroMode mode;
  final int totalSeconds;
  final int remainingSeconds;
  final int completedCycles;
  final TaskEntity? activeTask;
  final int workDurationMinutes;
  final int shortBreakDurationMinutes;
  final int longBreakDurationMinutes;

  const FocusState({
    required this.status,
    required this.mode,
    required this.totalSeconds,
    required this.remainingSeconds,
    this.completedCycles = 0,
    this.activeTask,
    this.workDurationMinutes = 25,
    this.shortBreakDurationMinutes = 5,
    this.longBreakDurationMinutes = 15,
  });

  /// Factory constructor for initial default state (25 minutes deep focus ready)
  factory FocusState.initial({
    TaskEntity? task,
    int workMinutes = 25,
    int shortBreakMinutes = 5,
    int longBreakMinutes = 15,
  }) {
    final int defaultSec = workMinutes * 60;
    return FocusState(
      status: TimerStatus.initial,
      mode: PomodoroMode.work,
      totalSeconds: defaultSec,
      remainingSeconds: defaultSec,
      completedCycles: 0,
      activeTask: task,
      workDurationMinutes: workMinutes,
      shortBreakDurationMinutes: shortBreakMinutes,
      longBreakDurationMinutes: longBreakMinutes,
    );
  }

  /// Current progress ratio from 0.0 (just started) to 1.0 (completed)
  double get progress {
    if (totalSeconds <= 0) return 0.0;
    final double elapsed = (totalSeconds - remainingSeconds).toDouble();
    return (elapsed / totalSeconds).clamp(0.0, 1.0);
  }

  /// Remaining time in MM:SS format
  String get formattedTime {
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  bool get isRunning => status == TimerStatus.running;
  bool get isPaused => status == TimerStatus.paused;
  bool get isInitial => status == TimerStatus.initial;
  bool get isCompleted => status == TimerStatus.completed;

  bool get isWorkMode => mode == PomodoroMode.work;
  bool get isBreakMode =>
      mode == PomodoroMode.shortBreak || mode == PomodoroMode.longBreak;

  FocusState copyWith({
    TimerStatus? status,
    PomodoroMode? mode,
    int? totalSeconds,
    int? remainingSeconds,
    int? completedCycles,
    TaskEntity? activeTask,
    bool clearActiveTask = false,
    int? workDurationMinutes,
    int? shortBreakDurationMinutes,
    int? longBreakDurationMinutes,
  }) {
    return FocusState(
      status: status ?? this.status,
      mode: mode ?? this.mode,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      completedCycles: completedCycles ?? this.completedCycles,
      activeTask: clearActiveTask ? null : (activeTask ?? this.activeTask),
      workDurationMinutes: workDurationMinutes ?? this.workDurationMinutes,
      shortBreakDurationMinutes:
          shortBreakDurationMinutes ?? this.shortBreakDurationMinutes,
      longBreakDurationMinutes:
          longBreakDurationMinutes ?? this.longBreakDurationMinutes,
    );
  }

  @override
  List<Object?> get props => [
        status,
        mode,
        totalSeconds,
        remainingSeconds,
        completedCycles,
        activeTask,
        workDurationMinutes,
        shortBreakDurationMinutes,
        longBreakDurationMinutes,
      ];
}
