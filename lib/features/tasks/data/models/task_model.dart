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
    super.frequency,
    super.customDays,
    super.estimatedMinutes,
    super.spentMinutes,
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
      frequency: entity.frequency,
      customDays: entity.customDays,
      estimatedMinutes: entity.estimatedMinutes,
      spentMinutes: entity.spentMinutes,
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
      frequency: TaskFrequency.fromString(map['frequency'] as String? ?? 'once'),
      customDays: map['customDays'] != null
          ? List<int>.from(map['customDays'] as List)
          : const [],
      estimatedMinutes: (map['estimatedMinutes'] as int?) ?? 25,
      spentMinutes: (map['spentMinutes'] as int?) ?? 0,
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
      'frequency': frequency.name,
      'customDays': customDays,
      'estimatedMinutes': estimatedMinutes,
      'spentMinutes': spentMinutes,
      'isFocusModeEnabled': isFocusModeEnabled,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
    };
  }
}
