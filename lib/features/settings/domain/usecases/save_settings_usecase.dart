import '../models/user_preferences_model.dart';
import '../repositories/settings_repository.dart';

class SaveSettingsUseCase {
  final SettingsRepository repository;

  const SaveSettingsUseCase(this.repository);

  Future<void> call(UserPreferencesModel preferences) async {
    await repository.savePreferences(preferences);
  }
}
