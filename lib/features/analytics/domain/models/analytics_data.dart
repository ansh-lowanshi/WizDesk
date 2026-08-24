import 'package:equatable/equatable.dart';
import '../../../tasks/domain/entities/focus_session_entity.dart';
import 'analytics_time_range.dart';

/// Single data point for productivity bar chart
class ChartBarPoint extends Equatable {
  final String label; // e.g. "Mon", "W32", "Aug"
  final double valueMinutes; // Total focus minutes recorded for this slot
  final int taskCount; // Tasks completed during this slot
  final DateTime date;
  final bool isTargetDay; // Highlights current day/period

  const ChartBarPoint({
    required this.label,
    required this.valueMinutes,
    required this.taskCount,
    required this.date,
    this.isTargetDay = false,
  });

  /// Formatted duration string (e.g. "1h 45m" or "30m")
  String get formattedDuration {
    final int mins = valueMinutes.round();
    final int hours = mins ~/ 60;
    final int remMins = mins % 60;
    if (hours > 0 && remMins > 0) {
      return '${hours}h ${remMins}m';
    } else if (hours > 0) {
      return '${hours}h';
    }
    return '${remMins}m';
  }

  @override
  List<Object?> get props => [label, valueMinutes, taskCount, date, isTargetDay];
}

/// Category focus distribution metric item
class CategoryAnalyticsItem extends Equatable {
  final String categoryId;
  final String categoryName;
  final int iconCode;
  final int colorValue;
  final int spentMinutes;
  final int tasksCompleted;
  final double percentageShare; // 0.0 to 1.0 (e.g. 0.45 for 45%)

  const CategoryAnalyticsItem({
    required this.categoryId,
    required this.categoryName,
    required this.iconCode,
    required this.colorValue,
    required this.spentMinutes,
    required this.tasksCompleted,
    required this.percentageShare,
  });

  String get formattedDuration {
    final int hours = spentMinutes ~/ 60;
    final int remMins = spentMinutes % 60;
    if (hours > 0 && remMins > 0) {
      return '${hours}h ${remMins}m';
    } else if (hours > 0) {
      return '${hours}h';
    }
    return '${remMins}m';
  }

  @override
  List<Object?> get props => [
        categoryId,
        categoryName,
        iconCode,
        colorValue,
        spentMinutes,
        tasksCompleted,
        percentageShare,
      ];
}

/// Comprehensive Productivity Summary aggregation
class AnalyticsSummary extends Equatable {
  final AnalyticsTimeRange timeRange;
  final int totalFocusMinutes;
  final int totalTasksCompleted;
  final int totalTasksCreated;
  final int totalFocusSessions;
  final String bestDayLabel;
  final int currentStreakDays;
  final int productivityScore; // 0 to 100
  final List<ChartBarPoint> chartPoints;
  final List<CategoryAnalyticsItem> categoryBreakdown;
  final List<FocusSessionEntity> recentSessions;

  const AnalyticsSummary({
    required this.timeRange,
    required this.totalFocusMinutes,
    required this.totalTasksCompleted,
    required this.totalTasksCreated,
    required this.totalFocusSessions,
    required this.bestDayLabel,
    required this.currentStreakDays,
    required this.productivityScore,
    required this.chartPoints,
    required this.categoryBreakdown,
    required this.recentSessions,
  });

  /// Completion rate percentage (0.0 to 100.0)
  double get completionRatePercentage {
    if (totalTasksCreated <= 0) return 0.0;
    return ((totalTasksCompleted / totalTasksCreated) * 100).clamp(0.0, 100.0);
  }

  /// Formatted total focus time
  String get formattedTotalFocusTime {
    final int hours = totalFocusMinutes ~/ 60;
    final int remMins = totalFocusMinutes % 60;
    if (hours > 0 && remMins > 0) {
      return '${hours}h ${remMins}m';
    } else if (hours > 0) {
      return '${hours}h';
    }
    return '${remMins}m';
  }

  @override
  List<Object?> get props => [
        timeRange,
        totalFocusMinutes,
        totalTasksCompleted,
        totalTasksCreated,
        totalFocusSessions,
        bestDayLabel,
        currentStreakDays,
        productivityScore,
        chartPoints,
        categoryBreakdown,
        recentSessions,
      ];
}
