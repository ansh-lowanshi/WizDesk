import '../../domain/entities/focus_session_entity.dart';

/// Data model for Pomodoro Focus Session logs
class FocusSessionModel extends FocusSessionEntity {
  const FocusSessionModel({
    required super.id,
    super.taskId,
    super.taskTitle,
    required super.durationMinutes,
    required super.startTime,
    required super.endTime,
    super.isCompleted,
    super.sessionType,
  });

  factory FocusSessionModel.fromEntity(FocusSessionEntity entity) {
    return FocusSessionModel(
      id: entity.id,
      taskId: entity.taskId,
      taskTitle: entity.taskTitle,
      durationMinutes: entity.durationMinutes,
      startTime: entity.startTime,
      endTime: entity.endTime,
      isCompleted: entity.isCompleted,
      sessionType: entity.sessionType,
    );
  }

  factory FocusSessionModel.fromMap(Map<dynamic, dynamic> map) {
    return FocusSessionModel(
      id: map['id'] as String,
      taskId: map['taskId'] as String?,
      taskTitle: map['taskTitle'] as String?,
      durationMinutes: (map['durationMinutes'] as int?) ?? 25,
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime'] as int),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['endTime'] as int),
      isCompleted: (map['isCompleted'] as bool?) ?? true,
      sessionType: (map['sessionType'] as String?) ?? 'work',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'taskTitle': taskTitle,
      'durationMinutes': durationMinutes,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'isCompleted': isCompleted,
      'sessionType': sessionType,
    };
  }
}
