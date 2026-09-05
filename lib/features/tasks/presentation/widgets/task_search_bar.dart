import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Instant search bar with clear button and modern glass aesthetics
class TaskSearchBar extends StatefulWidget {
  final ValueChanged<String> onSearchChanged;
  final VoidCallback? onFilterIconTap;

  const TaskSearchBar({
    super.key,
    required this.onSearchChanged,
    this.onFilterIconTap,
  });

  @override
  State<TaskSearchBar> createState() => _TaskSearchBarState();
}

class _TaskSearchBarState extends State<TaskSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onSearchChanged,
        style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          filled: false,
          hintText: 'Search tasks by title or tag...',
          hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20.r,
            color: AppColors.textSecondary,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close_rounded,
                      size: 18.r, color: AppColors.textSecondary),
                  onPressed: () {
                    _controller.clear();
                    widget.onSearchChanged('');
                    setState(() {});
                  },
                )
              : widget.onFilterIconTap != null
                  ? IconButton(
                      icon: Icon(Icons.tune_rounded,
                          size: 18.r, color: AppColors.primaryLight),
                      onPressed: widget.onFilterIconTap,
                    )
                  : null,
          contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}
