import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/bloc/locale_bloc.dart';
import '../../../../core/localization/bloc/locale_event.dart';
import '../../../../core/localization/bloc/locale_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';

/// Interactive Language Selector Section with Bottom Sheet Picker
class LanguageSelectorSection extends StatelessWidget {
  const LanguageSelectorSection({super.key});

  void _showLanguagePicker(BuildContext context, AppLanguage currentLanguage) {
    final l10n = context.l10n;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalCtx) {
        return ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated.withAlpha(
                  AppColors.isDarkMode ? 245 : 255,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                border: Border.all(
                  color: AppColors.border.withAlpha(80),
                  width: 1.2,
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag indicator handle
                    Container(
                      width: 42.w,
                      height: 4.h,
                      margin: EdgeInsets.only(bottom: 16.h),
                      decoration: BoxDecoration(
                        color: AppColors.textMuted.withAlpha(80),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),

                    // Header
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: AppColors.accentCyan.withAlpha(30),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.translate_rounded,
                            color: AppColors.accentCyan,
                            size: 20.r,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.chooseLanguage,
                                style: AppTypography.heading3,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                l10n.selectAppLanguage,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: AppColors.textMuted,
                            size: 22.r,
                          ),
                          onPressed: () => Navigator.of(modalCtx).pop(),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // Language List
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: AppLanguage.values.length,
                      separatorBuilder: (context, index) => SizedBox(height: 8.h),
                      itemBuilder: (ctx, index) {
                        final lang = AppLanguage.values[index];
                        final isSelected = lang == currentLanguage;

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            key: ValueKey('lang_option_${lang.code}'),
                            onTap: () {
                              Navigator.of(modalCtx).pop();

                              // Update locale & preferences
                              context
                                  .read<LocaleBloc>()
                                  .add(ChangeLanguageEvent(lang));
                              context
                                  .read<SettingsBloc>()
                                  .add(UpdateLanguageEvent(lang.code));

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.languageChangedSuccess),
                                  backgroundColor: AppColors.primary,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16.r),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withAlpha(35)
                                    : AppColors.surfaceElevated.withAlpha(90),
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.accentCyan
                                      : AppColors.border.withAlpha(60),
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Flag container
                                  Container(
                                    width: 40.r,
                                    height: 40.r,
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceElevated,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.border.withAlpha(70),
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      lang.flag,
                                      style: TextStyle(fontSize: 22.sp),
                                    ),
                                  ),
                                  SizedBox(width: 14.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          lang.nativeName,
                                          style: AppTypography.titleMedium
                                              .copyWith(
                                            color: isSelected
                                                ? (AppColors.isDarkMode
                                                    ? AppColors.accentCyan
                                                    : AppColors.primary)
                                                : AppColors.textPrimary,
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: 2.h),
                                        Text(
                                          lang.name,
                                          style: AppTypography.caption.copyWith(
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Container(
                                      padding: EdgeInsets.all(4.r),
                                      decoration: const BoxDecoration(
                                        color: AppColors.accentCyan,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.check_rounded,
                                        color: Colors.black,
                                        size: 16.r,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 12.h),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<LocaleBloc, LocaleState>(
      builder: (context, state) {
        final currentLanguage = state.language;

        return GlassmorphicCard(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: AppColors.accentCyan.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.translate_rounded,
                      color: AppColors.accentCyan,
                      size: 18.r,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.language,
                          style: AppTypography.heading3,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          l10n.languageSubtitle,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 14.h),

              // Current Selection & Tap to Change Card
              Material(
                color: Colors.transparent,
                child: InkWell(
                  key: const ValueKey('settings_language_selector_btn'),
                  onTap: () => _showLanguagePicker(context, currentLanguage),
                  borderRadius: BorderRadius.circular(16.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated.withAlpha(
                        AppColors.isDarkMode ? 120 : 180,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: AppColors.border.withAlpha(90),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36.r,
                          height: 36.r,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.border.withAlpha(60),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            currentLanguage.flag,
                            style: TextStyle(fontSize: 20.sp),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentLanguage.nativeName,
                                style: AppTypography.titleSmall.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                currentLanguage.name,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(30),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: AppColors.primary.withAlpha(80),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l10n.chooseLanguage,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.isDarkMode
                                      ? AppColors.accentCyan
                                      : AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 16.r,
                                color: AppColors.isDarkMode
                                    ? AppColors.accentCyan
                                    : AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
