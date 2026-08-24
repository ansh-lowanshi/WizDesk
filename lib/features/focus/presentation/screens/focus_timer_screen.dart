import 'package:flutter/material.dart';
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
import '../../../tasks/presentation/bloc/task_bloc.dart';
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
              StartFocusSessionEvent(
                task: widget.initialTask,
                customDurationMinutes: widget.initialTask!.estimatedMinutes,
              ),
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
                              side: const BorderSide(
                                  color: AppColors.border, width: 0.8),
                            ),
                            title: Text(task.title,
                                style: AppTypography.titleSmall
                                    .copyWith(color: Colors.white)),
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
                      side: const BorderSide(color: AppColors.border),
                    ),
                    leading: const Icon(Icons.close_rounded,
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

  void _openFullscreenMode() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const FullscreenTimerScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          child: BlocBuilder<FocusBloc, FocusState>(
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
                                            .copyWith(color: Colors.white),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        task != null
                                            ? 'Logged: ${task.spentMinutes}m / ${task.estimatedMinutes}m'
                                            : 'Tap to link a task from your list',
                                        style: AppTypography.caption,
                                      ),
                                    ],
                                  ),
                                ),
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
                                color: Colors.white,
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
