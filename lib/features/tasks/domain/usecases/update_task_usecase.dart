import '../../../../core/usecases/usecase.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class UpdateTaskUseCase implements UseCase<void, TaskEntity> {
  final TaskRepository repository;

  UpdateTaskUseCase(this.repository);

  @override
  Future<void> call(TaskEntity task) async {
    return await repository.updateTask(task);
  }
}
