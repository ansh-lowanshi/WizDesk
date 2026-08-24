import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../core/widgets/glow_container.dart';
import '../../../../core/widgets/responsive_wrapper.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../widgets/category_filter_carousel.dart';
import '../widgets/daily_progress_banner.dart';
import '../widgets/status_filter_tabs.dart';
import '../widgets/task_card.dart';
import '../widgets/task_empty_state.dart';
import '../widgets/task_search_bar.dart';
import 'add_edit_task_screen.dart';

/// Main Home Dashboard Screen for Wiz Desk
class HomeDashboardScreen extends StatefulWidget {
  final VoidCallback? onNavigateToTimer;
  final VoidCallback? onNavigateToAddTask;
  final ValueChanged<TaskEntity>? onStartTaskFocus;

  const HomeDashboardScreen({
    super.key,
    this.onNavigateToTimer,
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
    // Trigger initial load
    context.read<TaskBloc>().add(const LoadTasksEvent());
  }

  void _openAddTaskScreen() {
    if (widget.onNavigateToAddTask != null) {
      widget.onNavigateToAddTask!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const AddEditTaskScreen(),
        ),
      );
    }
  }

  void _openEditTaskScreen(TaskEntity task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditTaskScreen(taskToEdit: task),
      ),
    );
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
              if (state is TaskLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.accentCyan),
                  ),
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
                                      Text(
                                        'Good Day, Creator 👋',
                                        style: AppTypography.heading2,
                                        overflow: TextOverflow.ellipsis,
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
                                      onPressed: () {
                                        setState(() {
                                          _isSearchOpen = !_isSearchOpen;
                                        });
                                        if (!_isSearchOpen) {
                                          context
                                              .read<TaskBloc>()
                                              .add(const SearchTasksEvent(''));
                                        }
                                      },
                                    ),
                                    SizedBox(width: 4.w),
                                    GlowContainer(
                                      isCircle: true,
                                      padding: EdgeInsets.all(8.r),
                                      glowColor: AppColors.primary,
                                      child: Icon(
                                        Icons.person_outline_rounded,
                                        size: 20.r,
                                        color: AppColors.textPrimary,
                                      ),
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
                                  context
                                      .read<TaskBloc>()
                                      .add(SearchTasksEvent(query));
                                },
                              ),
                              SizedBox(height: 16.h),
                            ],

                            // Daily Progress Banner
                            DailyProgressBanner(
                              completedTasks: state.completedTasksCount,
                              totalTasks: state.totalTasksCount,
                              totalFocusMinutes: state.allTasks.fold<int>(
                                0,
                                (sum, t) => sum + t.spentMinutes,
                              ),
                            ),

                            SizedBox(height: 20.h),

                            // Category Filter Carousel
                            CategoryFilterCarousel(
                              categories: state.categories,
                              selectedCategoryId: state.categoryFilterId,
                              totalAllTasksCount: state.allTasks.length,
                              countGetter: (catId) =>
                                  state.countTasksInCategory(catId),
                              onCategorySelected: (catId) {
                                context
                                    .read<TaskBloc>()
                                    .add(FilterByCategoryEvent(catId));
                              },
                            ),

                            SizedBox(height: 16.h),

                            // Status Filter Tabs
                            StatusFilterTabs(
                              activeFilter: state.statusFilter,
                              allCount: state.allTasks.length,
                              inProgressCount: state.inProgressTasksCount,
                              pendingCount: state.pendingTasksCount,
                              completedCount: state.completedTasksCount,
                              onFilterChanged: (filter) {
                                context
                                    .read<TaskBloc>()
                                    .add(FilterByStatusEvent(filter));
                              },
                            ),

                            SizedBox(height: 20.h),

                            // Section Title & Counter
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  state.statusFilter.label == 'All'
                                      ? 'Tasks Overview'
                                      : '${state.statusFilter.label} Tasks',
                                  style: AppTypography.heading3,
                                ),
                                Text(
                                  '${state.filteredTasks.length} items',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.accentCyan,
                                    fontWeight: FontWeight.w700,
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
                                    : 'No tasks in this category',
                            subtitle: state.searchQuery.isNotEmpty
                                ? 'Try searching for another keyword or clear filters.'
                                : 'Tap the button below to add your first task!',
                            onActionTap: _openAddTaskScreen,
                          ),
                        )
                      else
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final task = state.filteredTasks[index];
                              final category =
                                  state.getCategoryById(task.categoryId);

                              return Padding(
                                padding: EdgeInsets.only(bottom: 12.h),
                                child: TaskCard(
                                  task: task,
                                  category: category,
                                  onToggle: () {
                                    context
                                        .read<TaskBloc>()
                                        .add(ToggleTaskStatusEvent(task.id));
                                  },
                                  onTap: () {
                                    _openEditTaskScreen(task);
                                  },
                                  onDelete: () {
                                    context
                                        .read<TaskBloc>()
                                        .add(DeleteTaskEvent(task.id));
                                  },
                                  onStartFocus: () {
                                    if (widget.onStartTaskFocus != null) {
                                      widget.onStartTaskFocus!(task);
                                    }
                                  },
                                ),
                              );
                            },
                            childCount: state.filteredTasks.length,
                          ),
                        ),

                      SliverToBoxAdapter(
                        child: SizedBox(height: 80.h),
                      ),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: AppDecorations.glowButton(borderRadius: 16.r),
        child: FloatingActionButton.extended(
          onPressed: _openAddTaskScreen,
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          icon: Icon(Icons.add_rounded, size: 22.r, color: Colors.white),
          label: Text('Add New Task', style: AppTypography.buttonMedium),
        ),
      ),
    );
  }
}
