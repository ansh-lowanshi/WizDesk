import 'package:hive/hive.dart';
import '../../../../core/error/exceptions.dart';
import '../models/note_model.dart';

abstract class NoteLocalDataSource {
  Future<List<NoteModel>> getNotes();
  Future<NoteModel?> getNoteById(String id);
  Future<List<NoteModel>> getNotesForTask(String taskId);
  Future<void> saveNote(NoteModel note);
  Future<void> deleteNote(String id);
  Future<void> clearAllData();
  Future<void> seedInitialDataIfEmpty();
}

class NoteLocalDataSourceImpl implements NoteLocalDataSource {
  final Box notesBox;

  NoteLocalDataSourceImpl({required this.notesBox});

  @override
  Future<List<NoteModel>> getNotes() async {
    try {
      final List<NoteModel> notes = [];
      for (final key in notesBox.keys) {
        final raw = notesBox.get(key);
        if (raw is Map) {
          notes.add(NoteModel.fromMap(raw));
        }
      }
      // Sort: pinned first, then newest updatedAt/createdAt first
      notes.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.updatedAt.compareTo(a.updatedAt);
      });
      return notes;
    } catch (e) {
      throw CacheException('Failed to read notes from local storage: $e');
    }
  }

  @override
  Future<NoteModel?> getNoteById(String id) async {
    try {
      final raw = notesBox.get(id);
      if (raw is Map) {
        return NoteModel.fromMap(raw);
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to retrieve note $id: $e');
    }
  }

  @override
  Future<List<NoteModel>> getNotesForTask(String taskId) async {
    try {
      final allNotes = await getNotes();
      return allNotes.where((n) => n.taskId == taskId).toList();
    } catch (e) {
      throw CacheException('Failed to get notes for task $taskId: $e');
    }
  }

  @override
  Future<void> saveNote(NoteModel note) async {
    try {
      await notesBox.put(note.id, note.toMap());
    } catch (e) {
      throw CacheException('Failed to save note: $e');
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    try {
      await notesBox.delete(id);
    } catch (e) {
      throw CacheException('Failed to delete note: $e');
    }
  }

  @override
  Future<void> clearAllData() async {
    try {
      await notesBox.clear();
    } catch (e) {
      throw CacheException('Failed to clear notes storage: $e');
    }
  }

  @override
  Future<void> seedInitialDataIfEmpty() async {
    try {
      if (notesBox.isNotEmpty) return;

      final now = DateTime.now();
      final sampleNotes = [
        NoteModel(
          id: 'note_welcome',
          title: 'Welcome to WizDesk Notes',
          content: 'Here you can jot down your ideas, meeting takeaways, and daily reflections.\n\n• Attach notes to any task (on a single date or throughout the task)\n• View your notes right from the Calendar tab\n• Color-code your thoughts for quick visual organization\n• Access distraction-free full screen editing',
          createdAt: now,
          updatedAt: now,
          date: DateTime(now.year, now.month, now.day),
          colorValue: 0xFF3874FF,
          isPinned: true,
          tags: const ['Welcome', 'Guide'],
        ),
        NoteModel(
          id: 'note_daily_focus',
          title: 'Daily Standup & Strategy',
          content: 'Key deliverables for today:\n[x] Review architecture spec\n[ ] Finalize notes system integration\n[ ] Perform responsive validation\n\nNotes from sprint sync: High priority on intuitive task-note linking.',
          createdAt: now,
          updatedAt: now,
          date: DateTime(now.year, now.month, now.day),
          colorValue: 0xFF00F0FF,
          isPinned: false,
          tags: const ['Work', 'Standup'],
        ),
      ];

      for (final note in sampleNotes) {
        await notesBox.put(note.id, note.toMap());
      }
    } catch (_) {
      // Ignored during seed
    }
  }
}
