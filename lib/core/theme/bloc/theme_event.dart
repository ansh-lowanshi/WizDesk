import 'package:equatable/equatable.dart';
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

