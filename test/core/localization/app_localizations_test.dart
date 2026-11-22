import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wizdesk/core/localization/app_language.dart';
import 'package:wizdesk/core/localization/app_localizations.dart';

void main() {
  group('AppLanguage Tests', () {
    test('contains all 8 supported languages', () {
      expect(AppLanguage.values.length, 8);
      expect(
        AppLanguage.values.map((e) => e.code),
        containsAll(['en', 'es', 'fr', 'de', 'hi', 'ja', 'ar', 'pt']),
      );
    });

    test('fromCode maps correctly with fallback to English', () {
      expect(AppLanguage.fromCode('es'), AppLanguage.es);
      expect(AppLanguage.fromCode('HI'), AppLanguage.hi);
      expect(AppLanguage.fromCode('invalid'), AppLanguage.en);
      expect(AppLanguage.fromCode(null), AppLanguage.en);
    });

    test('supportedLocales returns all language locales', () {
      final locales = AppLanguage.supportedLocales;
      expect(locales.length, 8);
      expect(locales.first, const Locale('en'));
    });
  });

  group('AppLocalizations Tests', () {
    test('English translations resolve correctly', () {
      final l10n = AppLocalizations(const Locale('en'));
      expect(l10n.navToday, 'Today');
      expect(l10n.navCalendar, 'Calendar');
      expect(l10n.navFocus, 'Focus');
      expect(l10n.navAnalytics, 'Analytics');
      expect(l10n.navSettings, 'Settings');
      expect(l10n.language, 'Language');
      expect(l10n.save, 'Save');
      expect(l10n.cancel, 'Cancel');
    });

    test('Spanish translations resolve correctly', () {
      final l10n = AppLocalizations(const Locale('es'));
      expect(l10n.navToday, 'Hoy');
      expect(l10n.navCalendar, 'Calendario');
      expect(l10n.navFocus, 'Enfoque');
      expect(l10n.language, 'Idioma');
      expect(l10n.save, 'Guardar');
      expect(l10n.cancel, 'Cancelar');
    });

    test('Hindi translations resolve correctly', () {
      final l10n = AppLocalizations(const Locale('hi'));
      expect(l10n.navToday, 'आज');
      expect(l10n.navCalendar, 'कैलेंडर');
      expect(l10n.navFocus, 'फोकस');
      expect(l10n.language, 'भाषा');
      expect(l10n.save, 'सहेजें');
    });

    test('Japanese translations resolve correctly', () {
      final l10n = AppLocalizations(const Locale('ja'));
      expect(l10n.navToday, '今日');
      expect(l10n.navCalendar, 'カレンダー');
      expect(l10n.navFocus, '集中');
      expect(l10n.language, '言語');
      expect(l10n.save, '保存');
    });

    test('Arabic translations resolve correctly', () {
      final l10n = AppLocalizations(const Locale('ar'));
      expect(l10n.navToday, 'اليوم');
      expect(l10n.navCalendar, 'التقويم');
      expect(l10n.navFocus, 'التركيز');
      expect(l10n.language, 'اللغة');
      expect(l10n.save, 'حفظ');
    });

    test('Fallback to English when locale code is unknown', () {
      final l10n = AppLocalizations(const Locale('xx'));
      expect(l10n.navToday, 'Today');
      expect(l10n.save, 'Save');
    });
  });
}
