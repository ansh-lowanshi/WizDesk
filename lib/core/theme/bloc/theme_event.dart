import 'package:equatable/equatable.dart';
import '../../../features/settings/domain/models/app_font_family.dart';
import '../../../features/settings/domain/models/app_theme_mode.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class InitThemeEvent extends ThemeEvent {
  const InitThemeEvent();
}

class SetThemeModeEvent extends ThemeEvent {
  final AppThemeMode themeMode;

  const SetThemeModeEvent(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

class SetFontFamilyEvent extends ThemeEvent {
  final AppFontFamily fontFamily;

  const SetFontFamilyEvent(this.fontFamily);

  @override
  List<Object?> get props => [fontFamily];
}
