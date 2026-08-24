import '../../../../core/usecases/usecase.dart';
import '../repositories/task_repository.dart';

class DeleteTaskUseCase implements UseCase<void, String> {
  final TaskRepository repository;

  DeleteTaskUseCase(this.repository);

  @override
  Future<void> call(String taskId) async {
    return await repository.deleteTask(taskId);
  }
}
