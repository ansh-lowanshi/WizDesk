import 'package:flutter_test/flutter_test.dart';
import 'package:wizdesk/core/localization/app_language.dart';
import 'package:wizdesk/core/localization/bloc/locale_bloc.dart';
import 'package:wizdesk/core/localization/bloc/locale_event.dart';
import 'package:wizdesk/core/localization/bloc/locale_state.dart';
import 'package:wizdesk/features/settings/domain/models/user_preferences_model.dart';
import 'package:wizdesk/features/settings/domain/repositories/settings_repository.dart';

class FakeSettingsRepository implements SettingsRepository {
  UserPreferencesModel preferences = const UserPreferencesModel();

  @override
  Future<UserPreferencesModel> getPreferences() async => preferences;

  @override
  Future<void> savePreferences(UserPreferencesModel prefs) async {
    preferences = prefs;
  }

  @override
  Future<void> resetToDefaults() async {
    preferences = const UserPreferencesModel();
  }

  @override
  Future<void> clearAllData() async {
    preferences = const UserPreferencesModel();
  }
}

void main() {
  group('LocaleBloc Tests', () {
    late FakeSettingsRepository repository;
    late LocaleBloc bloc;

  setUp(() {
    repository = FakeSettingsRepository();
    bloc = LocaleBloc(settingsRepository: repository);
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state defaults to English', () {
    expect(bloc.state.language, AppLanguage.en);
  });

  test('InitLocaleEvent loads saved language from repository', () async {
    repository.preferences =
        const UserPreferencesModel(languageCode: 'es');

    bloc.add(const InitLocaleEvent());
    await expectLater(
      bloc.stream,
      emits(const LocaleState(language: AppLanguage.es)),
    );
  });

  test('ChangeLanguageEvent changes state and persists to repository', () async {
    bloc.add(const ChangeLanguageEvent(AppLanguage.hi));

    await expectLater(
      bloc.stream,
      emits(const LocaleState(language: AppLanguage.hi)),
    );

    expect(repository.preferences.languageCode, 'hi');
  });

  test('UserPreferencesModel handles languageCode serialization', () {
    const prefs = UserPreferencesModel(languageCode: 'fr');
    final map = prefs.toMap();
    expect(map['languageCode'], 'fr');

    final reconstructed = UserPreferencesModel.fromMap(map);
    expect(reconstructed.languageCode, 'fr');
  });
  });
}
