import '../../../../core/usecases/usecase.dart';
import '../entities/task_category_entity.dart';
import '../repositories/task_repository.dart';

class GetCategoriesUseCase implements UseCase<List<TaskCategoryEntity>, NoParams> {
  final TaskRepository repository;

  GetCategoriesUseCase(this.repository);

  @override
  Future<List<TaskCategoryEntity>> call(NoParams params) async {
    return await repository.getCategories();
  }
}
