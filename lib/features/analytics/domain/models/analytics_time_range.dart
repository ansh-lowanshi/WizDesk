/// Time ranges available for productivity analytics
enum AnalyticsTimeRange {
  daily('Daily', 'Last 7 Days'),
  weekly('Weekly', 'Last 4 Weeks'),
  monthly('Monthly', 'Last 6 Months');

  final String label;
  final String subtitle;

  const AnalyticsTimeRange(this.label, this.subtitle);
}
