import '../../../../core/usecases/usecase.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class AddTaskUseCase implements UseCase<void, TaskEntity> {
  final TaskRepository repository;

  AddTaskUseCase(this.repository);

  @override
  Future<void> call(TaskEntity task) async {
    return await repository.addTask(task);
  }
}
