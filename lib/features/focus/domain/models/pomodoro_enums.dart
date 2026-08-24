import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Modes of the Pomodoro focus technique (25 min work + 5 min break)
enum PomodoroMode {
  work,
  shortBreak,
  longBreak;

  String get label {
    switch (this) {
      case PomodoroMode.work:
        return 'Deep Focus';
      case PomodoroMode.shortBreak:
        return 'Short Break';
      case PomodoroMode.longBreak:
        return 'Long Break';
    }
  }

  int get defaultMinutes {
    switch (this) {
      case PomodoroMode.work:
        return 25;
      case PomodoroMode.shortBreak:
        return 5;
      case PomodoroMode.longBreak:
        return 15;
    }
  }

  Color get color {
    switch (this) {
      case PomodoroMode.work:
        return AppColors.accentCyan;
      case PomodoroMode.shortBreak:
        return AppColors.success;
      case PomodoroMode.longBreak:
        return AppColors.primary;
    }
  }
}

/// Operational status of the timer
enum TimerStatus {
  initial,
  running,
  paused,
  completed,
}
