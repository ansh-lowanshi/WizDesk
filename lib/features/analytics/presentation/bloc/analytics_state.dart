import 'package:equatable/equatable.dart';
import '../../domain/models/analytics_data.dart';
import '../../domain/models/analytics_time_range.dart';

abstract class AnalyticsState extends Equatable {
  const AnalyticsState();

  @override
  List<Object?> get props => [];
}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoading extends AnalyticsState {
  final AnalyticsTimeRange timeRange;

  const AnalyticsLoading({this.timeRange = AnalyticsTimeRange.daily});

  @override
  List<Object?> get props => [timeRange];
}

class AnalyticsLoaded extends AnalyticsState {
  final AnalyticsSummary summary;

  const AnalyticsLoaded({required this.summary});

  @override
  List<Object?> get props => [summary];
}

class AnalyticsError extends AnalyticsState {
  final String message;

  const AnalyticsError(this.message);

  @override
  List<Object?> get props => [message];
}
