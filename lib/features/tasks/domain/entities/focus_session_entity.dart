import 'package:equatable/equatable.dart';

/// Domain entity representing a completed or recorded Pomodoro focus session
class FocusSessionEntity extends Equatable {
  final String id;
  final String? taskId;
  final String? taskTitle;
  final int durationMinutes;
  final DateTime startTime;
  final DateTime endTime;
  final bool isCompleted;
  final String sessionType; // 'work', 'short_break', 'long_break'

  const FocusSessionEntity({
    required this.id,
    this.taskId,
    this.taskTitle,
    required this.durationMinutes,
    required this.startTime,
    required this.endTime,
    this.isCompleted = true,
    this.sessionType = 'work',
  });

  @override
  List<Object?> get props => [
        id,
        taskId,
        taskTitle,
        durationMinutes,
        startTime,
        endTime,
        isCompleted,
        sessionType,
      ];
}
