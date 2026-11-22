import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../domain/models/analytics_data.dart';

/// Interactive Productivity Bar Chart with glowing neon gradients
class ProductivityChartCard extends StatefulWidget {
  final List<ChartBarPoint> points;
  final String timeRangeSubtitle;

  const ProductivityChartCard({
    super.key,
    required this.points,
    required this.timeRangeSubtitle,
  });

  @override
  State<ProductivityChartCard> createState() => _ProductivityChartCardState();
}

class _ProductivityChartCardState extends State<ProductivityChartCard> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final double maxMinutes = widget.points.isEmpty
        ? 60
        : widget.points
            .map((p) => p.valueMinutes)
            .reduce((a, b) => a > b ? a : b);

    // Calculate nice Y-axis interval
    final double maxY = maxMinutes <= 0 ? 60 : (maxMinutes * 1.25);

    return GlassmorphicCard(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      borderRadius: 20.r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.focusActivity,
                        style: AppTypography.heading3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    SizedBox(height: 2.h),
                    Text(
                      widget.timeRangeSubtitle,
                      style: AppTypography.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.accentCyan.withAlpha(25),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6.r,
                      height: 6.r,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accentCyan,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Minutes',
                      style: AppTypography.badge.copyWith(
                        color: AppColors.accentCyan,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // Bar Chart
          SizedBox(
            height: 180.h,
            child: widget.points.isEmpty
                ? Center(
                    child: Text('No data for this time period',
                        style: AppTypography.caption),
                  )
                : BarChart(
                    BarChartData(
                      maxY: maxY,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => AppColors.surfaceElevated,
                          tooltipBorder: BorderSide(
                            color: AppColors.border,
                            width: 1,
                          ),
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final point = widget.points[group.x.toInt()];
                            return BarTooltipItem(
                              '${point.label}\n',
                              AppTypography.titleSmall.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      '${point.formattedDuration}\n${point.taskCount} tasks done',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.accentCyan,
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        touchCallback: (event, response) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                response == null ||
                                response.spot == null) {
                              _touchedIndex = -1;
                              return;
                            }
                            _touchedIndex =
                                response.spot!.touchedBarGroupIndex;
                          });
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32.w,
                            interval: maxY > 60 ? (maxY / 3) : 20,
                            getTitlesWidget: (value, meta) {
                              if (value == 0) return const SizedBox();
                              return Text(
                                '${value.toInt()}m',
                                style: AppTypography.caption.copyWith(
                                  fontSize: 9.sp,
                                  color: AppColors.textMuted,
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28.h,
                            getTitlesWidget: (value, meta) {
                              final int index = value.toInt();
                              if (index < 0 || index >= widget.points.length) {
                                return const SizedBox();
                              }
                              final point = widget.points[index];
                              final isSelected = index == _touchedIndex ||
                                  (_touchedIndex == -1 && point.isTargetDay);

                              return Padding(
                                padding: EdgeInsets.only(top: 8.h),
                                child: Text(
                                  point.label,
                                  style: AppTypography.caption.copyWith(
                                    color: isSelected
                                        ? AppColors.accentCyan
                                        : AppColors.textSecondary,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    fontSize: 10.sp,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval:
                            maxY > 60 ? (maxY / 3) : 20,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: AppColors.border.withAlpha(50),
                            strokeWidth: 1,
                            dashArray: [4, 4],
                          );
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: widget.points.asMap().entries.map((entry) {
                        final index = entry.key;
                        final point = entry.value;
                        final isTouched = index == _touchedIndex;
                        final isTarget = point.isTargetDay;

                        final double rodValue = point.valueMinutes <= 0
                            ? (maxY * 0.03) // Subtle minimum bar indicator
                            : point.valueMinutes;

                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: rodValue,
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: isTouched || isTarget
                                    ? [
                                        AppColors.primary,
                                        AppColors.accentCyan,
                                      ]
                                    : [
                                        AppColors.surfaceElevated,
                                        AppColors.primary.withAlpha(160),
                                      ],
                              ),
                              width: widget.points.length <= 4 ? 24.w : 14.w,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(6.r),
                              ),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: maxY,
                                color:
                                    AppColors.surfaceElevated.withAlpha(60),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
