import 'app_font_family.dart';

/// User Preferences and Global Settings Configuration Model
class UserPreferencesModel {
  // Profile
  final String userName;
  final String userTitle;

  // Focus Timer Settings
  final int workDurationMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int longBreakInterval;
  final bool autoStartBreaks;
  final bool autoStartPomodoros;

  // Appearance
  final AppFontFamily fontFamily;

  // Daily Productivity Goals
  final int dailyTaskGoal;
  final int dailyFocusMinutesGoal;

  const UserPreferencesModel({
    this.userName = 'Creator',
    this.userTitle = 'Focus Architect',
    this.workDurationMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
    this.longBreakInterval = 4,
    this.autoStartBreaks = false,
    this.autoStartPomodoros = false,
    this.fontFamily = AppFontFamily.plusJakartaSans,
    this.dailyTaskGoal = 5,
    this.dailyFocusMinutesGoal = 120,
  });

  UserPreferencesModel copyWith({
    String? userName,
    String? userTitle,
    int? workDurationMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    int? longBreakInterval,
    bool? autoStartBreaks,
    bool? autoStartPomodoros,
    AppFontFamily? fontFamily,
    int? dailyTaskGoal,
    int? dailyFocusMinutesGoal,
  }) {
    return UserPreferencesModel(
      userName: userName ?? this.userName,
      userTitle: userTitle ?? this.userTitle,
      workDurationMinutes: workDurationMinutes ?? this.workDurationMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      longBreakInterval: longBreakInterval ?? this.longBreakInterval,
      autoStartBreaks: autoStartBreaks ?? this.autoStartBreaks,
      autoStartPomodoros: autoStartPomodoros ?? this.autoStartPomodoros,
      fontFamily: fontFamily ?? this.fontFamily,
      dailyTaskGoal: dailyTaskGoal ?? this.dailyTaskGoal,
      dailyFocusMinutesGoal:
          dailyFocusMinutesGoal ?? this.dailyFocusMinutesGoal,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'userTitle': userTitle,
      'workDurationMinutes': workDurationMinutes,
      'shortBreakMinutes': shortBreakMinutes,
      'longBreakMinutes': longBreakMinutes,
      'longBreakInterval': longBreakInterval,
      'autoStartBreaks': autoStartBreaks,
      'autoStartPomodoros': autoStartPomodoros,
      'fontFamily': fontFamily.id,
      'dailyTaskGoal': dailyTaskGoal,
      'dailyFocusMinutesGoal': dailyFocusMinutesGoal,
    };
  }

  factory UserPreferencesModel.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) return const UserPreferencesModel();
    return UserPreferencesModel(
      userName: (map['userName'] as String?) ?? 'Creator',
      userTitle: (map['userTitle'] as String?) ?? 'Focus Architect',
      workDurationMinutes: (map['workDurationMinutes'] as int?) ?? 25,
      shortBreakMinutes: (map['shortBreakMinutes'] as int?) ?? 5,
      longBreakMinutes: (map['longBreakMinutes'] as int?) ?? 15,
      longBreakInterval: (map['longBreakInterval'] as int?) ?? 4,
      autoStartBreaks: (map['autoStartBreaks'] as bool?) ?? false,
      autoStartPomodoros: (map['autoStartPomodoros'] as bool?) ?? false,
      fontFamily: AppFontFamily.fromId(map['fontFamily'] as String?),
      dailyTaskGoal: (map['dailyTaskGoal'] as int?) ?? 5,
      dailyFocusMinutesGoal: (map['dailyFocusMinutesGoal'] as int?) ?? 120,
    );
  }
}
