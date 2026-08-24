import '../entities/focus_session_entity.dart';
import '../repositories/task_repository.dart';

/// Use case to retrieve all recorded focus sessions from storage
class GetFocusSessionsUseCase {
  final TaskRepository repository;

  const GetFocusSessionsUseCase(this.repository);

  Future<List<FocusSessionEntity>> call() async {
    return await repository.getFocusSessions();
  }
}
