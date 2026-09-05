import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_enums.dart';

/// Data model for Task with robust Map & Hive serialization
class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.title,
    super.description,
    required super.categoryId,
    super.priority,
    super.status,
    super.dueDate,
    super.endDate,
    super.frequency,
    super.progressMode,
    super.customDays,
    super.completedDates,
    super.dailyProgress,
    super.dailySpentMinutes,
    super.dailyDescriptions,
    super.estimatedMinutes,
    super.spentMinutes,
    super.progressPercent,
    super.isFocusModeEnabled,
    required super.createdAt,
    super.completedAt,
  });

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      categoryId: entity.categoryId,
      priority: entity.priority,
      status: entity.status,
      dueDate: entity.dueDate,
      endDate: entity.endDate,
      frequency: entity.frequency,
      progressMode: entity.progressMode,
      customDays: entity.customDays,
      completedDates: entity.completedDates,
      dailyProgress: entity.dailyProgress,
      dailySpentMinutes: entity.dailySpentMinutes,
      dailyDescriptions: entity.dailyDescriptions,
      estimatedMinutes: entity.estimatedMinutes,
      spentMinutes: entity.spentMinutes,
      progressPercent: entity.progressPercent,
      isFocusModeEnabled: entity.isFocusModeEnabled,
      createdAt: entity.createdAt,
      completedAt: entity.completedAt,
    );
  }

  factory TaskModel.fromMap(Map<dynamic, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: (map['description'] as String?) ?? '',
      categoryId: map['categoryId'] as String,
      priority: TaskPriority.fromString(map['priority'] as String? ?? 'medium'),
      status: TaskStatus.fromString(map['status'] as String? ?? 'todo'),
      dueDate: map['dueDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dueDate'] as int)
          : null,
      endDate: map['endDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['endDate'] as int)
          : null,
      frequency: TaskFrequency.fromString(map['frequency'] as String? ?? 'once'),
      progressMode: TaskProgressMode.fromString(map['progressMode'] as String? ?? 'individual'),
      customDays: map['customDays'] != null
          ? List<int>.from(map['customDays'] as List)
          : const [],
      completedDates: map['completedDates'] != null
          ? List<String>.from(map['completedDates'] as List)
          : const [],
      dailyProgress: map['dailyProgress'] != null
          ? Map<String, int>.from(
              (map['dailyProgress'] as Map).map(
                (k, v) => MapEntry(k.toString(), (v as num).toInt()),
              ),
            )
          : const {},
      dailySpentMinutes: map['dailySpentMinutes'] != null
          ? Map<String, int>.from(
              (map['dailySpentMinutes'] as Map).map(
                (k, v) => MapEntry(k.toString(), (v as num).toInt()),
              ),
            )
          : const {},
      dailyDescriptions: map['dailyDescriptions'] != null
          ? Map<String, String>.from(
              (map['dailyDescriptions'] as Map).map(
                (k, v) => MapEntry(k.toString(), v.toString()),
              ),
            )
          : const {},
      estimatedMinutes: (map['estimatedMinutes'] as int?) ?? 25,
      spentMinutes: (map['spentMinutes'] as int?) ?? 0,
      progressPercent: (map['progressPercent'] as int?) ?? 0,
      isFocusModeEnabled: (map['isFocusModeEnabled'] as bool?) ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : DateTime.now(),
      completedAt: map['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completedAt'] as int)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'priority': priority.name,
      'status': status.name,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'endDate': endDate?.millisecondsSinceEpoch,
      'frequency': frequency.name,
      'progressMode': progressMode.name,
      'customDays': customDays,
      'completedDates': completedDates,
      'dailyProgress': dailyProgress,
      'dailySpentMinutes': dailySpentMinutes,
      'dailyDescriptions': dailyDescriptions,
      'estimatedMinutes': estimatedMinutes,
      'spentMinutes': spentMinutes,
      'progressPercent': progressPercent,
      'isFocusModeEnabled': isFocusModeEnabled,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
    };
  }
}
