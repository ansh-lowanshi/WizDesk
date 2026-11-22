import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:wizdesk/core/constants/app_constants.dart';
import 'package:wizdesk/core/theme/app_theme.dart';
import 'package:wizdesk/features/tasks/domain/entities/task_category_entity.dart';
import 'package:wizdesk/features/tasks/domain/usecases/add_task_usecase.dart';
import 'package:wizdesk/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:wizdesk/features/tasks/domain/usecases/get_categories_usecase.dart';
import 'package:wizdesk/features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'package:wizdesk/features/tasks/domain/usecases/update_task_usecase.dart';
import 'package:wizdesk/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:wizdesk/features/tasks/presentation/bloc/task_state.dart';
import 'package:wizdesk/features/tasks/presentation/screens/add_edit_task_screen.dart';

import 'task_bloc_test.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en', null);
  });

  late MockTaskRepository repository;
  late TaskBloc taskBloc;

  setUp(() {
    repository = MockTaskRepository(
      initialTasks: [],
      initialCategories: const [
        TaskCategoryEntity(
          id: 'cat_work',
          name: 'Work',
          iconCode: 0xe6f2,
          colorValue: 0xFF3874FF,
        ),
      ],
    );

    taskBloc = TaskBloc(
      getTasksUseCase: GetTasksUseCase(repository),
      addTaskUseCase: AddTaskUseCase(repository),
      updateTaskUseCase: UpdateTaskUseCase(repository),
      deleteTaskUseCase: DeleteTaskUseCase(repository),
      getCategoriesUseCase: GetCategoriesUseCase(repository),
    );
  });

  tearDown(() {
    taskBloc.close();
  });

  testWidgets('AddEditTaskScreen renders inputs and creates task',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() => tester.view.resetPhysicalSize());

    taskBloc.emit(
      const TaskLoaded(
        allTasks: [],
        filteredTasks: [],
        categories: [
          TaskCategoryEntity(
            id: 'cat_work',
            name: 'Work',
            iconCode: 0xe6f2,
            colorValue: 0xFF3874FF,
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize:
            const Size(AppConstants.designWidth, AppConstants.designHeight),
        builder: (context, child) {
          return BlocProvider<TaskBloc>.value(
            value: taskBloc,
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: const AddEditTaskScreen(),
            ),
          );
        },
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Add Task'), findsOneWidget);
    expect(find.text('Task Title'), findsOneWidget);
    expect(find.text('Priority'), findsOneWidget);
    expect(find.text('Pomodoro Focus Mode'), findsOneWidget);

    // Enter task title
    await tester.enterText(
        find.widgetWithText(TextFormField, 'What needs to be accomplished?'),
        'Prepare Sprint Presentation');
    await tester.pump();

    // Scroll to Create Task button and tap
    final createBtn = find.widgetWithText(ElevatedButton, 'Create Task');
    await tester.ensureVisible(createBtn);
    await tester.tap(createBtn);
    await tester.pumpAndSettle();

    // Verify task is added to MockRepository and BLoC
    final tasks = await repository.getTasks();
    expect(tasks.any((t) => t.title == 'Prepare Sprint Presentation'), isTrue);
  });
}

