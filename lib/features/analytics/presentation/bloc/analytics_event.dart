import 'package:equatable/equatable.dart';
import '../../domain/models/analytics_time_range.dart';

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => [];
}

/// Load or refresh analytics metrics for selected time range
class LoadAnalyticsEvent extends AnalyticsEvent {
  final AnalyticsTimeRange timeRange;

  const LoadAnalyticsEvent({this.timeRange = AnalyticsTimeRange.daily});

  @override
  List<Object?> get props => [timeRange];
}

/// Switch time range (Daily / Weekly / Monthly)
class ChangeAnalyticsTimeRangeEvent extends AnalyticsEvent {
  final AnalyticsTimeRange timeRange;

  const ChangeAnalyticsTimeRangeEvent(this.timeRange);

  @override
  List<Object?> get props => [timeRange];
}
