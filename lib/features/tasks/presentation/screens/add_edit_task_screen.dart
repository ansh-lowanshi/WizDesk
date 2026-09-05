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
import '../widgets/manage_categories_sheet.dart';

/// Screen for Creating new Tasks or Editing existing Tasks
class AddEditTaskScreen extends StatefulWidget {
  final TaskEntity? taskToEdit;
  final DateTime? initialDate;

  const AddEditTaskScreen({
    super.key,
    this.taskToEdit,
    this.initialDate,
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
  DateTime? _selectedEndDate;
  TimeOfDay? _selectedDueTime;
  late TaskFrequency _selectedFrequency;
  late TaskProgressMode _selectedProgressMode;
  late List<int> _selectedCustomDays;
  late int _estimatedMinutes;
  late int _progressPercent;
  late bool _isFocusModeEnabled;

  late DateTime _activeDate;
  bool _overrideDescriptionForActiveDate = false;

  final List<int> _quickDurations = const [15, 25, 45, 60, 90];
  final List<String> _weekdayNames = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  void initState() {
    super.initState();
    final task = widget.taskToEdit;
    _activeDate = widget.initialDate ?? task?.dueDate ?? DateTime.now();

    _titleController = TextEditingController(text: task?.title ?? '');

    // If editing recurring task and active date has a specific custom description, load that
    final dateDesc = task?.getDescriptionFor(_activeDate) ?? '';
    final hasCustomDayDesc = task != null &&
        task.frequency != TaskFrequency.once &&
        task.dailyDescriptions.containsKey(TaskEntity.formatDateKey(_activeDate)) &&
        task.dailyDescriptions[TaskEntity.formatDateKey(_activeDate)]!.trim().isNotEmpty;

    _overrideDescriptionForActiveDate = hasCustomDayDesc;
    _descriptionController = TextEditingController(
      text: task != null ? dateDesc : '',
    );

    _selectedCategoryId = task?.categoryId ?? 'cat_work';
    _selectedPriority = task?.priority ?? TaskPriority.medium;
    _selectedDueDate = task?.dueDate ?? widget.initialDate ?? DateTime.now();
    _selectedEndDate = task?.endDate;
    _selectedDueTime = task?.dueDate != null
        ? TimeOfDay(
            hour: task!.dueDate!.hour, minute: task.dueDate!.minute)
        : null;
    _selectedFrequency = task?.frequency ?? TaskFrequency.once;
    _selectedProgressMode = task?.progressMode ??
        (_selectedFrequency == TaskFrequency.once
            ? TaskProgressMode.individual
            : TaskProgressMode.individual);
    _selectedCustomDays = task?.customDays != null
        ? List<int>.from(task!.customDays)
        : [1, 3, 5];
    _estimatedMinutes = task?.estimatedMinutes ?? 25;
    _progressPercent = task?.getProgressPercentFor(_activeDate) ?? (task?.progressPercent ?? 0);
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
            colorScheme: ColorScheme(
              brightness:
                  AppColors.isDarkMode ? Brightness.dark : Brightness.light,
              primary: AppColors.primary,
              onPrimary: Colors.white,
              secondary: AppColors.accentCyan,
              onSecondary: Colors.black,
              surface: AppColors.surfaceElevated,
              onSurface: AppColors.textPrimary,
              error: AppColors.error,
              onError: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
        _activeDate = picked;
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate ??
          (_selectedDueDate ?? DateTime.now()).add(const Duration(days: 30)),
      firstDate: _selectedDueDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme(
              brightness:
                  AppColors.isDarkMode ? Brightness.dark : Brightness.light,
              primary: AppColors.primary,
              onPrimary: Colors.white,
              secondary: AppColors.accentCyan,
              onSecondary: Colors.black,
              surface: AppColors.surfaceElevated,
              onSurface: AppColors.textPrimary,
              error: AppColors.error,
              onError: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedEndDate = picked;
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
            colorScheme: ColorScheme(
              brightness:
                  AppColors.isDarkMode ? Brightness.dark : Brightness.light,
              primary: AppColors.primary,
              onPrimary: Colors.white,
              secondary: AppColors.accentCyan,
              onSecondary: Colors.black,
              surface: AppColors.surfaceElevated,
              onSurface: AppColors.textPrimary,
              error: AppColors.error,
              onError: Colors.white,
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

  Future<void> _promptExactPercentInput() async {
    final textController =
        TextEditingController(text: _progressPercent.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.r),
          side: BorderSide(color: AppColors.border, width: 1.2),
        ),
        title: Row(
          children: [
            Icon(Icons.edit_note_rounded,
                color: AppColors.accentCyan, size: 22.r),
            SizedBox(width: 8.w),
            Text(
              'Set Progress (0 - 100%)',
              style: AppTypography.heading3.copyWith(fontSize: 16.sp),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter exact progress percentage:',
              style: AppTypography.caption.copyWith(color: AppColors.textMuted),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: textController,
              autofocus: true,
              keyboardType: TextInputType.number,
              style: AppTypography.heading2.copyWith(
                color: AppColors.accentCyan,
                fontWeight: FontWeight.w800,
              ),
              decoration: InputDecoration(
                suffixText: '%',
                suffixStyle: AppTypography.titleMedium.copyWith(
                  color: AppColors.accentCyan,
                  fontWeight: FontWeight.w700,
                ),
                hintText: '0 - 100',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: AppTypography.buttonMedium),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentCyan,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            onPressed: () {
              final parsed = int.tryParse(textController.text.trim());
              if (parsed != null) {
                Navigator.of(ctx).pop(parsed.clamp(0, 100));
              } else {
                Navigator.of(ctx).pop();
              }
            },
            child: Text(
              'Set',
              style: AppTypography.buttonMedium.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() => _progressPercent = result);
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

    final effectiveEndDate =
        _selectedFrequency != TaskFrequency.once ? _selectedEndDate : null;

    final effectiveStatus = _progressPercent >= 100
        ? TaskStatus.completed
        : (_progressPercent > 0
            ? (widget.taskToEdit?.status == TaskStatus.todo || widget.taskToEdit == null
                ? TaskStatus.inProgress
                : widget.taskToEdit!.status)
            : (widget.taskToEdit?.status ?? TaskStatus.todo));

    final dateKey = TaskEntity.formatDateKey(_activeDate);

    if (widget.taskToEdit != null) {
      // Edit existing task
      final existing = widget.taskToEdit!;
      final updatedDailyProgress = Map<String, int>.from(existing.dailyProgress);
      final updatedDailyDescriptions =
          Map<String, String>.from(existing.dailyDescriptions);
      final updatedCompletedDates = List<String>.from(existing.completedDates);

      String baseDescription = existing.description;
      if (_overrideDescriptionForActiveDate &&
          _selectedFrequency != TaskFrequency.once) {
        final text = _descriptionController.text.trim();
        if (text.isNotEmpty) {
          updatedDailyDescriptions[dateKey] = text;
        } else {
          updatedDailyDescriptions.remove(dateKey);
        }
      } else {
        baseDescription = _descriptionController.text.trim();
      }

      int mainProgress = _progressPercent;
      if (_selectedProgressMode == TaskProgressMode.individual &&
          _selectedFrequency != TaskFrequency.once) {
        updatedDailyProgress[dateKey] = _progressPercent;
        if (_progressPercent >= 100) {
          if (!updatedCompletedDates.contains(dateKey)) {
            updatedCompletedDates.add(dateKey);
          }
        } else {
          updatedCompletedDates.remove(dateKey);
        }
        mainProgress = existing.progressPercent;
      }

      final updated = existing.copyWith(
        title: _titleController.text.trim(),
        description: baseDescription,
        categoryId: _selectedCategoryId,
        priority: _selectedPriority,
        status: effectiveStatus,
        dueDate: finalDueDateTime,
        endDate: effectiveEndDate,
        frequency: _selectedFrequency,
        progressMode: _selectedProgressMode,
        customDays: _selectedFrequency == TaskFrequency.customDays
            ? _selectedCustomDays
            : const [],
        completedDates: updatedCompletedDates,
        dailyProgress: updatedDailyProgress,
        dailyDescriptions: updatedDailyDescriptions,
        estimatedMinutes: _estimatedMinutes,
        progressPercent: mainProgress,
        isFocusModeEnabled: _isFocusModeEnabled,
        completedAt: _progressPercent >= 100
            ? (existing.completedAt ?? DateTime.now())
            : null,
      );
      context.read<TaskBloc>().add(UpdateTaskEvent(updated));
    } else {
      // Add new task
      final Map<String, int> initialDailyProgress = {};
      final List<String> initialCompletedDates = [];
      if (_selectedProgressMode == TaskProgressMode.individual &&
          _selectedFrequency != TaskFrequency.once) {
        initialDailyProgress[dateKey] = _progressPercent;
        if (_progressPercent >= 100) {
          initialCompletedDates.add(dateKey);
        }
      }

      final newTask = TaskEntity(
        id: 'task_${const Uuid().v4()}',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        categoryId: _selectedCategoryId,
        priority: _selectedPriority,
        status: effectiveStatus,
        dueDate: finalDueDateTime,
        endDate: effectiveEndDate,
        frequency: _selectedFrequency,
        progressMode: _selectedProgressMode,
        customDays: _selectedFrequency == TaskFrequency.customDays
            ? _selectedCustomDays
            : const [],
        completedDates: initialCompletedDates,
        dailyProgress: initialDailyProgress,
        dailyDescriptions: const {},
        estimatedMinutes: _estimatedMinutes,
        spentMinutes: 0,
        progressPercent: _selectedProgressMode == TaskProgressMode.cumulative ||
                _selectedFrequency == TaskFrequency.once
            ? _progressPercent
            : 0,
        isFocusModeEnabled: _isFocusModeEnabled,
        createdAt: DateTime.now(),
        completedAt: _progressPercent >= 100 ? DateTime.now() : null,
      );
      context.read<TaskBloc>().add(AddTaskEvent(newTask));
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.taskToEdit != null;
    final isRecurring = _selectedFrequency != TaskFrequency.once;
    final formattedActiveDate = DateFormat('EEE, MMM d').format(_activeDate);

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
          TextButton(
            key: const ValueKey('save_task_top_btn'),
            onPressed: _saveTask,
            child: Text(
              'Save',
              style: AppTypography.buttonMedium.copyWith(
                color: AppColors.accentCyan,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SafeArea(
        child: ResponsiveWrapper(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
                    style: AppTypography.bodyLarge
                        .copyWith(color: AppColors.textPrimary),
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

                  // Description Input with Scope Selector for recurring tasks
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Notes & Description',
                          style: AppTypography.titleSmall),
                      if (isEditing && isRecurring)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _overrideDescriptionForActiveDate =
                                  !_overrideDescriptionForActiveDate;
                              if (_overrideDescriptionForActiveDate) {
                                _descriptionController.text =
                                    widget.taskToEdit!.getDescriptionFor(_activeDate);
                              } else {
                                _descriptionController.text =
                                    widget.taskToEdit!.description;
                              }
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: _overrideDescriptionForActiveDate
                                  ? AppColors.accentCyan.withAlpha(40)
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: _overrideDescriptionForActiveDate
                                    ? AppColors.accentCyan
                                    : AppColors.border,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _overrideDescriptionForActiveDate
                                      ? Icons.calendar_today_rounded
                                      : Icons.public_rounded,
                                  size: 12.r,
                                  color: _overrideDescriptionForActiveDate
                                      ? AppColors.accentCyan
                                      : AppColors.textMuted,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  _overrideDescriptionForActiveDate
                                      ? 'For $formattedActiveDate only'
                                      : 'All Days (Default)',
                                  style: AppTypography.captionBold.copyWith(
                                    color: _overrideDescriptionForActiveDate
                                        ? AppColors.accentCyan
                                        : AppColors.textMuted,
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (isEditing && isRecurring && _overrideDescriptionForActiveDate) ...[
                    SizedBox(height: 4.h),
                    Text(
                      'Editing custom notes specifically for $formattedActiveDate. Other days retain default description.',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.accentCyan, fontSize: 10.sp),
                    ),
                  ],
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: _descriptionController,
                    style: AppTypography.bodyLarge
                        .copyWith(color: AppColors.textPrimary),
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: _overrideDescriptionForActiveDate
                          ? 'Add notes specific to $formattedActiveDate...'
                          : 'Add details, subtasks, or objectives...',
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
                              Row(
                                children: [
                                  GestureDetector(
                                    key: const ValueKey('add_task_manage_categories_btn'),
                                    onTap: () => ManageCategoriesSheet.show(context),
                                    child: Text(
                                      'Manage',
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.textMuted,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
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
                                      '+ Add',
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.accentCyan,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
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
                                  onLongPress: () => ManageCategoriesSheet.show(context),
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
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 3.w),
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? priority.color.withAlpha(40)
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: isSelected
                                    ? priority.color
                                    : AppColors.border,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                priority.label,
                                style: AppTypography.badge.copyWith(
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

                  SizedBox(height: 24.h),

                  // Due Date & Time Section
                  Row(
                    children: [
                      // Due Date Picker
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Due Date', style: AppTypography.titleSmall),
                            SizedBox(height: 8.h),
                            GestureDetector(
                              key: const ValueKey('pick_due_date_btn'),
                              onTap: _pickDate,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.w, vertical: 12.h),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                      color: AppColors.border, width: 1),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today_rounded,
                                        size: 16.r,
                                        color: AppColors.accentCyan),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: Text(
                                        _selectedDueDate != null
                                            ? DateFormat('EEE, MMM d')
                                                .format(_selectedDueDate!)
                                            : 'Select Date',
                                        style:
                                            AppTypography.bodyMedium.copyWith(
                                          color: _selectedDueDate != null
                                              ? Colors.white
                                              : AppColors.textMuted,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // Due Time Picker
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Time (Optional)',
                                style: AppTypography.titleSmall),
                            SizedBox(height: 8.h),
                            GestureDetector(
                              key: const ValueKey('pick_due_time_btn'),
                              onTap: _pickTime,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.w, vertical: 12.h),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                      color: AppColors.border, width: 1),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.access_time_rounded,
                                        size: 16.r,
                                        color: AppColors.accentCyan),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: Text(
                                        _selectedDueTime != null
                                            ? _selectedDueTime!.format(context)
                                            : 'Optional Time',
                                        style:
                                            AppTypography.bodyMedium.copyWith(
                                          color: _selectedDueTime != null
                                              ? Colors.white
                                              : AppColors.textMuted,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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

                  // End Date picker for recurring tasks (Daily, Weekly, Custom Days)
                  if (_selectedFrequency != TaskFrequency.once) ...[
                    SizedBox(height: 14.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.event_repeat_rounded,
                              size: 20.r, color: AppColors.accentCyan),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'End Date (Optional)',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  _selectedEndDate != null
                                      ? DateFormat('EEE, MMM d, yyyy')
                                          .format(_selectedEndDate!)
                                      : 'Ongoing (Repeat indefinitely)',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: _selectedEndDate != null
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_selectedEndDate != null)
                            IconButton(
                              icon: Icon(Icons.clear_rounded,
                                  size: 18.r, color: AppColors.textMuted),
                              visualDensity: VisualDensity.compact,
                              onPressed: () =>
                                  setState(() => _selectedEndDate = null),
                            ),
                          TextButton(
                            key: const ValueKey('pick_end_date_btn'),
                            onPressed: _pickEndDate,
                            child: Text(
                              _selectedEndDate != null ? 'Change' : 'Set End Date',
                              style: AppTypography.buttonMedium.copyWith(
                                color: AppColors.accentCyan,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Progress Tracking Mode (Individual vs Cumulative)
                  if (_selectedFrequency != TaskFrequency.once) ...[
                    SizedBox(height: 24.h),
                    Text('Progress Tracking Mode',
                        style: AppTypography.titleSmall),
                    SizedBox(height: 4.h),
                    Text(
                      'Choose how progress resets across repeated days:',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.textMuted),
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        // Individual Option
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedProgressMode =
                                TaskProgressMode.individual),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: EdgeInsets.all(12.r),
                              decoration: BoxDecoration(
                                color: _selectedProgressMode ==
                                        TaskProgressMode.individual
                                    ? AppColors.accentCyan.withAlpha(30)
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(
                                  color: _selectedProgressMode ==
                                          TaskProgressMode.individual
                                      ? AppColors.accentCyan
                                      : AppColors.border,
                                  width: _selectedProgressMode ==
                                          TaskProgressMode.individual
                                      ? 1.5
                                      : 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.replay_rounded,
                                        size: 18.r,
                                        color: _selectedProgressMode ==
                                                TaskProgressMode.individual
                                            ? AppColors.accentCyan
                                            : AppColors.textSecondary,
                                      ),
                                      SizedBox(width: 6.w),
                                      Expanded(
                                        child: Text(
                                          'Individual / Daily',
                                          style: AppTypography.titleSmall.copyWith(
                                            color: _selectedProgressMode ==
                                                    TaskProgressMode.individual
                                                ? Colors.white
                                                : AppColors.textPrimary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13.sp,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    'Each day starts fresh (0-100%). Best for daily habits.',
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 10.sp,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        // Cumulative Option
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedProgressMode =
                                TaskProgressMode.cumulative),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: EdgeInsets.all(12.r),
                              decoration: BoxDecoration(
                                color: _selectedProgressMode ==
                                        TaskProgressMode.cumulative
                                    ? AppColors.primary.withAlpha(30)
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(
                                  color: _selectedProgressMode ==
                                          TaskProgressMode.cumulative
                                      ? AppColors.primaryLight
                                      : AppColors.border,
                                  width: _selectedProgressMode ==
                                          TaskProgressMode.cumulative
                                      ? 1.5
                                      : 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.trending_up_rounded,
                                        size: 18.r,
                                        color: _selectedProgressMode ==
                                                TaskProgressMode.cumulative
                                            ? AppColors.primaryLight
                                            : AppColors.textSecondary,
                                      ),
                                      SizedBox(width: 6.w),
                                      Expanded(
                                        child: Text(
                                          'Cumulative',
                                          style: AppTypography.titleSmall.copyWith(
                                            color: _selectedProgressMode ==
                                                    TaskProgressMode.cumulative
                                                ? Colors.white
                                                : AppColors.textPrimary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13.sp,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    'Progress carries over across days towards overall completion.',
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 10.sp,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
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
                                        Text('Integrate session tracking',
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

                  SizedBox(height: 24.h),

                  // Task Completion Percentage Slider Card
                  GlassmorphicCard(
                    padding: EdgeInsets.all(16.r),
                    borderColor: AppColors.border,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.trending_up_rounded,
                                      size: 20.r, color: AppColors.accentCyan),
                                  SizedBox(width: 8.w),
                                  Flexible(
                                    child: Text(
                                      'Task Progress',
                                      style: AppTypography.titleMedium.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8.w),
                            GestureDetector(
                              onTap: _promptExactPercentInput,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: (_progressPercent >= 100
                                          ? AppColors.success
                                          : AppColors.accentCyan)
                                      .withAlpha(40),
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: (_progressPercent >= 100
                                            ? AppColors.success
                                            : AppColors.accentCyan)
                                        .withAlpha(120),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '$_progressPercent%',
                                      style: AppTypography.titleSmall.copyWith(
                                        color: _progressPercent >= 100
                                            ? AppColors.success
                                            : AppColors.accentCyan,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Icon(
                                      Icons.edit_rounded,
                                      size: 12.r,
                                      color: _progressPercent >= 100
                                          ? AppColors.success
                                          : AppColors.accentCyan,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),

                        // Fine-tune +/- controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: Icon(Icons.remove_circle_outline_rounded,
                                  size: 20.r, color: AppColors.textMuted),
                              tooltip: '-1%',
                              onPressed: _progressPercent > 0
                                  ? () => setState(() => _progressPercent--)
                                  : null,
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: Icon(Icons.add_circle_outline_rounded,
                                  size: 20.r, color: AppColors.accentCyan),
                              tooltip: '+1%',
                              onPressed: _progressPercent < 100
                                  ? () => setState(() => _progressPercent++)
                                  : null,
                            ),
                          ],
                        ),

                        // Smooth Continuous / Integer Slider (0 - 100%)
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: _progressPercent >= 100
                                ? AppColors.success
                                : AppColors.accentCyan,
                            inactiveTrackColor: AppColors.surfaceElevated,
                            thumbColor: _progressPercent >= 100
                                ? AppColors.success
                                : AppColors.accentCyan,
                            trackHeight: 5.h,
                          ),
                          child: Slider(
                            value: _progressPercent.clamp(0, 100).toDouble(),
                            min: 0,
                            max: 100,
                            divisions: 100,
                            onChanged: (val) {
                              setState(() => _progressPercent = val.round());
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [0, 25, 50, 75, 100].map((pct) {
                            final isSel = _progressPercent == pct;
                            return GestureDetector(
                              onTap: () => setState(() => _progressPercent = pct),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? AppColors.accentCyan.withAlpha(40)
                                      : AppColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: isSel
                                        ? AppColors.accentCyan
                                        : AppColors.border,
                                  ),
                                ),
                                child: Text(
                                  '$pct%',
                                  style: AppTypography.captionBold.copyWith(
                                    color: isSel
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
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
