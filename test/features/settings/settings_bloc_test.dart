import 'package:flutter_test/flutter_test.dart';
import 'package:wizdesk/features/settings/domain/models/user_preferences_model.dart';
import 'package:wizdesk/features/settings/domain/repositories/settings_repository.dart';
import 'package:wizdesk/features/settings/domain/usecases/clear_all_data_usecase.dart';
import 'package:wizdesk/features/settings/domain/usecases/get_settings_usecase.dart';
import 'package:wizdesk/features/settings/domain/usecases/reset_settings_usecase.dart';
import 'package:wizdesk/features/settings/domain/usecases/save_settings_usecase.dart';
import 'package:wizdesk/features/settings/domain/models/app_theme_mode.dart';
import 'package:wizdesk/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:wizdesk/features/settings/presentation/bloc/settings_event.dart';
import 'package:wizdesk/features/settings/presentation/bloc/settings_state.dart';

class MockSettingsRepository implements SettingsRepository {
  UserPreferencesModel currentPrefs;

  MockSettingsRepository([UserPreferencesModel? initial])
      : currentPrefs = initial ?? const UserPreferencesModel();

  @override
  Future<UserPreferencesModel> getPreferences() async => currentPrefs;

  @override
  Future<void> savePreferences(UserPreferencesModel preferences) async {
    currentPrefs = preferences;
  }

  @override
  Future<void> resetToDefaults() async {
    currentPrefs = const UserPreferencesModel();
  }

  @override
  Future<void> clearAllData() async {
    currentPrefs = const UserPreferencesModel();
  }
}

void main() {
  late MockSettingsRepository repository;
  late GetSettingsUseCase getSettingsUseCase;
  late SaveSettingsUseCase saveSettingsUseCase;
  late ResetSettingsUseCase resetSettingsUseCase;
  late ClearAllDataUseCase clearAllDataUseCase;
  late SettingsBloc settingsBloc;

  setUp(() {
    repository = MockSettingsRepository();
    getSettingsUseCase = GetSettingsUseCase(repository);
    saveSettingsUseCase = SaveSettingsUseCase(repository);
    resetSettingsUseCase = ResetSettingsUseCase(repository);
    clearAllDataUseCase = ClearAllDataUseCase(repository);

    settingsBloc = SettingsBloc(
      getSettingsUseCase: getSettingsUseCase,
      saveSettingsUseCase: saveSettingsUseCase,
      resetSettingsUseCase: resetSettingsUseCase,
      clearAllDataUseCase: clearAllDataUseCase,
    );
  });

  tearDown(() {
    settingsBloc.close();
  });

  group('SettingsBloc Tests', () {
    test('initial state is SettingsInitial', () {
      expect(settingsBloc.state, isA<SettingsInitial>());
    });

    test('LoadSettingsEvent loads default preferences correctly', () async {
      settingsBloc.add(const LoadSettingsEvent());

      await expectLater(
        settingsBloc.stream,
        emitsInOrder([
          isA<SettingsLoading>(),
          isA<SettingsLoaded>().having(
            (s) => s.preferences.userName,
            'userName',
            'Creator',
          ),
        ]),
      );
    });

    test('UpdateTimerSettingsEvent updates duration and emits message', () async {
      settingsBloc.add(const LoadSettingsEvent());
      await Future.delayed(const Duration(milliseconds: 10));

      settingsBloc.add(
        const UpdateTimerSettingsEvent(
          workDurationMinutes: 45,
          shortBreakMinutes: 10,
          longBreakMinutes: 20,
          longBreakInterval: 3,
          autoStartBreaks: true,
          autoStartPomodoros: false,
        ),
      );

      await expectLater(
        settingsBloc.stream,
        emits(
          isA<SettingsLoaded>()
              .having((s) => s.preferences.workDurationMinutes, 'workDuration', 45)
              .having((s) => s.preferences.shortBreakMinutes, 'shortBreak', 10)
              .having((s) => s.preferences.autoStartBreaks, 'autoStartBreaks', true),
        ),
      );
    });

    test('UpdateUserProfileEvent updates userName and title', () async {
      settingsBloc.add(const LoadSettingsEvent());
      await Future.delayed(const Duration(milliseconds: 10));

      settingsBloc.add(
        const UpdateUserProfileEvent(
          userName: 'Alex Dev',
          userTitle: 'Lead Engineer',
        ),
      );

      await expectLater(
        settingsBloc.stream,
        emits(
          isA<SettingsLoaded>()
              .having((s) => s.preferences.userName, 'userName', 'Alex Dev')
              .having((s) => s.preferences.userTitle, 'userTitle', 'Lead Engineer'),
        ),
      );
    });

    test('UpdateThemeModeEvent switches theme correctly', () async {
      settingsBloc.add(const LoadSettingsEvent());
      await Future.delayed(const Duration(milliseconds: 10));

      settingsBloc.add(const UpdateThemeModeEvent(AppThemeMode.light));

      await expectLater(
        settingsBloc.stream,
        emits(
          isA<SettingsLoaded>().having(
            (s) => s.preferences.themeMode,
            'themeMode',
            AppThemeMode.light,
          ),
        ),
      );
    });

    test('UpdateDayResetHourEvent updates day reset cutoff hour', () async {
      settingsBloc.add(const LoadSettingsEvent());
      await Future.delayed(const Duration(milliseconds: 10));

      settingsBloc.add(const UpdateDayResetHourEvent(2));

      await expectLater(
        settingsBloc.stream,
        emits(
          isA<SettingsLoaded>().having(
            (s) => s.preferences.dayResetHour,
            'dayResetHour',
            2,
          ),
        ),
      );
    });

    test('ResetSettingsEvent resets all preferences to defaults', () async {
      repository.currentPrefs = const UserPreferencesModel(
        userName: 'Custom User',
        workDurationMinutes: 50,
      );

      settingsBloc.add(const ResetSettingsEvent());

      await expectLater(
        settingsBloc.stream,
        emitsInOrder([
          isA<SettingsLoading>(),
          isA<SettingsLoaded>().having(
            (s) => s.preferences.workDurationMinutes,
            'workDuration',
            25,
          ),
        ]),
      );
    });

    test('UserPreferencesModel serializes and deserializes themeMode and dayResetHour correctly', () {
      const prefs = UserPreferencesModel(
        userName: 'Alex',
        themeMode: AppThemeMode.light,
        dayResetHour: 2,
      );

      final map = prefs.toMap();
      expect(map['themeMode'], 'light');
      expect(map['dayResetHour'], 2);

      final reconstructed = UserPreferencesModel.fromMap(map);
      expect(reconstructed.themeMode, AppThemeMode.light);
      expect(reconstructed.dayResetHour, 2);
    });
  });
}
