import '../../../../core/usecases/usecase.dart';
import '../entities/note_entity.dart';
import '../repositories/note_repository.dart';

class AddNoteUseCase implements UseCase<void, NoteEntity> {
  final NoteRepository repository;

  AddNoteUseCase(this.repository);

  @override
  Future<void> call(NoteEntity note) async {
    return await repository.saveNote(note);
  }
}
