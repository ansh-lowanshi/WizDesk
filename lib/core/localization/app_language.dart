import 'package:flutter/material.dart';

/// Supported application languages with metadata
enum AppLanguage {
  en(
    code: 'en',
    name: 'English',
    nativeName: 'English',
    flag: '🇺🇸',
    textDirection: TextDirection.ltr,
  ),
  es(
    code: 'es',
    name: 'Spanish',
    nativeName: 'Español',
    flag: '🇪🇸',
    textDirection: TextDirection.ltr,
  ),
  fr(
    code: 'fr',
    name: 'French',
    nativeName: 'Français',
    flag: '🇫🇷',
    textDirection: TextDirection.ltr,
  ),
  de(
    code: 'de',
    name: 'German',
    nativeName: 'Deutsch',
    flag: '🇩🇪',
    textDirection: TextDirection.ltr,
  ),
  hi(
    code: 'hi',
    name: 'Hindi',
    nativeName: 'हिन्दी',
    flag: '🇮🇳',
    textDirection: TextDirection.ltr,
  ),
  ja(
    code: 'ja',
    name: 'Japanese',
    nativeName: '日本語',
    flag: '🇯🇵',
    textDirection: TextDirection.ltr,
  ),
  ar(
    code: 'ar',
    name: 'Arabic',
    nativeName: 'العربية',
    flag: '🇸🇦',
    textDirection: TextDirection.rtl,
  ),
  pt(
    code: 'pt',
    name: 'Portuguese',
    nativeName: 'Português',
    flag: '🇧🇷',
    textDirection: TextDirection.ltr,
  );

  final String code;
  final String name;
  final String nativeName;
  final String flag;
  final TextDirection textDirection;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
    required this.textDirection,
  });

  Locale get locale => Locale(code);

  static AppLanguage fromCode(String? code) {
    if (code == null) return AppLanguage.en;
    return AppLanguage.values.firstWhere(
      (lang) => lang.code.toLowerCase() == code.toLowerCase(),
      orElse: () => AppLanguage.en,
    );
  }

  static List<Locale> get supportedLocales =>
      AppLanguage.values.map((lang) => lang.locale).toList();
}
