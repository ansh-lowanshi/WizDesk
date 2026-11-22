import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_enums.dart';
import '../../domain/usecases/add_category_usecase.dart';
import '../../domain/usecases/add_task_usecase.dart';
import '../../domain/usecases/delete_category_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';
import 'task_event.dart';
import 'task_state.dart';

/// Pure BLoC managing Task state, filtering, and data operations
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasksUseCase getTasksUseCase;
  final AddTaskUseCase addTaskUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final AddCategoryUseCase? addCategoryUseCase;
  final DeleteCategoryUseCase? deleteCategoryUseCase;

  TaskBloc({
    required this.getTasksUseCase,
    required this.addTaskUseCase,
    required this.updateTaskUseCase,
    required this.deleteTaskUseCase,
    required this.getCategoriesUseCase,
    this.addCategoryUseCase,
    this.deleteCategoryUseCase,
  }) : super(const TaskInitial()) {
    on<LoadTasksEvent>(_onLoadTasks);
    on<AddTaskEvent>(_onAddTask);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<DeleteTaskEvent>(_onDeleteTask);
    on<ToggleTaskStatusEvent>(_onToggleTaskStatus);
    on<UpdateTaskStatusDirectEvent>(_onUpdateTaskStatusDirect);
    on<FilterByStatusEvent>(_onFilterByStatus);
    on<FilterByCategoryEvent>(_onFilterByCategory);
    on<FilterByPriorityEvent>(_onFilterByPriority);
    on<FilterByDateEvent>(_onFilterByDate);
    on<SearchTasksEvent>(_onSearchTasks);
    on<AddCategoryEvent>(_onAddCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
  }

  /// Initial load or refresh from storage
  Future<void> _onLoadTasks(
    LoadTasksEvent event,
    Emitter<TaskState> emit,
  ) async {
    if (!event.isSilent && state is! TaskLoaded) {
      emit(const TaskLoading());
    }
    try {
      final loadedTasks = await getTasksUseCase(const NoParams());
      final categories = await getCategoriesUseCase(const NoParams());

      // Auto-heal tasks whose spent time meets or exceeds estimatedMinutes
      final now = DateTime.now();
      final dateKey = TaskEntity.formatDateKey(now);
      final tasks = <TaskEntity>[];
      for (final task in loadedTasks) {
        final spentToday = task.getSpentMinutesFor(now);
        final isOverDueEstimated =
            task.estimatedMinutes > 0 &&
            (task.spentMinutes >= task.estimatedMinutes ||
                spentToday >= task.estimatedMinutes);
        if (isOverDueEstimated &&
            (task.status != TaskStatus.completed ||
                !task.completedDates.contains(dateKey))) {
          final updatedCompletedDates = List<String>.from(task.completedDates);
          if (!updatedCompletedDates.contains(dateKey)) {
            updatedCompletedDates.add(dateKey);
          }
          final updatedDailyProgress = Map<String, int>.from(
            task.dailyProgress,
          );
          updatedDailyProgress[dateKey] = 100;

          final healedTask = task.copyWith(
            status: TaskStatus.completed,
            progressPercent: 100,
            completedDates: updatedCompletedDates,
            dailyProgress: updatedDailyProgress,
            completedAt: task.completedAt ?? now,
          );
          await updateTaskUseCase(healedTask);
          tasks.add(healedTask);
        } else {
          tasks.add(task);
        }
      }

      final filtered = _computeFilteredTasks(
        allTasks: tasks,
        statusFilter: TaskStatusFilter.all,
        categoryFilterId: null,
        priorityFilter: null,
        dateFilter: TaskDateFilter.today,
        searchQuery: '',
      );

      emit(
        TaskLoaded(
          allTasks: tasks,
          filteredTasks: filtered,
          categories: categories,
          dateFilter: TaskDateFilter.today,
        ),
      );
    } catch (e) {
      emit(TaskError('Failed to load tasks: $e'));
    } finally {
      if (event.completer != null && !event.completer!.isCompleted) {
        event.completer!.complete();
      }
    }
  }

  /// Add new task
  Future<void> _onAddTask(AddTaskEvent event, Emitter<TaskState> emit) async {
    try {
      await addTaskUseCase(event.task);
      if (state is TaskLoaded) {
        final current = state as TaskLoaded;
        final updatedAll = [event.task, ...current.allTasks];
        final updatedFiltered = _computeFilteredTasks(
          allTasks: updatedAll,
          statusFilter: current.statusFilter,
          categoryFilterId: current.categoryFilterId,
          priorityFilter: current.priorityFilter,
          dateFilter: current.dateFilter,
          searchQuery: current.searchQuery,
        );

        emit(
          current.copyWith(
            allTasks: updatedAll,
            filteredTasks: updatedFiltered,
          ),
        );
      } else {
        add(const LoadTasksEvent());
      }
    } catch (e) {
      emit(TaskError('Failed to add task: $e'));
    }
  }

  /// Update existing task
  Future<void> _onUpdateTask(
    UpdateTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    try {
      await updateTaskUseCase(event.task);
      if (state is TaskLoaded) {
        final current = state as TaskLoaded;
        final updatedAll = current.allTasks
            .map((t) => t.id == event.task.id ? event.task : t)
            .toList();

        final updatedFiltered = _computeFilteredTasks(
          allTasks: updatedAll,
          statusFilter: current.statusFilter,
          categoryFilterId: current.categoryFilterId,
          priorityFilter: current.priorityFilter,
          dateFilter: current.dateFilter,
          searchQuery: current.searchQuery,
        );

        emit(
          current.copyWith(
            allTasks: updatedAll,
            filteredTasks: updatedFiltered,
          ),
        );
      }
    } catch (e) {
      emit(TaskError('Failed to update task: $e'));
    }
  }

  /// Delete task
  Future<void> _onDeleteTask(
    DeleteTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    try {
      await deleteTaskUseCase(event.taskId);
      if (state is TaskLoaded) {
        final current = state as TaskLoaded;
        final updatedAll = current.allTasks
            .where((t) => t.id != event.taskId)
            .toList();

        final updatedFiltered = _computeFilteredTasks(
          allTasks: updatedAll,
          statusFilter: current.statusFilter,
          categoryFilterId: current.categoryFilterId,
          priorityFilter: current.priorityFilter,
          dateFilter: current.dateFilter,
          searchQuery: current.searchQuery,
        );

        emit(
          current.copyWith(
            allTasks: updatedAll,
            filteredTasks: updatedFiltered,
          ),
        );
      }
    } catch (e) {
      emit(TaskError('Failed to delete task: $e'));
    }
  }

  /// Toggle completion
  Future<void> _onToggleTaskStatus(
    ToggleTaskStatusEvent event,
    Emitter<TaskState> emit,
  ) async {
    if (state is! TaskLoaded) return;
    final current = state as TaskLoaded;

    try {
      final task = current.allTasks.firstWhere((t) => t.id == event.taskId);
      final targetDate = event.date ?? DateTime.now();
      final dateStr =
          '${targetDate.year.toString().padLeft(4, '0')}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';

      final completedDates = List<String>.from(task.completedDates);
      final bool wasCompletedOnDate = task.isCompletedOn(targetDate);

      if (wasCompletedOnDate) {
        completedDates.remove(dateStr);
      } else {
        if (!completedDates.contains(dateStr)) {
          completedDates.add(dateStr);
        }
      }

      final bool isNowCompletedOnDate = !wasCompletedOnDate;
      final now = DateTime.now();
      final isToday =
          targetDate.year == now.year &&
          targetDate.month == now.month &&
          targetDate.day == now.day;

      TaskStatus newStatus = task.status;
      if (task.frequency == TaskFrequency.once) {
        newStatus = isNowCompletedOnDate
            ? TaskStatus.completed
            : TaskStatus.todo;
      } else if (isToday) {
        newStatus = isNowCompletedOnDate
            ? TaskStatus.completed
            : TaskStatus.todo;
      }

      final updatedTask = task.copyWith(
        completedDates: completedDates,
        status: newStatus,
        completedAt: isNowCompletedOnDate ? targetDate : null,
      );

      await updateTaskUseCase(updatedTask);

      final updatedAll = current.allTasks
          .map((t) => t.id == event.taskId ? updatedTask : t)
          .toList();

      final updatedFiltered = _computeFilteredTasks(
        allTasks: updatedAll,
        statusFilter: current.statusFilter,
        categoryFilterId: current.categoryFilterId,
        priorityFilter: current.priorityFilter,
        dateFilter: current.dateFilter,
        searchQuery: current.searchQuery,
      );

      emit(
        current.copyWith(allTasks: updatedAll, filteredTasks: updatedFiltered),
      );
    } catch (e) {
      emit(TaskError('Failed to toggle task: $e'));
    }
  }

  /// Update task status directly (e.g. set In Progress)
  Future<void> _onUpdateTaskStatusDirect(
    UpdateTaskStatusDirectEvent event,
    Emitter<TaskState> emit,
  ) async {
    if (state is! TaskLoaded) return;
    final current = state as TaskLoaded;

    try {
      final task = current.allTasks.firstWhere((t) => t.id == event.taskId);
      final updatedTask = task.copyWith(
        status: event.status,
        completedAt: event.status == TaskStatus.completed
            ? DateTime.now()
            : null,
      );

      await updateTaskUseCase(updatedTask);

      final updatedAll = current.allTasks
          .map((t) => t.id == event.taskId ? updatedTask : t)
          .toList();

      final updatedFiltered = _computeFilteredTasks(
        allTasks: updatedAll,
        statusFilter: current.statusFilter,
        categoryFilterId: current.categoryFilterId,
        priorityFilter: current.priorityFilter,
        dateFilter: current.dateFilter,
        searchQuery: current.searchQuery,
      );

      emit(
        current.copyWith(allTasks: updatedAll, filteredTasks: updatedFiltered),
      );
    } catch (e) {
      emit(TaskError('Failed to update status: $e'));
    }
  }

  /// Filter by Status Tab
  void _onFilterByStatus(FilterByStatusEvent event, Emitter<TaskState> emit) {
    if (state is! TaskLoaded) return;
    final current = state as TaskLoaded;

    final filtered = _computeFilteredTasks(
      allTasks: current.allTasks,
      statusFilter: event.statusFilter,
      categoryFilterId: current.categoryFilterId,
      priorityFilter: current.priorityFilter,
      dateFilter: current.dateFilter,
      searchQuery: current.searchQuery,
    );

    emit(
      current.copyWith(
        statusFilter: event.statusFilter,
        filteredTasks: filtered,
      ),
    );
  }

  /// Filter by Category
  void _onFilterByCategory(
    FilterByCategoryEvent event,
    Emitter<TaskState> emit,
  ) {
    if (state is! TaskLoaded) return;
    final current = state as TaskLoaded;

    final filtered = _computeFilteredTasks(
      allTasks: current.allTasks,
      statusFilter: current.statusFilter,
      categoryFilterId: event.categoryId,
      priorityFilter: current.priorityFilter,
      dateFilter: current.dateFilter,
      searchQuery: current.searchQuery,
    );

    emit(
      current.copyWith(
        categoryFilterId: () => event.categoryId,
        filteredTasks: filtered,
      ),
    );
  }

  /// Filter by Priority
  void _onFilterByPriority(
    FilterByPriorityEvent event,
    Emitter<TaskState> emit,
  ) {
    if (state is! TaskLoaded) return;
    final current = state as TaskLoaded;

    final filtered = _computeFilteredTasks(
      allTasks: current.allTasks,
      statusFilter: current.statusFilter,
      categoryFilterId: current.categoryFilterId,
      priorityFilter: event.priority,
      dateFilter: current.dateFilter,
      searchQuery: current.searchQuery,
    );

    emit(
      current.copyWith(
        priorityFilter: () => event.priority,
        filteredTasks: filtered,
      ),
    );
  }

  /// Filter by Date
  void _onFilterByDate(FilterByDateEvent event, Emitter<TaskState> emit) {
    if (state is! TaskLoaded) return;
    final current = state as TaskLoaded;

    final filtered = _computeFilteredTasks(
      allTasks: current.allTasks,
      statusFilter: current.statusFilter,
      categoryFilterId: current.categoryFilterId,
      priorityFilter: current.priorityFilter,
      dateFilter: event.dateFilter,
      searchQuery: current.searchQuery,
    );

    emit(
      current.copyWith(dateFilter: event.dateFilter, filteredTasks: filtered),
    );
  }

  /// Search tasks by keyword
  void _onSearchTasks(SearchTasksEvent event, Emitter<TaskState> emit) {
    if (state is! TaskLoaded) return;
    final current = state as TaskLoaded;

    final filtered = _computeFilteredTasks(
      allTasks: current.allTasks,
      statusFilter: current.statusFilter,
      categoryFilterId: current.categoryFilterId,
      priorityFilter: current.priorityFilter,
      dateFilter: current.dateFilter,
      searchQuery: event.query,
    );

    emit(current.copyWith(searchQuery: event.query, filteredTasks: filtered));
  }

  /// Add custom category
  Future<void> _onAddCategory(
    AddCategoryEvent event,
    Emitter<TaskState> emit,
  ) async {
    if (state is! TaskLoaded) return;
    final current = state as TaskLoaded;

    try {
      if (addCategoryUseCase != null) {
        await addCategoryUseCase!(event.category);
      }
      final updatedCategories = [...current.categories, event.category];
      emit(current.copyWith(categories: updatedCategories));
    } catch (e) {
      emit(TaskError('Failed to add category: $e'));
    }
  }

  /// Delete existing category
  Future<void> _onDeleteCategory(
    DeleteCategoryEvent event,
    Emitter<TaskState> emit,
  ) async {
    if (state is! TaskLoaded) return;
    final current = state as TaskLoaded;

    try {
      if (deleteCategoryUseCase != null) {
        await deleteCategoryUseCase!(event.categoryId);
      }
      final updatedCategories = current.categories
          .where((cat) => cat.id != event.categoryId)
          .toList();

      final updatedCategoryFilter = current.categoryFilterId == event.categoryId
          ? null
          : current.categoryFilterId;

      final filtered = _computeFilteredTasks(
        allTasks: current.allTasks,
        statusFilter: current.statusFilter,
        categoryFilterId: updatedCategoryFilter,
        priorityFilter: current.priorityFilter,
        dateFilter: current.dateFilter,
        searchQuery: current.searchQuery,
      );

      emit(
        current.copyWith(
          categories: updatedCategories,
          categoryFilterId: () => updatedCategoryFilter,
          filteredTasks: filtered,
        ),
      );
    } catch (e) {
      emit(TaskError('Failed to delete category: $e'));
    }
  }

  /// Pure filtering computation logic
  static List<TaskEntity> _computeFilteredTasks({
    required List<TaskEntity> allTasks,
    required TaskStatusFilter statusFilter,
    required String? categoryFilterId,
    required TaskPriority? priorityFilter,
    required TaskDateFilter dateFilter,
    required String searchQuery,
  }) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    return allTasks.where((task) {
      // 1. Status Filter
      if (statusFilter == TaskStatusFilter.inProgress) {
        final isDoneOnDate = dateFilter == TaskDateFilter.today
            ? task.isCompletedOn(now)
            : task.isCompleted;
        if (isDoneOnDate || task.status != TaskStatus.inProgress) {
          return false;
        }
      }
      if (statusFilter == TaskStatusFilter.pending) {
        final isDoneOnDate = dateFilter == TaskDateFilter.today
            ? task.isCompletedOn(now)
            : task.isCompleted;
        if (isDoneOnDate || task.status != TaskStatus.todo) {
          return false;
        }
      }
      if (statusFilter == TaskStatusFilter.completed) {
        final isDoneOnDate = dateFilter == TaskDateFilter.today
            ? task.isCompletedOn(now)
            : task.isCompleted;
        if (!isDoneOnDate) {
          return false;
        }
      }

      // 2. Category Filter
      if (categoryFilterId != null &&
          categoryFilterId.isNotEmpty &&
          task.categoryId != categoryFilterId) {
        return false;
      }

      // 3. Priority Filter
      if (priorityFilter != null && task.priority != priorityFilter) {
        return false;
      }

      // 4. Date Filter
      if (dateFilter == TaskDateFilter.today) {
        if (!task.isDueToday) return false;
      } else if (dateFilter == TaskDateFilter.upcoming) {
        if (task.dueDate == null || !task.dueDate!.isAfter(todayEnd)) {
          return false;
        }
      } else if (dateFilter == TaskDateFilter.overdue) {
        if (task.dueDate == null ||
            !task.dueDate!.isBefore(todayStart) ||
            task.isCompleted) {
          return false;
        }
      }

      // 5. Search Query Filter
      if (searchQuery.trim().isNotEmpty) {
        final query = searchQuery.trim().toLowerCase();
        final titleMatch = task.title.toLowerCase().contains(query);
        final descMatch = task.description.toLowerCase().contains(query);
        if (!titleMatch && !descMatch) return false;
      }

      return true;
    }).toList();
  }
}
