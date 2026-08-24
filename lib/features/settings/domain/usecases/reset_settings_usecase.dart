import '../repositories/settings_repository.dart';

class ResetSettingsUseCase {
  final SettingsRepository repository;

  const ResetSettingsUseCase(this.repository);

  Future<void> call() async {
    await repository.resetToDefaults();
  }
}
