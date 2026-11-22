import '../../domain/entities/note_entity.dart';

/// Data model for Note with Map & Hive serialization support
class NoteModel extends NoteEntity {
  const NoteModel({
    required super.id,
    required super.title,
    required super.content,
    required super.createdAt,
    required super.updatedAt,
    super.date,
    super.taskId,
    super.taskTitle,
    super.isDateSpecific = true,
    super.colorValue,
    super.isPinned = false,
    super.tags = const [],
  });

  factory NoteModel.fromEntity(NoteEntity entity) {
    return NoteModel(
      id: entity.id,
      title: entity.title,
      content: entity.content,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      date: entity.date,
      taskId: entity.taskId,
      taskTitle: entity.taskTitle,
      isDateSpecific: entity.isDateSpecific,
      colorValue: entity.colorValue,
      isPinned: entity.isPinned,
      tags: entity.tags,
    );
  }

  factory NoteModel.fromMap(Map<dynamic, dynamic> map) {
    return NoteModel(
      id: map['id'] as String,
      title: (map['title'] as String?) ?? '',
      content: (map['content'] as String?) ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
          : DateTime.now(),
      date: map['date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['date'] as int)
          : null,
      taskId: map['taskId'] as String?,
      taskTitle: map['taskTitle'] as String?,
      isDateSpecific: (map['isDateSpecific'] as bool?) ?? true,
      colorValue: map['colorValue'] as int?,
      isPinned: (map['isPinned'] as bool?) ?? false,
      tags: map['tags'] != null
          ? List<String>.from(map['tags'] as List)
          : const [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'date': date?.millisecondsSinceEpoch,
      'taskId': taskId,
      'taskTitle': taskTitle,
      'isDateSpecific': isDateSpecific,
      'colorValue': colorValue,
      'isPinned': isPinned,
      'tags': tags,
    };
  }
}
