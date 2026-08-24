import 'package:intl/intl.dart';

/// Formatter utilities for tasks, calendar days, and timers
class DateTimeFormatter {
  static final DateFormat _dayMonthFormat = DateFormat('MMM d');
  static final DateFormat _fullDateFormat = DateFormat('EEEE, MMMM d');
  static final DateFormat _shortWeekdayFormat = DateFormat('E');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');

  /// Format date for task list (e.g. "Today", "Tomorrow", "Yesterday", or "Oct 24")
  static String formatTaskDueDate(DateTime? date) {
    if (date == null) return 'No date';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);

    final difference = taskDate.difference(today).inDays;
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference == -1) return 'Yesterday';

    return _dayMonthFormat.format(date);
  }

  /// Format full header date (e.g. "Tuesday, June 14")
  static String formatHeaderDate(DateTime date) {
    return _fullDateFormat.format(date);
  }

  /// Format time (e.g. "04:30 PM")
  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }

  /// Format short weekday (e.g. "Mon", "Tue")
  static String formatWeekday(DateTime date) {
    return _shortWeekdayFormat.format(date);
  }

  /// Format seconds into MM:SS display
  static String formatSecondsToMinutesSeconds(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Format duration into readable hours & minutes (e.g., "4h 10m" or "25m")
  static String formatDurationMinutes(int totalMinutes) {
    if (totalMinutes < 60) {
      return '${totalMinutes}m';
    }
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (minutes == 0) {
      return '${hours}h';
    }
    return '${hours}h ${minutes}m';
  }
}
