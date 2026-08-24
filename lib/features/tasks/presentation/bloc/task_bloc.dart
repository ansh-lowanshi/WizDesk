import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_enums.dart';
import '../../domain/usecases/add_task_usecase.dart';
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

  TaskBloc({
    required this.getTasksUseCase,
    required this.addTaskUseCase,
    required this.updateTaskUseCase,
    required this.deleteTaskUseCase,
    required this.getCategoriesUseCase,
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
  }

  /// Initial load or refresh from storage
  Future<void> _onLoadTasks(
    LoadTasksEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskLoading());
    try {
      final tasks = await getTasksUseCase(const NoParams());
      final categories = await getCategoriesUseCase(const NoParams());

      final filtered = _computeFilteredTasks(
        allTasks: tasks,
        statusFilter: TaskStatusFilter.all,
        categoryFilterId: null,
        priorityFilter: null,
        dateFilter: TaskDateFilter.all,
        searchQuery: '',
      );

      emit(TaskLoaded(
        allTasks: tasks,
        filteredTasks: filtered,
        categories: categories,
      ));
    } catch (e) {
      emit(TaskError('Failed to load tasks: $e'));
    }
  }

  /// Add new task
  Future<void> _onAddTask(
    AddTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
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

        emit(current.copyWith(
          allTasks: updatedAll,
          filteredTasks: updatedFiltered,
        ));
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

        emit(current.copyWith(
          allTasks: updatedAll,
          filteredTasks: updatedFiltered,
        ));
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
        final updatedAll =
            current.allTasks.where((t) => t.id != event.taskId).toList();

        final updatedFiltered = _computeFilteredTasks(
          allTasks: updatedAll,
          statusFilter: current.statusFilter,
          categoryFilterId: current.categoryFilterId,
          priorityFilter: current.priorityFilter,
          dateFilter: current.dateFilter,
          searchQuery: current.searchQuery,
        );

        emit(current.copyWith(
          allTasks: updatedAll,
          filteredTasks: updatedFiltered,
        ));
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
      final isNowCompleted = task.status != TaskStatus.completed;
      final updatedTask = task.copyWith(
        status: isNowCompleted ? TaskStatus.completed : TaskStatus.todo,
        completedAt: isNowCompleted ? DateTime.now() : null,
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

      emit(current.copyWith(
        allTasks: updatedAll,
        filteredTasks: updatedFiltered,
      ));
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
        completedAt: event.status == TaskStatus.completed ? DateTime.now() : null,
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

      emit(current.copyWith(
        allTasks: updatedAll,
        filteredTasks: updatedFiltered,
      ));
    } catch (e) {
      emit(TaskError('Failed to update status: $e'));
    }
  }

  /// Filter by Status Tab
  void _onFilterByStatus(
    FilterByStatusEvent event,
    Emitter<TaskState> emit,
  ) {
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

    emit(current.copyWith(
      statusFilter: event.statusFilter,
      filteredTasks: filtered,
    ));
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

    emit(current.copyWith(
      categoryFilterId: () => event.categoryId,
      filteredTasks: filtered,
    ));
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

    emit(current.copyWith(
      priorityFilter: () => event.priority,
      filteredTasks: filtered,
    ));
  }

  /// Filter by Date
  void _onFilterByDate(
    FilterByDateEvent event,
    Emitter<TaskState> emit,
  ) {
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

    emit(current.copyWith(
      dateFilter: event.dateFilter,
      filteredTasks: filtered,
    ));
  }

  /// Search tasks by keyword
  void _onSearchTasks(
    SearchTasksEvent event,
    Emitter<TaskState> emit,
  ) {
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

    emit(current.copyWith(
      searchQuery: event.query,
      filteredTasks: filtered,
    ));
  }

  /// Add custom category
  Future<void> _onAddCategory(
    AddCategoryEvent event,
    Emitter<TaskState> emit,
  ) async {
    if (state is! TaskLoaded) return;
    final current = state as TaskLoaded;

    final updatedCategories = [...current.categories, event.category];
    emit(current.copyWith(categories: updatedCategories));
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
      if (statusFilter == TaskStatusFilter.inProgress &&
          task.status != TaskStatus.inProgress) {
        return false;
      }
      if (statusFilter == TaskStatusFilter.pending &&
          task.status != TaskStatus.todo) {
        return false;
      }
      if (statusFilter == TaskStatusFilter.completed &&
          task.status != TaskStatus.completed) {
        return false;
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
