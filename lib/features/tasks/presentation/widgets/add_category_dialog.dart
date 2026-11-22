import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/app_icon_helper.dart';
import '../../domain/entities/task_category_entity.dart';

/// Modal dialog allowing user to define a new custom category
class AddCategoryDialog extends StatefulWidget {
  final ValueChanged<TaskCategoryEntity> onCategoryCreated;

  const AddCategoryDialog({
    super.key,
    required this.onCategoryCreated,
  });

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  late final TextEditingController _nameController;
  int _selectedColorValue = 0xFF3874FF;
  int _selectedIconCode = 0xe6f2;

  final List<int> _colorOptions = const [
    0xFF3874FF, // Primary Blue
    0xFF00F0FF, // Neon Cyan
    0xFF7F56D9, // Purple
    0xFFFF6B6B, // Coral
    0xFFFFB020, // Amber
    0xFF10B981, // Emerald
    0xFFEC4899, // Pink
    0xFF8B5CF6, // Violet
  ];

  final List<int> _iconOptions = const [
    0xe6f2, // Work
    0xe559, // School
    0xe194, // Coding
    0xe471, // Palette/Design
    0xe294, // Fitness
    0xe491, // Person
    0xe3e7, // Book
    0xe0be, // Phone
    0xe318, // Idea
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final newCategory = TaskCategoryEntity(
      id: 'cat_${const Uuid().v4()}',
      name: name,
      iconCode: _selectedIconCode,
      colorValue: _selectedColorValue,
    );

    widget.onCategoryCreated(newCategory);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(context.l10n.newCategory, style: AppTypography.heading3),
                  IconButton(
                    icon: Icon(Icons.close_rounded,
                        size: 20.r, color: AppColors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Category Name Input
              TextField(
                controller: _nameController,
                style: AppTypography.bodyLarge
                    .copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: context.l10n.category,
                  hintText: 'e.g. Finance, Reading, Project X',
                ),
              ),
              SizedBox(height: 18.h),

              // Color Picker
              Text('Select Color', style: AppTypography.titleSmall),
              SizedBox(height: 10.h),
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: _colorOptions.map((colorVal) {
                  final isSelected = _selectedColorValue == colorVal;
                  final color = Color(colorVal);
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColorValue = colorVal),
                    child: Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 2.5)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withAlpha(120),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? Icon(Icons.check_rounded,
                              size: 16.r, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 18.h),

              // Icon Picker
              Text('Select Icon', style: AppTypography.titleSmall),
              SizedBox(height: 10.h),
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: _iconOptions.map((iconCode) {
                  final isSelected = _selectedIconCode == iconCode;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIconCode = iconCode),
                    child: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Color(_selectedColorValue).withAlpha(40)
                            : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: isSelected
                              ? Color(_selectedColorValue)
                              : AppColors.border,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Icon(
                        AppIconHelper.getCategoryIcon(iconCode),
                        size: 20.r,
                        color: isSelected
                            ? Color(_selectedColorValue)
                            : AppColors.textSecondary,
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 24.h),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.border),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(context.l10n.cancel,
                          style: AppTypography.buttonMedium
                              .copyWith(color: AppColors.textSecondary)),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Container(
                      decoration: AppDecorations.glowButton(borderRadius: 12.r),
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(context.l10n.save, style: AppTypography.buttonMedium),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
