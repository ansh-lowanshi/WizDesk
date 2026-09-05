import 'package:flutter_test/flutter_test.dart';
import 'package:wizdesk/features/tasks/domain/entities/focus_session_entity.dart';
import 'package:wizdesk/features/tasks/domain/entities/task_category_entity.dart';
import 'package:wizdesk/features/tasks/domain/entities/task_entity.dart';
import 'package:wizdesk/features/tasks/domain/entities/task_enums.dart';
import 'package:wizdesk/features/tasks/domain/repositories/task_repository.dart';
import 'package:wizdesk/features/tasks/domain/usecases/add_category_usecase.dart';
import 'package:wizdesk/features/tasks/domain/usecases/add_task_usecase.dart';
import 'package:wizdesk/features/tasks/domain/usecases/delete_category_usecase.dart';
import 'package:wizdesk/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:wizdesk/features/tasks/domain/usecases/get_categories_usecase.dart';
import 'package:wizdesk/features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'package:wizdesk/features/tasks/domain/usecases/update_task_usecase.dart';
import 'package:wizdesk/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:wizdesk/features/tasks/presentation/bloc/task_event.dart';
import 'package:wizdesk/features/tasks/presentation/bloc/task_state.dart';

// In-memory test repository implementation
class MockTaskRepository implements TaskRepository {
  final List<TaskEntity> _tasks = [];
  final List<TaskCategoryEntity> _categories = [];
  final List<FocusSessionEntity> _sessions = [];

  MockTaskRepository({
    List<TaskEntity>? initialTasks,
    List<TaskCategoryEntity>? initialCategories,
    List<FocusSessionEntity>? initialSessions,
  }) {
    if (initialTasks != null) _tasks.addAll(initialTasks);
    if (initialCategories != null) _categories.addAll(initialCategories);
    if (initialSessions != null) _sessions.addAll(initialSessions);
  }

  @override
  Future<List<TaskEntity>> getTasks() async => List.from(_tasks);

  @override
  Future<TaskEntity?> getTaskById(String taskId) async {
    try {
      return _tasks.firstWhere((t) => t.id == taskId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addTask(TaskEntity task) async {
    _tasks.add(task);
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) _tasks[index] = task;
  }

  @override
  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((t) => t.id == taskId);
  }

  @override
  Future<void> updateTaskStatus(String taskId, TaskStatus newStatus) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(status: newStatus);
    }
  }

  @override
  Future<List<TaskCategoryEntity>> getCategories() async => List.from(_categories);

  @override
  Future<void> addCategory(TaskCategoryEntity category) async {
    _categories.add(category);
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    _categories.removeWhere((c) => c.id == categoryId);
  }

  @override
  Future<void> logFocusSession(FocusSessionEntity session) async {
    _sessions.add(session);
  }

  @override
  Future<List<FocusSessionEntity>> getFocusSessions() async => List.from(_sessions);
}

