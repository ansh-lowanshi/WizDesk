import '../../../../core/usecases/usecase.dart';
import '../entities/note_entity.dart';
import '../repositories/note_repository.dart';

class GetNotesForTaskUseCase implements UseCase<List<NoteEntity>, String> {
  final NoteRepository repository;

  GetNotesForTaskUseCase(this.repository);

  @override
  Future<List<NoteEntity>> call(String taskId) async {
    return await repository.getNotesForTask(taskId);
  }
}
