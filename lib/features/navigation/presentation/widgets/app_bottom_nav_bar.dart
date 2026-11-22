import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glow_container.dart';

/// Navigation item model
class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// Ultra-Modern Docked Bottom Navigation Bar connected to screen bottom
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  List<NavItem> _getItems(BuildContext context) {
    final l10n = context.l10n;
    return [
      NavItem(
        icon: Icons.today_outlined,
        activeIcon: Icons.today_rounded,
        label: l10n.navToday,
      ),
      NavItem(
        icon: Icons.calendar_month_outlined,
        activeIcon: Icons.calendar_month_rounded,
        label: l10n.navCalendar,
      ),
      NavItem(
        icon: Icons.timer_outlined,
        activeIcon: Icons.timer_rounded,
        label: l10n.navFocus,
      ),
      NavItem(
        icon: Icons.insights_outlined,
        activeIcon: Icons.insights_rounded,
        label: l10n.navAnalytics,
      ),
      NavItem(
        icon: Icons.tune_rounded,
        activeIcon: Icons.tune_rounded,
        label: l10n.navSettings,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final items = _getItems(context);
    final activeColor =
        AppColors.isDarkMode ? AppColors.accentCyan : AppColors.primary;

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: AppColors.isDarkMode
                ? Colors.black.withAlpha(140)
                : Colors.black.withAlpha(25),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated.withAlpha(
                AppColors.isDarkMode ? 230 : 245,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
              border: Border(
                top: BorderSide(
                  color: AppColors.border.withAlpha(AppColors.isDarkMode ? 100 : 180),
                  width: 1.2,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Container(
                height: 62.h,
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Tab 0: Today
                    Expanded(child: _buildNavItem(0, items[0], activeColor)),

                    // Tab 1: Calendar
                    Expanded(child: _buildNavItem(1, items[1], activeColor)),

                    // Tab 2: Focus (Elevated Center Glowing Button)
                    _buildCenterFocusButton(items[2].label),

                    // Tab 3: Analytics
                    Expanded(child: _buildNavItem(3, items[3], activeColor)),

                    // Tab 4: Settings
                    Expanded(child: _buildNavItem(4, items[4], activeColor)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, NavItem item, Color activeColor) {
    final isSelected = currentIndex == index;
    final activeTextColor =
        AppColors.isDarkMode ? Colors.white : AppColors.primary;

    return InkWell(
      key: ValueKey('nav_item_$index'),
      onTap: () => onTabSelected(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Top indicator bar when selected
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              width: isSelected ? 18.w : 0,
              height: 3.h,
              margin: EdgeInsets.only(bottom: 4.h),
              decoration: BoxDecoration(
                color: isSelected ? activeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(2.r),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: activeColor.withAlpha(160),
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
            ),

            // Icon + Animated pill background
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 12.w : 6.w,
                vertical: 3.h,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? activeColor.withAlpha(28)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                size: 21.r,
                color: isSelected
                    ? activeColor
                    : AppColors.textMuted.withAlpha(180),
              ),
            ),

            SizedBox(height: 2.h),

            // Label
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                fontSize: 10.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? activeTextColor
                    : AppColors.textMuted.withAlpha(180),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterFocusButton(String label) {
    final isSelected = currentIndex == 2;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: InkWell(
        key: const ValueKey('nav_item_2'),
        onTap: () => onTabSelected(2),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GlowContainer(
              glowColor: isSelected ? AppColors.accentCyan : AppColors.primary,
              blurRadius: isSelected ? 14 : 8,
              spreadRadius: 0,
              borderRadius: 16,
              child: Container(
                width: 42.r,
                height: 42.r,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(15.r),
                  border: Border.all(
                    color: isSelected
                        ? (AppColors.isDarkMode
                            ? AppColors.accentCyan
                            : Colors.white)
                        : Colors.white.withAlpha(50),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isSelected ? AppColors.accentCyan : AppColors.primary)
                          .withAlpha(120),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  isSelected ? Icons.timer_rounded : Icons.timer_outlined,
                  size: 22.r,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                fontSize: 10.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? (AppColors.isDarkMode
                        ? AppColors.accentCyan
                        : AppColors.primary)
                    : AppColors.textMuted.withAlpha(180),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
