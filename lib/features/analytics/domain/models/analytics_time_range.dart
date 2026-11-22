import 'package:flutter/widgets.dart';
import '../../../../core/localization/app_localizations.dart';

/// Time ranges available for productivity analytics
enum AnalyticsTimeRange {
  daily('Daily', 'Last 7 Days'),
  weekly('Weekly', 'Last 4 Weeks'),
  monthly('Monthly', 'Last 6 Months');

  final String label;
  final String subtitle;

  const AnalyticsTimeRange(this.label, this.subtitle);

  String localizedLabel(BuildContext context) {
    switch (this) {
      case AnalyticsTimeRange.daily:
        return context.l10n.daily;
      case AnalyticsTimeRange.weekly:
        return context.l10n.weekly;
      case AnalyticsTimeRange.monthly:
        return context.l10n.monthly;
    }
  }

  String localizedSubtitle(BuildContext context) {
    switch (this) {
      case AnalyticsTimeRange.daily:
        return context.l10n.last7Days;
      case AnalyticsTimeRange.weekly:
        return context.l10n.last4Weeks;
      case AnalyticsTimeRange.monthly:
        return context.l10n.last6Months;
    }
  }
}

