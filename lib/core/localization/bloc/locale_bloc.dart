import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/settings/domain/repositories/settings_repository.dart';
import '../app_language.dart';
import 'locale_event.dart';
import 'locale_state.dart';

class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  final SettingsRepository settingsRepository;

  LocaleBloc({required this.settingsRepository})
      : super(const LocaleState()) {
    on<InitLocaleEvent>(_onInitLocale);
    on<ChangeLanguageEvent>(_onChangeLanguage);
  }

  Future<void> _onInitLocale(
    InitLocaleEvent event,
    Emitter<LocaleState> emit,
  ) async {
    try {
      final prefs = await settingsRepository.getPreferences();
      final language = AppLanguage.fromCode(prefs.languageCode);
      emit(state.copyWith(language: language));
    } catch (_) {
      // Fallback to default
    }
  }

  Future<void> _onChangeLanguage(
    ChangeLanguageEvent event,
    Emitter<LocaleState> emit,
  ) async {
    emit(state.copyWith(language: event.language));

    try {
      final currentPrefs = await settingsRepository.getPreferences();
      await settingsRepository.savePreferences(
        currentPrefs.copyWith(languageCode: event.language.code),
      );
    } catch (_) {}
  }
}
