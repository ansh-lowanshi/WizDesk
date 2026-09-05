import '../../../../core/usecases/usecase.dart';
import '../entities/task_category_entity.dart';
import '../repositories/task_repository.dart';

class AddCategoryUseCase implements UseCase<void, TaskCategoryEntity> {
  final TaskRepository repository;

  AddCategoryUseCase(this.repository);

  @override
  Future<void> call(TaskCategoryEntity category) async {
    return await repository.addCategory(category);
  }
}
