import 'package:hive/hive.dart';
import '../../../notes/data/datasources/note_local_datasource.dart';
import '../../../tasks/data/datasources/task_local_datasource.dart';
import '../../domain/models/user_preferences_model.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final Box? preferencesBox;
  final TaskLocalDataSource? taskLocalDataSource;
  final NoteLocalDataSource? noteLocalDataSource;

  static const String _preferencesKey = 'user_app_preferences';

  SettingsRepositoryImpl({
    this.preferencesBox,
    this.taskLocalDataSource,
    this.noteLocalDataSource,
  });

  @override
  Future<UserPreferencesModel> getPreferences() async {
    try {
      if (preferencesBox != null && preferencesBox!.isOpen) {
        final rawData = preferencesBox!.get(_preferencesKey);
        if (rawData != null && rawData is Map) {
          return UserPreferencesModel.fromMap(rawData);
        }
      }
    } catch (_) {}
    return const UserPreferencesModel();
  }

  @override
  Future<void> savePreferences(UserPreferencesModel preferences) async {
    if (preferencesBox != null && preferencesBox!.isOpen) {
      await preferencesBox!.put(_preferencesKey, preferences.toMap());
    }
  }

  @override
  Future<void> resetToDefaults() async {
    const defaultPrefs = UserPreferencesModel();
    await savePreferences(defaultPrefs);
  }

  @override
  Future<void> clearAllData() async {
    if (taskLocalDataSource != null) {
      await taskLocalDataSource!.clearAllData();
      await taskLocalDataSource!.seedInitialDataIfEmpty();
    }
    if (noteLocalDataSource != null) {
      await noteLocalDataSource!.clearAllData();
      await noteLocalDataSource!.seedInitialDataIfEmpty();
    }
    await resetToDefaults();
  }
}

