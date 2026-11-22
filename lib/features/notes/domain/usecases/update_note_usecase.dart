import '../../../../core/usecases/usecase.dart';
import '../entities/note_entity.dart';
import '../repositories/note_repository.dart';

class UpdateNoteUseCase implements UseCase<void, NoteEntity> {
  final NoteRepository repository;

  UpdateNoteUseCase(this.repository);

  @override
  Future<void> call(NoteEntity note) async {
    return await repository.saveNote(note);
  }
}
