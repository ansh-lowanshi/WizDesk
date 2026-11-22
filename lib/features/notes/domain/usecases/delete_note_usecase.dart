import '../../../../core/usecases/usecase.dart';
import '../repositories/note_repository.dart';

class DeleteNoteUseCase implements UseCase<void, String> {
  final NoteRepository repository;

  DeleteNoteUseCase(this.repository);

  @override
  Future<void> call(String id) async {
    return await repository.deleteNote(id);
  }
}
