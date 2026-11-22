import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/settings/domain/repositories/settings_repository.dart';
import '../app_colors.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SettingsRepository settingsRepository;

  ThemeBloc({required this.settingsRepository})
      : super(const ThemeState()) {
    on<InitThemeEvent>(_onInitTheme);
    on<SetThemeModeEvent>(_onSetThemeMode);
  }

  Future<void> _onInitTheme(
    InitThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      final prefs = await settingsRepository.getPreferences();
      final isDark = prefs.themeMode.id != 'light';
      AppColors.isDarkMode = isDark;
      emit(state.copyWith(
        isDarkMode: isDark,
      ));
    } catch (_) {}
  }

  Future<void> _onSetThemeMode(
    SetThemeModeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    final isDark = event.themeMode.id != 'light';
    AppColors.isDarkMode = isDark;

    emit(state.copyWith(
      themeMode: event.themeMode,
      isDarkMode: isDark,
    ));

    try {
      final currentPrefs = await settingsRepository.getPreferences();
      await settingsRepository.savePreferences(
        currentPrefs.copyWith(themeMode: event.themeMode),
      );
    } catch (_) {}
  }

}
