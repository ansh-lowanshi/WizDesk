import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_icon_helper.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../domain/models/analytics_data.dart';

/// Category Focus Time Distribution Card
class CategoryDistributionCard extends StatelessWidget {
  final List<CategoryAnalyticsItem> items;

  const CategoryDistributionCard({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      borderRadius: 20.r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Category Breakdown',
                  style: AppTypography.heading3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '${items.length} Categories',
                style: AppTypography.caption,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (items.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Center(
                child: Text(
                  'No focus logs recorded yet.\nStart a Pomodoro session to see category breakdown!',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => SizedBox(height: 14.h),
              itemBuilder: (context, index) {
                final item = items[index];
                final color = Color(item.colorValue);
                final percent = (item.percentageShare * 100).toStringAsFixed(0);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Category Icon Pill
                        Container(
                          padding: EdgeInsets.all(6.r),
                          decoration: BoxDecoration(
                            color: color.withAlpha(35),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            AppIconHelper.getCategoryIcon(item.iconCode),
                            size: 14.r,
                            color: color,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            item.categoryName,
                            style: AppTypography.titleSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          '${item.formattedDuration} ($percent%)',
                          style: AppTypography.caption.copyWith(
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: LinearProgressIndicator(
                        value: item.percentageShare.clamp(0.02, 1.0),
                        minHeight: 6.h,
                        backgroundColor: AppColors.surfaceElevated,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
