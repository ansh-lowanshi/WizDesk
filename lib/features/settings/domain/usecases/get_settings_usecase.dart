import '../models/user_preferences_model.dart';
import '../repositories/settings_repository.dart';

class GetSettingsUseCase {
  final SettingsRepository repository;

  const GetSettingsUseCase(this.repository);

  Future<UserPreferencesModel> call() async {
    return await repository.getPreferences();
  }
}
