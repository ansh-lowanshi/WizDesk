import 'package:flutter_test/flutter_test.dart';
import 'package:wizdesk/core/theme/bloc/theme_bloc.dart';
import 'package:wizdesk/core/theme/bloc/theme_event.dart';
import 'package:wizdesk/core/theme/bloc/theme_state.dart';
import 'package:wizdesk/features/settings/domain/models/app_theme_mode.dart';
import 'package:wizdesk/features/settings/domain/models/user_preferences_model.dart';
import 'package:wizdesk/features/settings/domain/repositories/settings_repository.dart';

class MockSettingsRepository implements SettingsRepository {
  UserPreferencesModel prefs = const UserPreferencesModel();

  @override
  Future<UserPreferencesModel> getPreferences() async => prefs;
  @override
  Future<void> savePreferences(UserPreferencesModel p) async => prefs = p;
  @override
  Future<void> resetToDefaults() async => prefs = const UserPreferencesModel();
  @override
  Future<void> clearAllData() async => prefs = const UserPreferencesModel();
}

void main() {
  late MockSettingsRepository settingsRepo;
  late ThemeBloc themeBloc;

  setUp(() {
    settingsRepo = MockSettingsRepository();
    themeBloc = ThemeBloc(settingsRepository: settingsRepo);
  });

  tearDown(() {
    themeBloc.close();
  });

  test('initial state has default theme configuration', () {
    expect(themeBloc.state.themeMode, AppThemeMode.dark);
    expect(themeBloc.state.isDarkMode, true);
  });

  test('SetThemeModeEvent switches to light theme and updates isDarkMode', () async {
    themeBloc.add(const SetThemeModeEvent(AppThemeMode.light));
    await expectLater(
      themeBloc.stream,
      emits(predicate<ThemeState>((state) {
        return state.themeMode == AppThemeMode.light && state.isDarkMode == false;
      })),
    );
  });
}
