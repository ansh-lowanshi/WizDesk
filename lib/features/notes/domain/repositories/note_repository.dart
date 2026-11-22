import '../entities/note_entity.dart';

abstract class NoteRepository {
  Future<List<NoteEntity>> getNotes();
  Future<NoteEntity?> getNoteById(String id);
  Future<List<NoteEntity>> getNotesForTask(String taskId);
  Future<void> saveNote(NoteEntity note);
  Future<void> deleteNote(String id);
}
