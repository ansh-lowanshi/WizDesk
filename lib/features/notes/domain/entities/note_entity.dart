import 'package:equatable/equatable.dart';

/// Domain entity representing a rich user Note in WizDesk
class NoteEntity extends Equatable {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  /// Calendar date this note is assigned to or created for
  final DateTime? date;
  /// ID of the task this note is linked/attached to, if any
  final String? taskId;
  /// Cached title of the attached task for immediate display
  final String? taskTitle;
  /// If true, the note is specific to the selected date of the task.
  /// If false, the note attaches throughout the task lifecycle across all dates.
  final bool isDateSpecific;
  /// Optional accent color value (e.g. 0xFF3874FF, 0xFF00F0FF, 0xFF7F56D9)
  final int? colorValue;
  /// Whether the note is pinned to top
  final bool isPinned;
  /// Optional tags/labels
  final List<String> tags;

  const NoteEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.date,
    this.taskId,
    this.taskTitle,
    this.isDateSpecific = true,
    this.colorValue,
    this.isPinned = false,
    this.tags = const [],
  });

  /// Check if the note was created on a given date (ignoring time)
  bool isCreatedOn(DateTime targetDate) {
    return createdAt.year == targetDate.year &&
        createdAt.month == targetDate.month &&
        createdAt.day == targetDate.day;
  }

  /// Check if the note is relevant to a specific calendar date:
  /// - Created on this date, OR
  /// - Explicitly assigned to this date (`date` matches), OR
  /// - If `isDateSpecific` is true and assigned to this date.
  bool isRelevantForDate(DateTime targetDate) {
    if (isCreatedOn(targetDate)) return true;
    if (date != null) {
      return date!.year == targetDate.year &&
          date!.month == targetDate.month &&
          date!.day == targetDate.day;
    }
    return false;
  }

  /// True if the note is attached to a task
  bool get hasAttachedTask => taskId != null && taskId!.trim().isNotEmpty;

  /// Returns effective target date for display
  DateTime get effectiveDate => date ?? createdAt;

  NoteEntity copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? date,
    String? taskId,
    String? taskTitle,
    bool? isDateSpecific,
    int? colorValue,
    bool? isPinned,
    List<String>? tags,
  }) {
    return NoteEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      date: date ?? this.date,
      taskId: taskId ?? this.taskId,
      taskTitle: taskTitle ?? this.taskTitle,
      isDateSpecific: isDateSpecific ?? this.isDateSpecific,
      colorValue: colorValue ?? this.colorValue,
      isPinned: isPinned ?? this.isPinned,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        createdAt,
        updatedAt,
        date,
        taskId,
        taskTitle,
        isDateSpecific,
        colorValue,
        isPinned,
        tags,
      ];
}
