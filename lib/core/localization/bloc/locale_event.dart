import 'package:equatable/equatable.dart';
import '../app_language.dart';

abstract class LocaleEvent extends Equatable {
  const LocaleEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize locale from persisted user settings
class InitLocaleEvent extends LocaleEvent {
  const InitLocaleEvent();
}

/// Change app language & persist to storage
class ChangeLanguageEvent extends LocaleEvent {
  final AppLanguage language;

  const ChangeLanguageEvent(this.language);

  @override
  List<Object?> get props => [language];
}
