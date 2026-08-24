import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_icon_helper.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../../../core/widgets/responsive_wrapper.dart';
import '../../domain/entities/task_category_entity.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_enums.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../widgets/add_category_dialog.dart';

/// Screen for Creating new Tasks or Editing existing Tasks
class AddEditTaskScreen extends StatefulWidget {
  final TaskEntity? taskToEdit;

  const AddEditTaskScreen({
    super.key,
    this.taskToEdit,
  });

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  late String _selectedCategoryId;
  late TaskPriority _selectedPriority;
  DateTime? _selectedDueDate;
  TimeOfDay? _selectedDueTime;
  late TaskFrequency _selectedFrequency;
  late List<int> _selectedCustomDays;
  late int _estimatedMinutes;
  late bool _isFocusModeEnabled;

  final List<int> _quickDurations = const [15, 25, 45, 60, 90];
  final List<String> _weekdayNames = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  void initState() {
    super.initState();
    final task = widget.taskToEdit;

    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController =
        TextEditingController(text: task?.description ?? '');

    _selectedCategoryId = task?.categoryId ?? 'cat_work';
    _selectedPriority = task?.priority ?? TaskPriority.medium;
    _selectedDueDate = task?.dueDate ?? DateTime.now();
    _selectedDueTime = task?.dueDate != null
        ? TimeOfDay(
            hour: task!.dueDate!.hour, minute: task.dueDate!.minute)
        : null;
    _selectedFrequency = task?.frequency ?? TaskFrequency.once;
    _selectedCustomDays = task?.customDays != null
        ? List<int>.from(task!.customDays)
        : [1, 3, 5];
    _estimatedMinutes = task?.estimatedMinutes ?? 25;
    _isFocusModeEnabled = task?.isFocusModeEnabled ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surfaceElevated,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedDueTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surfaceElevated,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDueTime = picked;
      });
    }
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    DateTime? finalDueDateTime = _selectedDueDate;
    if (finalDueDateTime != null && _selectedDueTime != null) {
      finalDueDateTime = DateTime(
        finalDueDateTime.year,
        finalDueDateTime.month,
        finalDueDateTime.day,
        _selectedDueTime!.hour,
        _selectedDueTime!.minute,
      );
    }

    if (widget.taskToEdit != null) {
      // Edit existing task
      final updated = widget.taskToEdit!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        categoryId: _selectedCategoryId,
        priority: _selectedPriority,
        dueDate: finalDueDateTime,
        frequency: _selectedFrequency,
        customDays: _selectedFrequency == TaskFrequency.customDays
            ? _selectedCustomDays
            : const [],
        estimatedMinutes: _estimatedMinutes,
        isFocusModeEnabled: _isFocusModeEnabled,
      );
      context.read<TaskBloc>().add(UpdateTaskEvent(updated));
    } else {
      // Add new task
      final newTask = TaskEntity(
        id: 'task_${const Uuid().v4()}',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        categoryId: _selectedCategoryId,
        priority: _selectedPriority,
        status: TaskStatus.todo,
        dueDate: finalDueDateTime,
        frequency: _selectedFrequency,
        customDays: _selectedFrequency == TaskFrequency.customDays
            ? _selectedCustomDays
            : const [],
        estimatedMinutes: _estimatedMinutes,
        spentMinutes: 0,
        isFocusModeEnabled: _isFocusModeEnabled,
        createdAt: DateTime.now(),
      );
      context.read<TaskBloc>().add(AddTaskEvent(newTask));
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.taskToEdit != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 18.r, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isEditing ? 'Edit Task' : 'New Task',
          style: AppTypography.heading3,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check_circle_rounded,
                size: 24.r, color: AppColors.accentCyan),
            onPressed: _saveTask,
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SafeArea(
        child: ResponsiveWrapper(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Input
                  Text('Task Title', style: AppTypography.titleSmall),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: _titleController,
                    style: AppTypography.bodyLarge.copyWith(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'What needs to be accomplished?',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a task title';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 20.h),

                  // Description Input
                  Text('Notes & Description', style: AppTypography.titleSmall),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: _descriptionController,
                    style: AppTypography.bodyLarge.copyWith(color: Colors.white),
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Add details, subtasks, or objectives...',
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Category Selector
                  BlocBuilder<TaskBloc, TaskState>(
                    builder: (context, state) {
                      final categories = state is TaskLoaded
                          ? state.categories
                          : <TaskCategoryEntity>[];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Category', style: AppTypography.titleSmall),
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AddCategoryDialog(
                                      onCategoryCreated: (newCat) {
                                        context
                                            .read<TaskBloc>()
                                            .add(AddCategoryEvent(newCat));
                                        setState(() {
                                          _selectedCategoryId = newCat.id;
                                        });
                                      },
                                    ),
                                  );
                                },
                                child: Text(
                                  '+ Add Category',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.accentCyan,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          SizedBox(
                            height: 38.h,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: categories.length,
                              separatorBuilder: (context, index) => SizedBox(width: 8.w),
                              itemBuilder: (context, index) {
                                final cat = categories[index];
                                final isSelected = _selectedCategoryId == cat.id;
                                final color = Color(cat.colorValue);

                                return GestureDetector(
                                  onTap: () => setState(
                                      () => _selectedCategoryId = cat.id),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12.w, vertical: 6.h),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? color.withAlpha(40)
                                          : AppColors.surface,
                                      borderRadius:
                                          BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: isSelected
                                            ? color
                                            : AppColors.border,
                                        width: isSelected ? 1.5 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          AppIconHelper.getCategoryIcon(
                                              cat.iconCode),
                                          size: 14.r,
                                          color: isSelected
                                              ? color
                                              : AppColors.textSecondary,
                                        ),
                                        SizedBox(width: 6.w),
                                        Text(
                                          cat.name,
                                          style: AppTypography.caption.copyWith(
                                            color: isSelected
                                                ? Colors.white
                                                : AppColors.textSecondary,
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  SizedBox(height: 24.h),

                  // Priority Selector
                  Text('Priority Level', style: AppTypography.titleSmall),
                  SizedBox(height: 10.h),
                  Row(
                    children: TaskPriority.values.map((priority) {
                      final isSelected = _selectedPriority == priority;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedPriority = priority),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: EdgeInsets.symmetric(horizontal: 3.w),
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? priority.color.withAlpha(35)
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: isSelected
                                    ? priority.color
                                    : AppColors.border,
                                width: isSelected ? 1.5 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: priority.color.withAlpha(80),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 6.r,
                                      height: 6.r,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: priority.color,
                                      ),
                                    ),
                                    SizedBox(width: 5.w),
                                    Text(
                                      priority.label,
                                      style: AppTypography.caption.copyWith(
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.textSecondary,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 24.h),

                  // Due Date & Time Section
                  Text('Schedule & Due Date', style: AppTypography.titleSmall),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      // Date Selector Card
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickDate,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 14.w, vertical: 12.h),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14.r),
                              border:
                                  Border.all(color: AppColors.border, width: 1),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today_rounded,
                                    size: 16.r, color: AppColors.accentCyan),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    _selectedDueDate != null
                                        ? DateFormat('MMM d, yyyy')
                                            .format(_selectedDueDate!)
                                        : 'Select Date',
                                    style: AppTypography.bodyMedium.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),

                      // Time Selector Card
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickTime,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 14.w, vertical: 12.h),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14.r),
                              border:
                                  Border.all(color: AppColors.border, width: 1),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.access_time_rounded,
                                    size: 16.r, color: AppColors.primaryLight),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    _selectedDueTime != null
                                        ? _selectedDueTime!.format(context)
                                        : 'Optional Time',
                                    style: AppTypography.bodyMedium.copyWith(
                                        color: _selectedDueTime != null
                                            ? Colors.white
                                            : AppColors.textMuted,
                                        fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // Recurrence Configuration
                  Text('Frequency / Recurrence', style: AppTypography.titleSmall),
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: TaskFrequency.values.map((freq) {
                      final isSelected = _selectedFrequency == freq;
                      return ChoiceChip(
                        label: Text(freq.label),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surface,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 12.sp,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primaryLight
                              : AppColors.border,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedFrequency = freq);
                          }
                        },
                      );
                    }).toList(),
                  ),

                  // Custom Weekdays selector (when customDays is selected)
                  if (_selectedFrequency == TaskFrequency.customDays) ...[
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (i) {
                        final int dayIndex = i + 1; // 1 = Mon ... 7 = Sun
                        final isDaySelected =
                            _selectedCustomDays.contains(dayIndex);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isDaySelected) {
                                if (_selectedCustomDays.length > 1) {
                                  _selectedCustomDays.remove(dayIndex);
                                }
                              } else {
                                _selectedCustomDays.add(dayIndex);
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 38.r,
                            height: 38.r,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isDaySelected
                                  ? AppColors.accentCyan
                                  : AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDaySelected
                                    ? AppColors.accentCyan
                                    : AppColors.border,
                              ),
                            ),
                            child: Text(
                              _weekdayNames[i],
                              style: AppTypography.badge.copyWith(
                                color: isDaySelected
                                    ? AppColors.background
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],

                  SizedBox(height: 24.h),

                  // Focus Mode & Estimated Time Section
                  GlassmorphicCard(
                    padding: EdgeInsets.all(16.r),
                    borderColor: _isFocusModeEnabled
                        ? AppColors.accentCyan.withAlpha(80)
                        : AppColors.border,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(Icons.timer_rounded,
                                      size: 20.r, color: AppColors.accentCyan),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Pomodoro Focus Mode',
                                            style: AppTypography.titleMedium
                                                .copyWith(color: Colors.white)),
                                        Text('Integrate 25+5 min session tracking',
                                            style: AppTypography.caption),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Switch.adaptive(
                              value: _isFocusModeEnabled,
                              activeThumbColor: AppColors.accentCyan,
                              activeTrackColor: AppColors.primary,
                              onChanged: (val) {
                                setState(() => _isFocusModeEnabled = val);
                              },
                            ),
                          ],
                        ),
                        if (_isFocusModeEnabled) ...[
                          SizedBox(height: 16.h),
                          Text('Estimated Focus Duration',
                              style: AppTypography.bodySmall),
                          SizedBox(height: 10.h),
                          Row(
                            children: _quickDurations.map((duration) {
                              final isSelected = _estimatedMinutes == duration;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(
                                      () => _estimatedMinutes = duration),
                                  child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: 2.w),
                                    padding: EdgeInsets.symmetric(vertical: 8.h),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.surfaceElevated,
                                      borderRadius: BorderRadius.circular(10.r),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.accentCyan
                                            : AppColors.border,
                                      ),
                                    ),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        '${duration}m',
                                        style: AppTypography.caption.copyWith(
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.textSecondary,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: 32.h),

                  // Bottom Save Action Button
                  Container(
                    width: double.infinity,
                    height: 52.h,
                    decoration: AppDecorations.glowButton(),
                    child: ElevatedButton(
                      onPressed: _saveTask,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isEditing ? Icons.save_rounded : Icons.add_rounded,
                            size: 20.r,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            isEditing ? 'Save Changes' : 'Create Task',
                            style: AppTypography.buttonLarge,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
