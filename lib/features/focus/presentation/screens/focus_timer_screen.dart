import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/app_icon_helper.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../../../core/widgets/glow_container.dart';
import '../../../../core/widgets/responsive_wrapper.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/domain/entities/task_enums.dart';
import '../../../tasks/presentation/bloc/task_bloc.dart';
import '../../../tasks/presentation/bloc/task_event.dart';
import '../../../tasks/presentation/bloc/task_state.dart';
import '../../domain/models/pomodoro_enums.dart';
import '../bloc/focus_bloc.dart';
import '../bloc/focus_event.dart';
import '../bloc/focus_state.dart';
import 'fullscreen_timer_screen.dart';

/// Main Normal View Focus Timer Screen
class FocusTimerScreen extends StatefulWidget {
  final TaskEntity? initialTask;

  const FocusTimerScreen({
    super.key,
    this.initialTask,
  });

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen> {
  final List<int> _quickPresets = const [15, 25, 45, 60];

  @override
  void initState() {
    super.initState();
    if (widget.initialTask != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<FocusBloc>().add(
              SetActiveTaskEvent(widget.initialTask),
            );
      });
    }
  }

  void _openTaskSelectorBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            final tasks = state is TaskLoaded
                ? state.allTasks.where((t) => !t.isCompleted).toList()
                : <TaskEntity>[];

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Select Task to Focus',
                          style: AppTypography.heading3),
                      IconButton(
                        icon: Icon(Icons.close_rounded,
                            size: 20.r, color: AppColors.textSecondary),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  if (tasks.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.h),
                      child: Center(
                        child: Text(
                          'No pending tasks available.\nCreate one from Home dashboard!',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmall,
                        ),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: tasks.length,
                        separatorBuilder: (context, index) => SizedBox(height: 8.h),
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return ListTile(
                            tileColor: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              side: BorderSide(
                                  color: AppColors.border, width: 0.8),
                            ),
                            title: Text(task.title,
                                style: AppTypography.titleSmall
                                    .copyWith(color: AppColors.textPrimary)),
                            subtitle: Text(
                              '${task.estimatedMinutes} min estimated • ${task.priority.label} priority',
                              style: AppTypography.caption,
                            ),
                            trailing: Icon(Icons.play_circle_filled_rounded,
                                color: AppColors.accentCyan, size: 24.r),
                            onTap: () {
                              context
                                  .read<FocusBloc>()
                                  .add(SetActiveTaskEvent(task));
                              Navigator.of(ctx).pop();
                            },
                          );
                        },
                      ),
                    ),
                  SizedBox(height: 10.h),
                  // Clear active task option
                  ListTile(
                    tileColor: AppColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      side: BorderSide(color: AppColors.border),
                    ),
                    leading: Icon(Icons.close_rounded,
                        color: AppColors.textMuted),
                    title: Text('Continue without specific task',
                        style: AppTypography.bodyMedium),
                    onTap: () {
                      context
                          .read<FocusBloc>()
                          .add(const SetActiveTaskEvent(null));
                      Navigator.of(ctx).pop();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showTaskProgressSheet(BuildContext context, TaskEntity task) async {
    final today = DateTime.now();
    int currentSpent = task.getSpentMinutesFor(today);
    int currentEstimated = task.estimatedMinutes;
    TaskStatus currentStatus = task.status;
    int currentPercent = task.getProgressPercentFor(today);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setSheetState) {
            final isDone = currentStatus == TaskStatus.completed || currentPercent >= 100;

            Future<void> promptPercentDialog() async {
              final textController =
                  TextEditingController(text: currentPercent.toString());
              final result = await showDialog<int>(
                context: dialogCtx,
                builder: (numCtx) => AlertDialog(
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
                        style: AppTypography.caption
                            .copyWith(color: AppColors.textMuted),
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
                      onPressed: () => Navigator.of(numCtx).pop(),
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
                          Navigator.of(numCtx).pop(parsed.clamp(0, 100));
                        } else {
                          Navigator.of(numCtx).pop();
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
                setSheetState(() {
                  currentPercent = result;
                  if (result >= 100) {
                    currentStatus = TaskStatus.completed;
                  } else if (result > 0 && currentStatus == TaskStatus.todo) {
                    currentStatus = TaskStatus.inProgress;
                  } else if (result == 0) {
                    currentStatus = TaskStatus.todo;
                  }
                });
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 20.h,
                bottom: MediaQuery.of(dialogCtx).viewInsets.bottom + 24.h,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: AppColors.borderLight,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Header
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: AppColors.accentCyan.withAlpha(35),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.trending_up_rounded,
                            color: AppColors.accentCyan,
                            size: 22.r,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Update Task Progress',
                                style: AppTypography.heading3.copyWith(fontSize: 17.sp),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                task.title,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close_rounded,
                              size: 20.r, color: AppColors.textMuted),
                          onPressed: () => Navigator.of(dialogCtx).pop(),
                        ),
                      ],
                    ),

                    SizedBox(height: 18.h),

                    // Percentage Section Header & Display
                    Container(
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: isDone
                              ? AppColors.success.withAlpha(120)
                              : AppColors.accentCyan.withAlpha(80),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'COMPLETION PERCENTAGE',
                                style: AppTypography.captionBold.copyWith(
                                  color: AppColors.textSecondary,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              GestureDetector(
                                onTap: promptPercentDialog,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 3.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (isDone ? AppColors.success : AppColors.accentCyan)
                                        .withAlpha(40),
                                    borderRadius: BorderRadius.circular(10.r),
                                    border: Border.all(
                                      color: (isDone
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
                                        '$currentPercent%',
                                        style: AppTypography.titleSmall.copyWith(
                                          color: isDone
                                              ? AppColors.success
                                              : AppColors.accentCyan,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15.sp,
                                        ),
                                      ),
                                      SizedBox(width: 4.w),
                                      Icon(
                                        Icons.edit_rounded,
                                        size: 12.r,
                                        color: isDone
                                            ? AppColors.success
                                            : AppColors.accentCyan,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),

                          // Fine tune +/- 1% buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                icon: Icon(
                                  Icons.remove_circle_outline_rounded,
                                  size: 20.r,
                                  color: AppColors.textMuted,
                                ),
                                tooltip: '-1%',
                                onPressed: currentPercent > 0
                                    ? () {
                                        setSheetState(() {
                                          currentPercent--;
                                          if (currentPercent == 0) {
                                            currentStatus = TaskStatus.todo;
                                          }
                                        });
                                      }
                                    : null,
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                icon: Icon(
                                  Icons.add_circle_outline_rounded,
                                  size: 20.r,
                                  color: AppColors.accentCyan,
                                ),
                                tooltip: '+1%',
                                onPressed: currentPercent < 100
                                    ? () {
                                        setSheetState(() {
                                          currentPercent++;
                                          if (currentPercent >= 100) {
                                            currentStatus = TaskStatus.completed;
                                          } else if (currentStatus == TaskStatus.todo) {
                                            currentStatus = TaskStatus.inProgress;
                                          }
                                        });
                                      }
                                    : null,
                              ),
                            ],
                          ),

                          // Slider to interactively adjust percentage (1% precision)
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor:
                                  isDone ? AppColors.success : AppColors.accentCyan,
                              inactiveTrackColor: AppColors.surfaceElevated,
                              thumbColor: isDone ? AppColors.success : AppColors.accentCyan,
                              overlayColor: (isDone
                                      ? AppColors.success
                                      : AppColors.accentCyan)
                                  .withAlpha(40),
                              trackHeight: 6.h,
                            ),
                            child: Slider(
                              value: currentPercent.clamp(0, 100).toDouble(),
                              min: 0,
                              max: 100,
                              divisions: 100,
                              onChanged: (val) {
                                final newVal = val.round();
                                setSheetState(() {
                                  currentPercent = newVal;
                                  if (newVal >= 100) {
                                    currentStatus = TaskStatus.completed;
                                  } else if (newVal > 0 && currentStatus == TaskStatus.todo) {
                                    currentStatus = TaskStatus.inProgress;
                                  } else if (newVal == 0) {
                                    currentStatus = TaskStatus.todo;
                                  }
                                });
                              },
                            ),
                          ),

                          // Quick % Jump Chips
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [0, 25, 50, 75, 100].map((pct) {
                              final isSelected = currentPercent == pct;
                              return GestureDetector(
                                onTap: () {
                                  setSheetState(() {
                                    currentPercent = pct;
                                    if (pct >= 100) {
                                      currentStatus = TaskStatus.completed;
                                    } else if (pct > 0 && currentStatus == TaskStatus.todo) {
                                      currentStatus = TaskStatus.inProgress;
                                    } else if (pct == 0) {
                                      currentStatus = TaskStatus.todo;
                                    }
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? (pct == 100
                                                ? AppColors.success
                                                : AppColors.accentCyan)
                                            .withAlpha(50)
                                        : AppColors.surfaceElevated,
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(
                                      color: isSelected
                                          ? (pct == 100
                                              ? AppColors.success
                                              : AppColors.accentCyan)
                                          : AppColors.border,
                                      width: isSelected ? 1.5 : 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    '$pct%',
                                    style: AppTypography.captionBold.copyWith(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                      fontSize: 11.sp,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 18.h),

                    // Status Selector Row
                    Text(
                      'STATUS',
                      style: AppTypography.captionBold.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        TaskStatus.todo,
                        TaskStatus.inProgress,
                        TaskStatus.completed,
                      ].map((status) {
                        final isSelected = currentStatus == status;
                        Color statusColor;
                        switch (status) {
                          case TaskStatus.completed:
                            statusColor = AppColors.success;
                            break;
                          case TaskStatus.inProgress:
                            statusColor = AppColors.accentCyan;
                            break;
                          case TaskStatus.todo:
                          default:
                            statusColor = AppColors.textSecondary;
                            break;
                        }

                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setSheetState(() {
                                currentStatus = status;
                                if (status == TaskStatus.completed) {
                                  currentPercent = 100;
                                } else if (status == TaskStatus.todo && currentPercent == 100) {
                                  currentPercent = 0;
                                }
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 4.w),
                              padding: EdgeInsets.symmetric(vertical: 9.h),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? statusColor.withAlpha(40)
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: isSelected ? statusColor : AppColors.border,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  status.label,
                                  style: AppTypography.badge.copyWith(
                                    color: isSelected ? Colors.white : AppColors.textMuted,
                                    fontWeight:
                                        isSelected ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    SizedBox(height: 18.h),

                    // Spent Minutes Adjuster
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TIME SPENT',
                              style: AppTypography.captionBold.copyWith(
                                color: AppColors.textSecondary,
                                letterSpacing: 0.8,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '$currentSpent minutes logged',
                              style: AppTypography.titleSmall.copyWith(
                                color: AppColors.accentCyan,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  side: BorderSide(color: AppColors.border),
                                ),
                              ),
                              icon: Icon(Icons.remove_rounded,
                                  size: 18.r, color: AppColors.textPrimary),
                              onPressed: currentSpent >= 5
                                  ? () {
                                      setSheetState(() {
                                        currentSpent -= 5;
                                      });
                                    }
                                  : null,
                            ),
                            SizedBox(width: 8.w),
                            IconButton(
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                              icon: Icon(Icons.add_rounded,
                                  size: 18.r, color: AppColors.textPrimary),
                              onPressed: () {
                                setSheetState(() {
                                  currentSpent += 5;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 14.h),

                    // Estimated Minutes Adjuster
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ESTIMATED TARGET',
                              style: AppTypography.captionBold.copyWith(
                                color: AppColors.textSecondary,
                                letterSpacing: 0.8,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '$currentEstimated minutes total',
                              style: AppTypography.titleSmall.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  side: BorderSide(color: AppColors.border),
                                ),
                              ),
                              icon: Icon(Icons.remove_rounded,
                                  size: 18.r, color: AppColors.textPrimary),
                              onPressed: currentEstimated >= 10
                                  ? () {
                                      setSheetState(() {
                                        currentEstimated -= 5;
                                      });
                                    }
                                  : null,
                            ),
                            SizedBox(width: 8.w),
                            IconButton(
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                              icon: Icon(Icons.add_rounded,
                                  size: 18.r, color: AppColors.textPrimary),
                              onPressed: () {
                                setSheetState(() {
                                  currentEstimated += 5;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // Save & Update Progress Button
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                           backgroundColor: AppColors.accentCyan,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          final dateKey = TaskEntity.formatDateKey(today);
                          final updatedDailyProgress =
                              Map<String, int>.from(task.dailyProgress);
                          final updatedDailySpent =
                              Map<String, int>.from(task.dailySpentMinutes);
                          final updatedCompletedDates =
                              List<String>.from(task.completedDates);

                          if (task.progressMode == TaskProgressMode.individual &&
                              task.frequency != TaskFrequency.once) {
                            updatedDailyProgress[dateKey] = currentPercent;
                            updatedDailySpent[dateKey] = currentSpent;
                            if (isDone) {
                              if (!updatedCompletedDates.contains(dateKey)) {
                                updatedCompletedDates.add(dateKey);
                              }
                            } else {
                              updatedCompletedDates.remove(dateKey);
                            }
                          }

                          final updatedTask = task.copyWith(
                            status: currentStatus,
                            spentMinutes: task.progressMode ==
                                        TaskProgressMode.cumulative ||
                                    task.frequency == TaskFrequency.once
                                ? currentSpent
                                : task.spentMinutes,
                            estimatedMinutes: currentEstimated,
                            progressPercent: task.progressMode ==
                                        TaskProgressMode.cumulative ||
                                    task.frequency == TaskFrequency.once
                                ? currentPercent
                                : task.progressPercent,
                            dailyProgress: updatedDailyProgress,
                            dailySpentMinutes: updatedDailySpent,
                            completedDates: updatedCompletedDates,
                            completedAt: isDone
                                ? (task.completedAt ?? DateTime.now())
                                : null,
                          );

                          // 1. Update in TaskBloc
                          context.read<TaskBloc>().add(UpdateTaskEvent(updatedTask));

                          // 2. Keep FocusBloc synced with updated task
                          context.read<FocusBloc>().add(SetActiveTaskEvent(updatedTask));

                          Navigator.of(dialogCtx).pop();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isDone
                                    ? '🎉 Great job! "${task.title}" marked completed ($currentPercent%).'
                                    : 'Progress updated to $currentPercent% for "${task.title}".',
                              ),
                              backgroundColor: isDone ? AppColors.success : AppColors.surfaceElevated,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Text(
                          'Save Progress',
                          style: AppTypography.buttonMedium.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openFullscreenMode() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const FullscreenTimerScreen(),
      ),
    );
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('Focus Timer', style: AppTypography.heading3),
        actions: [
          IconButton(
            icon: Icon(Icons.fullscreen_rounded,
                size: 24.r, color: AppColors.accentCyan),
            tooltip: 'Immersive Fullscreen Mode',
            onPressed: _openFullscreenMode,
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SafeArea(
        child: ResponsiveWrapper(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 6.h),
          child: BlocConsumer<FocusBloc, FocusState>(
            listenWhen: (previous, current) =>
                previous.status != current.status &&
                current.status == TimerStatus.completed,
            listener: (context, state) {
              if (state.activeTask != null) {
                // Prompt user to update task progress after every completed session
                _showTaskProgressSheet(context, state.activeTask!);
              }
            },
            builder: (context, state) {
              final modeColor = state.mode.color;
              final isRunning = state.isRunning;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Mode Selector Tabs (Deep Focus / Short Break / Long Break)
                    Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: Row(
                        children: PomodoroMode.values.map((mode) {
                          final isSelected = state.mode == mode;
                          return Expanded(
                            child: GestureDetector(
                              key: ValueKey('mode_tab_${mode.name}'),
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                context.read<FocusBloc>().add(
                                      SwitchPomodoroModeEvent(mode: mode),
                                    );
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? mode.color
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12.r),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: mode.color.withAlpha(100),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 4.w),
                                    child: Text(
                                      mode.label,
                                      style:
                                          AppTypography.buttonMedium.copyWith(
                                        color: isSelected
                                            ? AppColors.background
                                            : AppColors.textSecondary,
                                        fontWeight: isSelected
                                            ? FontWeight.w800
                                            : FontWeight.w500,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    SizedBox(height: 18.h),

                    // Active Task Linked Card
                    BlocBuilder<TaskBloc, TaskState>(
                      builder: (context, taskState) {
                        final task = state.activeTask;
                        final category = (task != null &&
                                taskState is TaskLoaded)
                            ? taskState.getCategoryById(task.categoryId)
                            : null;

                        return GestureDetector(
                          onTap: () => _openTaskSelectorBottomSheet(context),
                          child: GlassmorphicCard(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 12.h),
                            borderColor: task != null
                                ? AppColors.accentCyan.withAlpha(90)
                                : AppColors.border,
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8.r),
                                  decoration: BoxDecoration(
                                    color: task != null
                                        ? AppColors.accentCyan.withAlpha(30)
                                        : AppColors.surfaceElevated,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    task != null
                                        ? (category != null
                                            ? AppIconHelper.getCategoryIcon(
                                                category.iconCode)
                                            : Icons.task_alt_rounded)
                                        : Icons.link_rounded,
                                    size: 18.r,
                                    color: task != null
                                        ? AppColors.accentCyan
                                        : AppColors.textMuted,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        task != null
                                            ? task.title
                                            : 'Free Focus Session',
                                        style: AppTypography.titleSmall
                                            .copyWith(color: AppColors.textPrimary),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        task != null
                                            ? '${(task.progressPercentage * 100).round()}% completed • ${task.spentMinutes}m / ${task.estimatedMinutes}m'
                                            : 'Tap to link a task from your list',
                                        style: AppTypography.caption,
                                      ),
                                    ],
                                  ),
                                ),
                                 if (task != null) ...[
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => _showTaskProgressSheet(context, task),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 5.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentCyan.withAlpha(30),
                                        borderRadius: BorderRadius.circular(8.r),
                                        border: Border.all(
                                          color: AppColors.accentCyan.withAlpha(90),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.edit_note_rounded,
                                            size: 14.r,
                                            color: AppColors.accentCyan,
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            'Progress',
                                            style: AppTypography.captionBold.copyWith(
                                              color: AppColors.accentCyan,
                                              fontSize: 10.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ] else
                                  Icon(Icons.arrow_forward_ios_rounded,
                                      size: 14.r, color: AppColors.textMuted),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 28.h),

                    // Central Glowing Countdown Progress Gauge
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Ambient Pulsing Glow
                        GlowContainer(
                          isCircle: true,
                          glowColor: isRunning ? modeColor : Colors.transparent,
                          blurRadius: isRunning ? 28 : 0,
                          spreadRadius: 2,
                          backgroundColor: Colors.transparent,
                          child: SizedBox(
                            width: 230.r,
                            height: 230.r,
                            child: CircularProgressIndicator(
                              value: state.progress,
                              strokeWidth: 9.r,
                              backgroundColor: AppColors.surfaceElevated,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(modeColor),
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                        ),

                        // Time Display & Status
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              state.formattedTime,
                              style: AppTypography.timerDisplay(
                                fontSize: 52,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 3.h),
                              decoration: AppDecorations.badge(
                                color: modeColor,
                                borderRadius: 12.r,
                              ),
                              child: Text(
                                state.isRunning
                                    ? 'RUNNING'
                                    : state.isPaused
                                        ? 'PAUSED'
                                        : 'READY',
                                style: AppTypography.badge.copyWith(
                                  color: modeColor,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // Cycle Indicator Row (Cycle 1 of 4)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Cycle ${(state.completedCycles % 4) + 1} of 4',
                          style: AppTypography.titleSmall.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Row(
                          children: List.generate(4, (index) {
                            final currentCycleMod = state.completedCycles % 4;
                            final isFilled = index < currentCycleMod;
                            final isCurrent =
                                index == currentCycleMod && isRunning;

                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 4.w),
                              width: isCurrent ? 20.w : 8.w,
                              height: 8.h,
                              decoration: BoxDecoration(
                                color: isFilled || isCurrent
                                    ? modeColor
                                    : AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // Quick Duration Presets
                    if (!isRunning && !state.isPaused) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _quickPresets.map((mins) {
                          final isSelected =
                              state.totalSeconds == mins * 60;
                          return GestureDetector(
                            onTap: () {
                              context.read<FocusBloc>().add(
                                    SwitchPomodoroModeEvent(
                                      mode: state.mode,
                                      customDurationMinutes: mins,
                                    ),
                                  );
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 4.w),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14.w, vertical: 7.h),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? modeColor.withAlpha(40)
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: isSelected
                                      ? modeColor
                                      : AppColors.border,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Text(
                                '${mins}m',
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
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 24.h),
                    ],

                    // Action Controls: Reset, Big Primary Action, Skip
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Reset Button
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.replay_rounded,
                                size: 22.r, color: AppColors.textSecondary),
                            onPressed: () {
                              context
                                  .read<FocusBloc>()
                                  .add(const ResetFocusSessionEvent());
                            },
                          ),
                        ),

                        // Main Glowing Action Button
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            if (state.isRunning) {
                              context
                                  .read<FocusBloc>()
                                  .add(const PauseFocusSessionEvent());
                            } else if (state.isPaused) {
                              context
                                  .read<FocusBloc>()
                                  .add(const ResumeFocusSessionEvent());
                            } else {
                              context
                                  .read<FocusBloc>()
                                  .add(const StartFocusSessionEvent());
                            }
                          },
                          child: Container(
                            width: 160.w,
                            height: 52.h,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  modeColor,
                                  modeColor.withAlpha(190),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(26.r),
                              boxShadow: [
                                BoxShadow(
                                  color: modeColor.withAlpha(140),
                                  blurRadius: 18,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  state.isRunning
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  size: 24.r,
                                  color: AppColors.background,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  state.isRunning
                                      ? 'PAUSE'
                                      : state.isPaused
                                          ? 'RESUME'
                                          : 'START',
                                  style: AppTypography.buttonLarge.copyWith(
                                    color: AppColors.background,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Skip Phase Button
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.skip_next_rounded,
                                size: 24.r, color: AppColors.textSecondary),
                            onPressed: () {
                              context
                                  .read<FocusBloc>()
                                  .add(const SkipPhaseEvent());
                            },
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
