import '../../../../core/usecases/usecase.dart';
import '../repositories/task_repository.dart';

class DeleteCategoryUseCase implements UseCase<void, String> {
  final TaskRepository repository;

  DeleteCategoryUseCase(this.repository);

  @override
  Future<void> call(String categoryId) async {
    return await repository.deleteCategory(categoryId);
  }
}