void main() {
  late MockTaskRepository repository;
  late TaskBloc taskBloc;

  final tTask1 = TaskEntity(
    id: '1',
    title: 'Design UI Theme',
    description: 'Create neon cyan dark mode cards',
    categoryId: 'cat_design',
    priority: TaskPriority.high,
    status: TaskStatus.inProgress,
    createdAt: DateTime.now(),
  );

  final tTask2 = TaskEntity(
    id: '2',
    title: 'Write Unit Tests',
    description: 'Verify BLoC state transitions',
    categoryId: 'cat_coding',
    priority: TaskPriority.urgent,
    status: TaskStatus.todo,
    createdAt: DateTime.now(),
  );

  final tCategory = const TaskCategoryEntity(
    id: 'cat_design',
    name: 'Design',
    iconCode: 0xe471,
    colorValue: 0xFFFF6B6B,
  );

  setUp(() {
    repository = MockTaskRepository(
      initialTasks: [tTask1, tTask2],
      initialCategories: [tCategory],
    );

    taskBloc = TaskBloc(
      getTasksUseCase: GetTasksUseCase(repository),
      addTaskUseCase: AddTaskUseCase(repository),
      updateTaskUseCase: UpdateTaskUseCase(repository),
      deleteTaskUseCase: DeleteTaskUseCase(repository),
      getCategoriesUseCase: GetCategoriesUseCase(repository),
      addCategoryUseCase: AddCategoryUseCase(repository),
      deleteCategoryUseCase: DeleteCategoryUseCase(repository),
    );
  });

  tearDown(() {
    taskBloc.close();
  });

  test('initial state should be TaskInitial', () {
    expect(taskBloc.state, isA<TaskInitial>());
  });

  test('LoadTasksEvent should emit TaskLoading and then TaskLoaded with correct metrics', () async {
    taskBloc.add(const LoadTasksEvent());

    await expectLater(
      taskBloc.stream,
      emitsInOrder([
        isA<TaskLoading>(),
        predicate<TaskLoaded>((state) {
          expect(state.allTasks.length, 2);
          expect(state.totalTasksCount, 2);
          expect(state.inProgressTasksCount, 1);
          expect(state.pendingTasksCount, 1);
          expect(state.completedTasksCount, 0);
          return true;
        }),
      ]),
    );
  });

  test('FilterByStatusEvent should filter tasks correctly', () async {
    taskBloc.add(const LoadTasksEvent());
    await taskBloc.stream.firstWhere((s) => s is TaskLoaded);

    taskBloc.add(const FilterByStatusEvent(TaskStatusFilter.inProgress));

    await expectLater(
      taskBloc.stream,
      emits(predicate<TaskLoaded>((state) {
        expect(state.filteredTasks.length, 1);
        expect(state.filteredTasks.first.id, '1');
        return true;
      })),
    );
  });

  test('SearchTasksEvent should filter tasks by keyword substring', () async {
    taskBloc.add(const LoadTasksEvent());
    await taskBloc.stream.firstWhere((s) => s is TaskLoaded);

    taskBloc.add(const SearchTasksEvent('Unit Tests'));

    await expectLater(
      taskBloc.stream,
      emits(predicate<TaskLoaded>((state) {
        expect(state.filteredTasks.length, 1);
        expect(state.filteredTasks.first.id, '2');
        return true;
      })),
    );
  });

  test('ToggleTaskStatusEvent should flip task to completed', () async {
    taskBloc.add(const LoadTasksEvent());
    await taskBloc.stream.firstWhere((s) => s is TaskLoaded);

    taskBloc.add(const ToggleTaskStatusEvent('2'));

    await expectLater(
      taskBloc.stream,
      emits(predicate<TaskLoaded>((state) {
        final toggled = state.allTasks.firstWhere((t) => t.id == '2');
        expect(toggled.status, TaskStatus.completed);
        expect(state.completedTasksCount, 1);
        return true;
      })),
    );
  });

  test('AddCategoryEvent and DeleteCategoryEvent should add and remove categories', () async {
    taskBloc.add(const LoadTasksEvent());
    await taskBloc.stream.firstWhere((s) => s is TaskLoaded);

    final newCategory = const TaskCategoryEntity(
      id: 'cat_fitness',
      name: 'Fitness',
      iconCode: 0xe294,
      colorValue: 0xFF10B981,
    );

    // 1. Add Category
    taskBloc.add(AddCategoryEvent(newCategory));
    await expectLater(
      taskBloc.stream,
      emits(predicate<TaskLoaded>((state) {
        expect(state.categories.length, 2);
        expect(state.categories.any((c) => c.id == 'cat_fitness'), isTrue);
        return true;
      })),
    );

    // 2. Delete Category
    taskBloc.add(const DeleteCategoryEvent('cat_fitness'));
    await expectLater(
      taskBloc.stream,
      emits(predicate<TaskLoaded>((state) {
        expect(state.categories.length, 1);
        expect(state.categories.any((c) => c.id == 'cat_fitness'), isFalse);
        return true;
      })),
    );
  });
}
