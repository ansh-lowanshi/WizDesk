import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/settings/domain/repositories/settings_repository.dart';
import '../app_colors.dart';
import '../app_typography.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SettingsRepository settingsRepository;

  ThemeBloc({required this.settingsRepository})
      : super(const ThemeState()) {
    on<InitThemeEvent>(_onInitTheme);
    on<SetThemeModeEvent>(_onSetThemeMode);
    on<SetFontFamilyEvent>(_onSetFontFamily);
  }

  Future<void> _onInitTheme(
    InitThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      final prefs = await settingsRepository.getPreferences();
      final isDark = prefs.themeMode.id != 'light';
      AppColors.isDarkMode = isDark;
      AppTypography.currentFontFamily = prefs.fontFamily;

      emit(state.copyWith(
        themeMode: prefs.themeMode,
        fontFamily: prefs.fontFamily,
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

  Future<void> _onSetFontFamily(
    SetFontFamilyEvent event,
    Emitter<ThemeState> emit,
  ) async {
    AppTypography.currentFontFamily = event.fontFamily;

    emit(state.copyWith(
      fontFamily: event.fontFamily,
    ));

    try {
      final currentPrefs = await settingsRepository.getPreferences();
      await settingsRepository.savePreferences(
        currentPrefs.copyWith(fontFamily: event.fontFamily),
      );
    } catch (_) {}
  }
}
