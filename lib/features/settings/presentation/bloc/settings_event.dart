import 'package:equatable/equatable.dart';
import '../../domain/models/app_font_family.dart';
import '../../domain/models/app_theme_mode.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettingsEvent extends SettingsEvent {
  const LoadSettingsEvent();
}

class UpdateTimerSettingsEvent extends SettingsEvent {
  final int workDurationMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int longBreakInterval;
  final bool autoStartBreaks;
  final bool autoStartPomodoros;

  const UpdateTimerSettingsEvent({
    required this.workDurationMinutes,
    required this.shortBreakMinutes,
    required this.longBreakMinutes,
    required this.longBreakInterval,
    required this.autoStartBreaks,
    required this.autoStartPomodoros,
  });

  @override
  List<Object?> get props => [
        workDurationMinutes,
        shortBreakMinutes,
        longBreakMinutes,
        longBreakInterval,
        autoStartBreaks,
        autoStartPomodoros,
      ];
}

class UpdateFontFamilyEvent extends SettingsEvent {
  final AppFontFamily fontFamily;

  const UpdateFontFamilyEvent(this.fontFamily);

  @override
  List<Object?> get props => [fontFamily];
}

class UpdateThemeModeEvent extends SettingsEvent {
  final AppThemeMode themeMode;

  const UpdateThemeModeEvent(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

class UpdateDayResetHourEvent extends SettingsEvent {
  final int dayResetHour;

  const UpdateDayResetHourEvent(this.dayResetHour);

  @override
  List<Object?> get props => [dayResetHour];
}

class UpdateGoalsEvent extends SettingsEvent {
  final int dailyTaskGoal;
  final int dailyFocusMinutesGoal;

  const UpdateGoalsEvent({
    required this.dailyTaskGoal,
    required this.dailyFocusMinutesGoal,
  });

  @override
  List<Object?> get props => [dailyTaskGoal, dailyFocusMinutesGoal];
}

class UpdateUserProfileEvent extends SettingsEvent {
  final String userName;
  final String userTitle;

  const UpdateUserProfileEvent({
    required this.userName,
    required this.userTitle,
  });

  @override
  List<Object?> get props => [userName, userTitle];
}

class ResetSettingsEvent extends SettingsEvent {
  const ResetSettingsEvent();
}

class ClearAllDataConfirmedEvent extends SettingsEvent {
  const ClearAllDataConfirmedEvent();
}
