import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/responsive_wrapper.dart';
import '../../domain/models/analytics_time_range.dart';
import '../bloc/analytics_bloc.dart';
import '../bloc/analytics_event.dart';
import '../bloc/analytics_state.dart';
import '../widgets/category_distribution_card.dart';
import '../widgets/productivity_chart_card.dart';
import '../widgets/productivity_metric_cards.dart';
import '../widgets/productivity_score_banner.dart';
import '../widgets/recent_sessions_card.dart';

/// Full Interactive Productivity & Focus Analytics Screen
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<AnalyticsBloc>();
    if (bloc.state is! AnalyticsLoaded) {
      bloc.add(const LoadAnalyticsEvent(timeRange: AnalyticsTimeRange.daily));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18.r, color: AppColors.textPrimary),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: Text('Productivity Analytics', style: AppTypography.heading3),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded,
                size: 22.r, color: AppColors.accentCyan),
            tooltip: 'Refresh Metrics',
            onPressed: () {
              final currentState = context.read<AnalyticsBloc>().state;
              final range = currentState is AnalyticsLoaded
                  ? currentState.summary.timeRange
                  : AnalyticsTimeRange.daily;
              context
                  .read<AnalyticsBloc>()
                  .add(LoadAnalyticsEvent(timeRange: range));
            },
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SafeArea(
        child: ResponsiveWrapper(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
          child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
            builder: (context, state) {
              if (state is AnalyticsInitial || state is AnalyticsLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.accentCyan,
                  ),
                );
              }

              if (state is AnalyticsError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline_rounded,
                          size: 40.r, color: AppColors.error),
                      SizedBox(height: 12.h),
                      Text(state.message, style: AppTypography.bodyMedium),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<AnalyticsBloc>()
                              .add(const LoadAnalyticsEvent());
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (state is AnalyticsLoaded) {
                final summary = state.summary;

                return RefreshIndicator(
                  color: AppColors.accentCyan,
                  backgroundColor: AppColors.surfaceElevated,
                  onRefresh: () async {
                    context.read<AnalyticsBloc>().add(
                          LoadAnalyticsEvent(timeRange: summary.timeRange),
                        );
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Time Range Selector Tabs (Daily, Weekly, Monthly)
                        _buildTimeRangeSelector(summary.timeRange),

                        SizedBox(height: 18.h),

                        // Hero Productivity Score Banner
                        ProductivityScoreBanner(summary: summary),

                        SizedBox(height: 18.h),

                        // 4-Grid Metric Cards
                        ProductivityMetricCards(summary: summary),

                        SizedBox(height: 18.h),

                        // Productivity Bar Chart
                        ProductivityChartCard(
                          points: summary.chartPoints,
                          timeRangeSubtitle: summary.timeRange.subtitle,
                        ),

                        SizedBox(height: 18.h),

                        // Category Distribution Breakdown
                        CategoryDistributionCard(
                          items: summary.categoryBreakdown,
                        ),

                        SizedBox(height: 18.h),

                        // Recent Focus Session Logs
                        RecentSessionsCard(
                          sessions: summary.recentSessions,
                        ),

                        SizedBox(height: 90.h),
                      ],
                    ),
                  ),
                );
              }

              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRangeSelector(AnalyticsTimeRange activeRange) {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: AnalyticsTimeRange.values.map((range) {
          final isSelected = activeRange == range;
          return Expanded(
            child: GestureDetector(
              key: ValueKey('analytics_range_${range.name}'),
              behavior: HitTestBehavior.opaque,
              onTap: () {
                context
                    .read<AnalyticsBloc>()
                    .add(ChangeAnalyticsTimeRangeEvent(range));
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 8.h),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(120),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  range.label,
                  style: AppTypography.buttonMedium.copyWith(
                    color: isSelected
                        ? Colors.white
                        : AppColors.textSecondary,
                    fontWeight:
                        isSelected ? FontWeight.w800 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
