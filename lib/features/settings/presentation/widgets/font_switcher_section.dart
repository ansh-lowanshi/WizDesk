import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../domain/models/app_font_family.dart';

/// Font Switcher Section with Live Previews & Interactive Chip Toggles
class FontSwitcherSection extends StatelessWidget {
  final AppFontFamily selectedFont;
  final ValueChanged<AppFontFamily> onFontSelected;

  const FontSwitcherSection({
    super.key,
    required this.selectedFont,
    required this.onFontSelected,
  });

  TextStyle _getFontPreviewStyle(AppFontFamily font) {
    switch (font) {
      case AppFontFamily.spaceGrotesk:
        return GoogleFonts.spaceGrotesk();
      case AppFontFamily.inter:
        return GoogleFonts.inter();
      case AppFontFamily.outfit:
        return GoogleFonts.outfit();
      case AppFontFamily.plusJakartaSans:
        return GoogleFonts.plusJakartaSans();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      padding: EdgeInsets.all(16.r),
      borderRadius: 20.r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(30),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.font_download_rounded,
                  size: 18.r,
                  color: AppColors.primaryLight,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Typography & Font', style: AppTypography.heading3),
                    Text(
                      'Select your preferred visual style',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          // Font Selection List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: AppFontFamily.values.length,
            separatorBuilder: (context, index) => SizedBox(height: 10.h),
            itemBuilder: (context, index) {
              final font = AppFontFamily.values[index];
              final isSelected = font == selectedFont;
              final fontStyle = _getFontPreviewStyle(font);

              return InkWell(
                key: ValueKey('font_option_${font.id}'),
                onTap: () => onFontSelected(font),
                borderRadius: BorderRadius.circular(14.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withAlpha(25)
                        : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: isSelected
                          ? (AppColors.isDarkMode
                              ? AppColors.accentCyan
                              : AppColors.primary)
                          : AppColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Radio icon
                      Container(
                        width: 20.r,
                        height: 20.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? (AppColors.isDarkMode
                                  ? AppColors.accentCyan
                                  : AppColors.primary)
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? (AppColors.isDarkMode
                                    ? AppColors.accentCyan
                                    : AppColors.primary)
                                : AppColors.textMuted,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Icon(Icons.check,
                                size: 12.r,
                                color: AppColors.isDarkMode
                                    ? AppColors.background
                                    : Colors.white)
                            : null,
                      ),

                      SizedBox(width: 14.w),

                      // Font Name & Subtitle in its own font
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              font.displayName,
                              style: fontStyle.copyWith(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? (AppColors.isDarkMode
                                        ? Colors.white
                                        : AppColors.primary)
                                    : AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              font.subtitle,
                              style: fontStyle.copyWith(
                                fontSize: 11.sp,
                                color: isSelected
                                    ? (AppColors.isDarkMode
                                        ? AppColors.accentCyan
                                        : AppColors.primary)
                                    : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Sample preview tag
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: AppColors.border,
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          'Aa',
                          style: fontStyle.copyWith(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
