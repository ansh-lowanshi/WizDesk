import 'package:equatable/equatable.dart';
import '../../domain/entities/note_entity.dart';
import '../../../tasks/domain/entities/task_entity.dart';

abstract class NoteState extends Equatable {
  const NoteState();

  @override
  List<Object?> get props => [];
}

class NoteInitial extends NoteState {
  const NoteInitial();
}

class NoteLoading extends NoteState {
  const NoteLoading();
}

class NoteLoaded extends NoteState {
  final List<NoteEntity> allNotes;

  const NoteLoaded(this.allNotes);

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Returns all notes created on, assigned to, or relevant for the specified calendar day
  List<NoteEntity> getNotesForDate(DateTime targetDate, {List<TaskEntity>? scheduledTasks}) {
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final scheduledTaskIds = scheduledTasks?.map((t) => t.id).toSet() ?? <String>{};

    return allNotes.where((note) {
      // 1. Created on this day
      if (_isSameDay(note.createdAt, target)) return true;

      // 2. Explicit target date matches
      if (note.date != null && _isSameDay(note.date!, target)) return true;

      // 3. Attached to a task scheduled for this day
      if (note.taskId != null && scheduledTaskIds.contains(note.taskId)) {
        // If date-specific, check if the date matches
        if (note.isDateSpecific) {
          final noteDate = note.date ?? note.createdAt;
          return _isSameDay(noteDate, target);
        } else {
          // Throughout task: relevant on any day the task is scheduled!
          return true;
        }
      }

      return false;
    }).toList();
  }

  /// Returns all notes attached to a given task ID
  List<NoteEntity> getNotesForTask(String taskId) {
    return allNotes.where((note) => note.taskId == taskId).toList();
  }

  /// Returns count of notes attached to a task
  int getNotesCountForTask(String taskId) {
    return allNotes.where((note) => note.taskId == taskId).length;
  }

  /// Returns total count of notes for a given date
  int getNotesCountForDate(DateTime targetDate, {List<TaskEntity>? scheduledTasks}) {
    return getNotesForDate(targetDate, scheduledTasks: scheduledTasks).length;
  }

  @override
  List<Object?> get props => [allNotes];
}

class NoteError extends NoteState {
  final String message;

  const NoteError(this.message);

  @override
  List<Object?> get props => [message];
}
