import 'package:flutter_test/flutter_test.dart';
import 'package:wizdesk/features/notes/domain/entities/note_entity.dart';
import 'package:wizdesk/features/notes/data/models/note_model.dart';

void main() {
  final now = DateTime(2026, 10, 13, 10, 30);
  final note = NoteEntity(
    id: 'note_1',
    title: 'Sprint Planning',
    content: 'Review backlog and prioritize user stories.',
    createdAt: now,
    updatedAt: now,
    date: DateTime(2026, 10, 13),
    taskId: 'task_1',
    taskTitle: 'Plan Sprint',
    isDateSpecific: true,
    colorValue: 0xFF3874FF,
    isPinned: true,
    tags: const ['Sprint', 'Work'],
  );

  group('NoteEntity', () {
    test('isCreatedOn returns true for matching date', () {
      expect(note.isCreatedOn(DateTime(2026, 10, 13)), isTrue);
      expect(note.isCreatedOn(DateTime(2026, 10, 14)), isFalse);
    });

    test('isRelevantForDate returns true when date or createdAt matches', () {
      expect(note.isRelevantForDate(DateTime(2026, 10, 13)), isTrue);
      expect(note.isRelevantForDate(DateTime(2026, 10, 15)), isFalse);
    });

    test('hasAttachedTask reflects presence of taskId', () {
      expect(note.hasAttachedTask, isTrue);

      final standaloneNote = NoteEntity(
        id: 'note_2',
        title: 'Random thought',
        content: 'Idea for feature',
        createdAt: DateTime(2026, 10, 13),
        updatedAt: DateTime(2026, 10, 13),
      );
      expect(standaloneNote.hasAttachedTask, isFalse);
    });

    test('copyWith updates properties properly', () {
      final updated = note.copyWith(
        title: 'Updated Title',
        isPinned: false,
        isDateSpecific: false,
      );

      expect(updated.title, 'Updated Title');
      expect(updated.isPinned, isFalse);
      expect(updated.isDateSpecific, isFalse);
      expect(updated.id, note.id);
    });
  });

  group('NoteModel', () {
    test('toMap and fromMap work symmetrically', () {
      final model = NoteModel.fromEntity(note);
      final map = model.toMap();
      final fromMap = NoteModel.fromMap(map);

      expect(fromMap.id, note.id);
      expect(fromMap.title, note.title);
      expect(fromMap.content, note.content);
      expect(fromMap.taskId, note.taskId);
      expect(fromMap.taskTitle, note.taskTitle);
      expect(fromMap.isDateSpecific, note.isDateSpecific);
      expect(fromMap.colorValue, note.colorValue);
      expect(fromMap.isPinned, note.isPinned);
      expect(fromMap.tags, note.tags);
    });
  });
}
