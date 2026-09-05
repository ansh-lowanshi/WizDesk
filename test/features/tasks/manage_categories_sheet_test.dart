import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wizdesk/core/constants/app_constants.dart';
import 'package:wizdesk/core/theme/app_theme.dart';
import 'package:wizdesk/features/tasks/domain/entities/task_category_entity.dart';
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
import 'package:wizdesk/features/tasks/presentation/widgets/manage_categories_sheet.dart';

import 'task_bloc_test.dart';

void main() {
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
        TaskCategoryEntity(
          id: 'cat_study',
          name: 'Study',
          iconCode: 0xe559,
          colorValue: 0xFF00F0FF,
        ),
      ],
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

  testWidgets('ManageCategoriesSheet displays categories and deletes on confirmation',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.runAsync(() async {
      final taskLoadedFuture =
          taskBloc.stream.firstWhere((s) => s is TaskLoaded);
      taskBloc.add(const LoadTasksEvent());
      await taskLoadedFuture;
    });

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize:
            const Size(AppConstants.designWidth, AppConstants.designHeight),
        builder: (context, child) {
          return BlocProvider<TaskBloc>.value(
            value: taskBloc,
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: const Scaffold(
                body: ManageCategoriesSheet(),
              ),
            ),
          );
        },
      ),
    );

    await tester.pumpAndSettle();

    // Verify title and categories render
    expect(find.text('Manage Categories'), findsOneWidget);
    expect(find.text('Work'), findsOneWidget);
    expect(find.text('Study'), findsOneWidget);

    // Tap delete button for Study category
    final deleteStudyBtn = find.byKey(const ValueKey('delete_cat_cat_study'));
    expect(deleteStudyBtn, findsOneWidget);
    await tester.tap(deleteStudyBtn);
    await tester.pumpAndSettle();

    // Verify confirmation dialog
    expect(find.text('Delete Category?'), findsOneWidget);
    expect(find.byKey(const ValueKey('cancel_delete_cat_btn')), findsOneWidget);
    expect(find.byKey(const ValueKey('confirm_delete_cat_btn')), findsOneWidget);

    // Confirm deletion
    await tester.runAsync(() async {
      final taskLoadedFuture = taskBloc.stream
          .firstWhere((s) => s is TaskLoaded && !s.categories.any((c) => c.id == 'cat_study'));
      await tester.tap(find.byKey(const ValueKey('confirm_delete_cat_btn')));
      await taskLoadedFuture;
    });
    await tester.pumpAndSettle();

    // Verify category is removed from state
    expect(find.text('Study'), findsNothing);
    expect(find.text('Work'), findsOneWidget);
  });
}
