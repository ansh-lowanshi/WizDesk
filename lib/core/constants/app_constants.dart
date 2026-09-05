/// Application-wide constants for Wiz Desk
class AppConstants {
  // App info
  static const String appName = 'Wiz Desk';
  static const String appTagline = 'Focus. Plan. Achieve.';
  static const String appVersion = '1.0.0';
  static const String appLogo = 'assets/images/WizDesk_logo.png';

  // Hive Box Names
  static const String taskBoxName = 'wizdesk_tasks_box';
  static const String categoryBoxName = 'wizdesk_categories_box';
  static const String sessionBoxName = 'wizdesk_focus_sessions_box';
  static const String userPreferencesBoxName = 'wizdesk_preferences_box';

  // Storage Keys
  static const String keyUserDisplayName = 'pref_user_name';
  static const String keyUserAvatar = 'pref_user_avatar';
  static const String keyFocusDurationMinutes = 'pref_focus_duration';
  static const String keyShortBreakMinutes = 'pref_short_break';
  static const String keyLongBreakMinutes = 'pref_long_break';
  static const String keyAutoStartBreak = 'pref_auto_start_break';
  static const String keyNotificationSound = 'pref_notification_sound';

  // Default Pomodoro Settings (25 min Focus + 5 min Short Break)
  static const int defaultFocusMinutes = 25;
  static const int defaultShortBreakMinutes = 5;
  static const int defaultLongBreakMinutes = 15;
  static const int defaultSessionsBeforeLongBreak = 4;

  // Responsive Screen Design Baseline (Figma base: 375 x 812)
  static const double designWidth = 375.0;
  static const double designHeight = 812.0;
  static const double tabletBreakpoint = 600.0;
  static const double desktopBreakpoint = 1024.0;
}
