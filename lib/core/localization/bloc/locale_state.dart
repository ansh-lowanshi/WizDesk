import 'dart:ui';
import 'package:equatable/equatable.dart';
import '../app_language.dart';

class LocaleState extends Equatable {
  final AppLanguage language;

  const LocaleState({
    this.language = AppLanguage.en,
  });

  Locale get locale => language.locale;

  LocaleState copyWith({
    AppLanguage? language,
  }) {
    return LocaleState(
      language: language ?? this.language,
    );
  }

  @override
  List<Object?> get props => [language];
}
