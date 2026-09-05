import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../core/widgets/responsive_wrapper.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_enums.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../../../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../../../features/focus/presentation/screens/focus_timer_screen.dart';
import '../../../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../../../features/settings/presentation/bloc/settings_state.dart';
import '../widgets/category_filter_carousel.dart';
import '../widgets/daily_progress_banner.dart';
import '../widgets/status_filter_tabs.dart';
import '../widgets/task_card.dart';
import '../widgets/task_empty_state.dart';
import '../widgets/task_search_bar.dart';
import 'add_edit_task_screen.dart';

/// Main Home Dashboard Screen for Wiz Desk
class HomeDashboardScreen extends StatefulWidget {
  final VoidCallback? onNavigateToAddTask;
  final ValueChanged<TaskEntity>? onStartTaskFocus;

  const HomeDashboardScreen({
    super.key,
    this.onNavigateToAddTask,
    this.onStartTaskFocus,
  });

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  bool _isSearchOpen = false;

  @override
  void initState() {
    super.initState();
    // Load initial tasks & categories
    final taskBloc = context.read<TaskBloc>();
    if (taskBloc.state is! TaskLoaded) {
      taskBloc.add(const LoadTasksEvent());
    }
  }

  void _openAddTaskScreen() {
    if (widget.onNavigateToAddTask != null) {
      widget.onNavigateToAddTask!();
      return;
    }
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AddEditTaskScreen()));
  }

  void _openEditTaskScreen(TaskEntity task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditTaskScreen(
          taskToEdit: task,
          initialDate: DateTime.now(),
        ),
      ),
    );
  }

  void _openFocusTimerScreen([TaskEntity? task]) {
    if (task != null && widget.onStartTaskFocus != null) {
      widget.onStartTaskFocus!(task);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => FocusTimerScreen(initialTask: task)),
    );
  }

  void _openAnalyticsScreen() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AnalyticsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveWrapper(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: BlocConsumer<TaskBloc, TaskState>(
            listener: (context, state) {
              if (state is TaskError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is TaskInitial || state is TaskLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.accentCyan),
                );
              }

              if (state is TaskLoaded) {
                return RefreshIndicator(
                  color: AppColors.accentCyan,
                  backgroundColor: AppColors.surfaceElevated,
                  onRefresh: () async {
                    context.read<TaskBloc>().add(const LoadTasksEvent());
                  },
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      // Sliver Header
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8.h),

                            // Top Profile / Greeting Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      BlocBuilder<SettingsBloc, SettingsState>(
                                        builder: (context, settingsState) {
                                          final name =
                                              settingsState is SettingsLoaded
                                              ? settingsState
                                                    .preferences
                                                    .userName
                                              : 'Creator';
                                          return Text(
                                            'Good Day, $name 👋',
                                            style: AppTypography.heading2,
                                            overflow: TextOverflow.ellipsis,
                                          );
                                        },
                                      ),
                                      SizedBox(height: 3.h),
                                      Text(
                                        DateTimeFormatter.formatHeaderDate(now),
                                        style: AppTypography.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    // IconButton(
                                    //   icon: Icon(
                                    //     Icons.insights_rounded,
                                    //     color: AppColors.accentCyan,
                                    //     size: 22.r,
                                    //   ),
                                    //   tooltip: 'Productivity Analytics',
                                    //   onPressed: _openAnalyticsScreen,
                                    // ),
                                    // IconButton(
                                    //   icon: Icon(
                                    //     Icons.timer_outlined,
                                    //     color: AppColors.accentCyan,
                                    //     size: 22.r,
                                    //   ),
                                    //   tooltip: 'Focus Timer',
                                    //   onPressed: () => _openFocusTimerScreen(),
                                    // ),
                                    IconButton(
                                      icon: Icon(
                                        _isSearchOpen
                                            ? Icons.close_rounded
                                            : Icons.search_rounded,
                                        color: _isSearchOpen
                                            ? AppColors.accentCyan
                                            : AppColors.textPrimary,
                                        size: 22.r,
                                      ),
                                      tooltip: 'Search Tasks',
                                      onPressed: () {
                                        setState(() {
                                          _isSearchOpen = !_isSearchOpen;
                                        });
                                        if (!_isSearchOpen) {
                                          context.read<TaskBloc>().add(
                                            const SearchTasksEvent(''),
                                          );
                                        }
                                      },
                                    ),
                                    SizedBox(width: 4.w),
                                    IconButton(
                                      key: const ValueKey(
                                        'today_add_task_header_btn',
                                      ),
                                      icon: Container(
                                        padding: EdgeInsets.all(6.r),
                                        decoration: BoxDecoration(
                                          gradient: AppColors.primaryGradient,
                                          borderRadius: BorderRadius.circular(
                                            10.r,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primary
                                                  .withAlpha(120),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.add_rounded,
                                          color: Colors.white,
                                          size: 18.r,
                                        ),
                                      ),
                                      tooltip: 'Add Task',
                                      onPressed: _openAddTaskScreen,
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            SizedBox(height: 16.h),

                            // Collapsible Search Bar
                            if (_isSearchOpen) ...[
                              TaskSearchBar(
                                onSearchChanged: (query) {
                                  context.read<TaskBloc>().add(
                                    SearchTasksEvent(query),
                                  );
                                },
                              ),
                              SizedBox(height: 16.h),
                            ],

                            // Daily Progress Banner
                            DailyProgressBanner(
                              completedTasks:
                                  state.dateFilter == TaskDateFilter.today
                                      ? state.todayCompletedTasksCount
                                      : state.completedTasksCount,
                              totalTasks:
                                  state.dateFilter == TaskDateFilter.today
                                      ? state.todayTasksCount
                                      : state.totalTasksCount,
                              totalFocusMinutes:
                                  state.dateFilter == TaskDateFilter.today
                                      ? state.todayFocusMinutes
                                      : state.allTasks.fold<int>(
                                          0,
                                          (sum, t) => sum + t.spentMinutes,
                                        ),
                              onBannerTap: _openAnalyticsScreen,
                            ),

                            SizedBox(height: 20.h),

                            // Category Filter Carousel
                            Builder(
                              builder: (context) {
                                final scopedTasks =
                                    state.dateFilter == TaskDateFilter.today
                                        ? state.todayTasks
                                        : state.allTasks;
                                return CategoryFilterCarousel(
                                  categories: state.categories,
                                  selectedCategoryId: state.categoryFilterId,
                                  totalAllTasksCount: scopedTasks.length,
                                  countGetter: (catId) => scopedTasks
                                      .where((t) => t.categoryId == catId)
                                      .length,
                                  onCategorySelected: (catId) {
                                    context.read<TaskBloc>().add(
                                      FilterByCategoryEvent(catId),
                                    );
                                  },
                                );
                              },
                            ),

                            SizedBox(height: 16.h),

                            // Status Filter Tabs
                            Builder(
                              builder: (context) {
                                final scopedTasks =
                                    state.dateFilter == TaskDateFilter.today
                                        ? state.todayTasks
                                        : state.allTasks;
                                final categoryScopedTasks =
                                    state.categoryFilterId == null
                                        ? scopedTasks
                                        : scopedTasks
                                            .where((t) =>
                                                t.categoryId ==
                                                state.categoryFilterId)
                                            .toList();

                                final int inProgressCount =
                                    categoryScopedTasks.where((t) {
                                  final isDone =
                                      state.dateFilter == TaskDateFilter.today
                                          ? t.isCompletedOn(now)
                                          : t.status == TaskStatus.completed;
                                  return !isDone &&
                                      t.status == TaskStatus.inProgress;
                                }).length;

                                final int pendingCount =
                                    categoryScopedTasks.where((t) {
                                  final isDone =
                                      state.dateFilter == TaskDateFilter.today
                                          ? t.isCompletedOn(now)
                                          : t.status == TaskStatus.completed;
                                  return !isDone &&
                                      t.status == TaskStatus.todo;
                                }).length;

                                final int completedCount =
                                    categoryScopedTasks.where((t) {
                                  return state.dateFilter == TaskDateFilter.today
                                      ? t.isCompletedOn(now)
                                      : t.status == TaskStatus.completed;
                                }).length;

                                return StatusFilterTabs(
                                  activeFilter: state.statusFilter,
                                  allCount: categoryScopedTasks.length,
                                  inProgressCount: inProgressCount,
                                  pendingCount: pendingCount,
                                  completedCount: completedCount,
                                  onFilterChanged: (filter) {
                                    context.read<TaskBloc>().add(
                                      FilterByStatusEvent(filter),
                                    );
                                  },
                                );
                              },
                            ),

                            SizedBox(height: 20.h),

                            // Section Title & Quick Filter Toggle
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          state.dateFilter == TaskDateFilter.today
                                              ? "Today's Tasks"
                                              : 'All Tasks',
                                          style: AppTypography.heading3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 2.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.accentCyan.withAlpha(25),
                                          borderRadius: BorderRadius.circular(10.r),
                                          border: Border.all(
                                            color: AppColors.accentCyan.withAlpha(60),
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Text(
                                          '${state.filteredTasks.length}',
                                          style: AppTypography.caption.copyWith(
                                            color: AppColors.accentCyan,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Toggle between Today only and All tasks
                                GestureDetector(
                                  onTap: () {
                                    final nextDateFilter =
                                        state.dateFilter == TaskDateFilter.today
                                            ? TaskDateFilter.all
                                            : TaskDateFilter.today;
                                    context.read<TaskBloc>().add(
                                          FilterByDateEvent(nextDateFilter),
                                        );
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 5.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: state.dateFilter == TaskDateFilter.all
                                          ? AppColors.primary.withAlpha(30)
                                          : AppColors.surfaceElevated,
                                      borderRadius: BorderRadius.circular(20.r),
                                      border: Border.all(
                                        color: state.dateFilter == TaskDateFilter.all
                                            ? AppColors.primary
                                            : AppColors.border,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          state.dateFilter == TaskDateFilter.all
                                              ? Icons.check_circle_rounded
                                              : Icons.tune_rounded,
                                          size: 13.r,
                                          color: state.dateFilter == TaskDateFilter.all
                                              ? AppColors.primary
                                              : AppColors.textSecondary,
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          state.dateFilter == TaskDateFilter.today
                                              ? 'See All Tasks'
                                              : 'Show Today Only',
                                          style: AppTypography.caption.copyWith(
                                            color: state.dateFilter == TaskDateFilter.all
                                                ? AppColors.primary
                                                : AppColors.textSecondary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 12.h),
                          ],
                        ),
                      ),

                      // Task List or Empty State
                      if (state.filteredTasks.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: TaskEmptyState(
                            title: state.searchQuery.isNotEmpty
                                ? 'No matching tasks'
                                : state.statusFilter ==
                                      TaskStatusFilter.completed
                                ? 'No completed tasks yet'
                                : state.dateFilter == TaskDateFilter.today
                                    ? 'No tasks scheduled for today'
                                    : 'No tasks in this category',
                            subtitle: state.searchQuery.isNotEmpty
                                ? 'Try searching for another keyword or clear filters.'
                                : state.dateFilter == TaskDateFilter.today
                                    ? 'You are all clear today! Tap below to add a task, or tap "See All Tasks" above.'
                                    : 'Tap the button below to add your first task!',
                            onActionTap: _openAddTaskScreen,
                          ),
                        )
                      else
                        SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final task = state.filteredTasks[index];
                            final category = state.getCategoryById(
                              task.categoryId,
                            );

                            return Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: TaskCard(
                                task: task,
                                category: category,
                                date: state.dateFilter == TaskDateFilter.today
                                    ? now
                                    : null,
                                onToggle: () {
                                  context.read<TaskBloc>().add(
                                    ToggleTaskStatusEvent(
                                      task.id,
                                      date: state.dateFilter == TaskDateFilter.today
                                          ? now
                                          : null,
                                    ),
                                  );
                                },
                                onEdit: () {
                                  _openEditTaskScreen(task);
                                },
                                onDelete: () {
                                  context.read<TaskBloc>().add(
                                    DeleteTaskEvent(task.id),
                                  );
                                },
                                onStartFocus: () {
                                  _openFocusTimerScreen(task);
                                },
                              ),
                            );
                          }, childCount: state.filteredTasks.length),
                        ),

                      SliverToBoxAdapter(child: SizedBox(height: 80.h)),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
