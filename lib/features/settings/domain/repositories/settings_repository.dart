import '../models/user_preferences_model.dart';

/// Contract for accessing and updating user settings & preferences
abstract class SettingsRepository {
  Future<UserPreferencesModel> getPreferences();
  Future<void> savePreferences(UserPreferencesModel preferences);
  Future<void> resetToDefaults();
  Future<void> clearAllData();
}
