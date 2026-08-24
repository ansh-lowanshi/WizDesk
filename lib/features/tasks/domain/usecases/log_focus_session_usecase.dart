import '../../../../core/usecases/usecase.dart';
import '../entities/focus_session_entity.dart';
import '../repositories/task_repository.dart';

class LogFocusSessionUseCase implements UseCase<void, FocusSessionEntity> {
  final TaskRepository repository;

  LogFocusSessionUseCase(this.repository);

  @override
  Future<void> call(FocusSessionEntity session) async {
    return await repository.logFocusSession(session);
  }
}
