import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

/// Ultra-Modern Glassmorphic Floating Bottom Navigation Bar
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onQuickAdd;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onQuickAdd,
  });

  static const List<NavItem> _items = [
    NavItem(
      icon: Icons.checklist_rounded,
      activeIcon: Icons.checklist_rounded,
      label: 'Tasks',
    ),
    NavItem(
      icon: Icons.timer_outlined,
      activeIcon: Icons.timer_rounded,
      label: 'Focus',
    ),
    NavItem(
      icon: Icons.insights_rounded,
      activeIcon: Icons.insights_rounded,
      label: 'Analytics',
    ),
    NavItem(
      icon: Icons.tune_rounded,
      activeIcon: Icons.tune_rounded,
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
        child: SizedBox(
          height: 64.h,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated.withAlpha(220),
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: AppColors.borderLight.withAlpha(80),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(120),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Tab 0: Tasks
                    Expanded(child: _buildNavItem(0)),

                    // Tab 1: Focus
                    Expanded(child: _buildNavItem(1)),

                    // Center Quick Add Button (FAB)
                    _buildQuickAddButton(),

                    // Tab 2: Analytics
                    Expanded(child: _buildNavItem(2)),

                    // Tab 3: Settings
                    Expanded(child: _buildNavItem(3)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = _items[index];
    final isSelected = currentIndex == index;

    return InkWell(
      key: ValueKey('nav_item_$index'),
      onTap: () => onTabSelected(index),
      borderRadius: BorderRadius.circular(16.r),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 8.w : 4.w,
            vertical: 4.h,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withAlpha(40)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14.r),
            border: isSelected
                ? Border.all(
                    color: AppColors.accentCyan.withAlpha(120), width: 1)
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? item.activeIcon : item.icon,
                size: 20.r,
                color: isSelected ? AppColors.accentCyan : AppColors.textMuted,
              ),
              SizedBox(height: 2.h),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption.copyWith(
                  fontSize: 9.5.sp,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : AppColors.textMuted.withAlpha(180),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAddButton() {
    return InkWell(
      key: const ValueKey('nav_quick_add_btn'),
      onTap: onQuickAdd,
      borderRadius: BorderRadius.circular(20.r),
      child: GlowContainer(
        glowColor: AppColors.accentCyan,
        blurRadius: 14,
        spreadRadius: 0,
        borderRadius: 20,
        child: Container(
          width: 44.r,
          height: 44.r,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(120),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.add_rounded,
            size: 26.r,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
