import '../../../../core/usecases/usecase.dart';
import '../entities/note_entity.dart';
import '../repositories/note_repository.dart';

class GetNotesUseCase implements UseCase<List<NoteEntity>, NoParams> {
  final NoteRepository repository;

  GetNotesUseCase(this.repository);

  @override
  Future<List<NoteEntity>> call(NoParams params) async {
    return await repository.getNotes();
  }
}
