import '../repositories/settings_repository.dart';

class ClearAllDataUseCase {
  final SettingsRepository repository;

  const ClearAllDataUseCase(this.repository);

  Future<void> call() async {
    await repository.clearAllData();
  }
}
