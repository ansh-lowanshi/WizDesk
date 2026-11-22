import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasources/note_local_datasource.dart';
import '../models/note_model.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteLocalDataSource localDataSource;

  NoteRepositoryImpl({required this.localDataSource});

  @override
  Future<List<NoteEntity>> getNotes() async {
    return await localDataSource.getNotes();
  }

  @override
  Future<NoteEntity?> getNoteById(String id) async {
    return await localDataSource.getNoteById(id);
  }

  @override
  Future<List<NoteEntity>> getNotesForTask(String taskId) async {
    return await localDataSource.getNotesForTask(taskId);
  }

  @override
  Future<void> saveNote(NoteEntity note) async {
    await localDataSource.saveNote(NoteModel.fromEntity(note));
  }

  @override
  Future<void> deleteNote(String id) async {
    await localDataSource.deleteNote(id);
  }
}
