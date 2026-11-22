import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wizdesk/core/constants/app_constants.dart';
import 'package:wizdesk/features/notes/domain/entities/note_entity.dart';
import 'package:wizdesk/features/notes/domain/repositories/note_repository.dart';
import 'package:wizdesk/features/notes/domain/usecases/add_note_usecase.dart';
import 'package:wizdesk/features/notes/domain/usecases/delete_note_usecase.dart';
import 'package:wizdesk/features/notes/domain/usecases/get_notes_usecase.dart';
import 'package:wizdesk/features/notes/domain/usecases/update_note_usecase.dart';
import 'package:wizdesk/features/notes/presentation/bloc/note_bloc.dart';
import 'package:wizdesk/features/notes/presentation/screens/note_editor_screen.dart';
import 'package:wizdesk/features/tasks/domain/entities/focus_session_entity.dart';
import 'package:wizdesk/features/tasks/domain/entities/task_category_entity.dart';
import 'package:wizdesk/features/tasks/domain/entities/task_entity.dart';
import 'package:wizdesk/features/tasks/domain/entities/task_enums.dart';
import 'package:wizdesk/features/tasks/domain/repositories/task_repository.dart';
import 'package:wizdesk/features/tasks/domain/usecases/add_task_usecase.dart';
import 'package:wizdesk/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:wizdesk/features/tasks/domain/usecases/get_categories_usecase.dart';
import 'package:wizdesk/features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'package:wizdesk/features/tasks/domain/usecases/update_task_usecase.dart';
import 'package:wizdesk/features/tasks/presentation/bloc/task_bloc.dart';

class MockNoteRepository implements NoteRepository {
  final List<NoteEntity> notes = [];

  @override
  Future<List<NoteEntity>> getNotes() async => List.from(notes);
  @override
  Future<NoteEntity?> getNoteById(String id) async =>
      notes.firstWhere((n) => n.id == id);
  @override
  Future<List<NoteEntity>> getNotesForTask(String taskId) async =>
      notes.where((n) => n.taskId == taskId).toList();
  @override
  Future<void> saveNote(NoteEntity note) async {
    final i = notes.indexWhere((n) => n.id == note.id);
    if (i != -1) {
      notes[i] = note;
    } else {
      notes.add(note);
    }
  }
  @override
  Future<void> deleteNote(String id) async =>
      notes.removeWhere((n) => n.id == id);
}

class MockTaskRepository implements TaskRepository {
  final List<TaskEntity> tasks = [];
  final List<TaskCategoryEntity> categories = [];
  @override
  Future<List<TaskEntity>> getTasks() async => List.from(tasks);
  @override
  Future<TaskEntity?> getTaskById(String id) async =>
      tasks.firstWhere((t) => t.id == id);
  @override
  Future<void> addTask(TaskEntity task) async => tasks.add(task);
  @override
  Future<void> updateTask(TaskEntity task) async {}
  @override
  Future<void> deleteTask(String id) async =>
      tasks.removeWhere((t) => t.id == id);
  @override
  Future<void> updateTaskStatus(String id, TaskStatus s) async {}
  @override
  Future<List<TaskCategoryEntity>> getCategories() async =>
      List.from(categories);
  @override
  Future<void> addCategory(TaskCategoryEntity c) async => categories.add(c);
  @override
  Future<void> deleteCategory(String id) async =>
      categories.removeWhere((c) => c.id == id);
  @override
  Future<void> logFocusSession(FocusSessionEntity s) async {}
  @override
  Future<List<FocusSessionEntity>> getFocusSessions() async => [];
}

void main() {
  late MockNoteRepository noteRepo;
  late MockTaskRepository taskRepo;
  late NoteBloc noteBloc;
  late TaskBloc taskBloc;

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    noteRepo = MockNoteRepository();
    taskRepo = MockTaskRepository();

    noteBloc = NoteBloc(
      getNotesUseCase: GetNotesUseCase(noteRepo),
      addNoteUseCase: AddNoteUseCase(noteRepo),
      updateNoteUseCase: UpdateNoteUseCase(noteRepo),
      deleteNoteUseCase: DeleteNoteUseCase(noteRepo),
    );

    taskBloc = TaskBloc(
      getTasksUseCase: GetTasksUseCase(taskRepo),
      addTaskUseCase: AddTaskUseCase(taskRepo),
      updateTaskUseCase: UpdateTaskUseCase(taskRepo),
      deleteTaskUseCase: DeleteTaskUseCase(taskRepo),
      getCategoriesUseCase: GetCategoriesUseCase(taskRepo),
    );
  });

  tearDown(() {
    noteBloc.close();
    taskBloc.close();
  });

  Widget buildTestWidget({NoteEntity? noteToEdit, String? initialTaskId}) {
    return ScreenUtilInit(
      designSize: const Size(AppConstants.designWidth, AppConstants.designHeight),
      minTextAdapt: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<NoteBloc>.value(value: noteBloc),
            BlocProvider<TaskBloc>.value(value: taskBloc),
          ],
          child: MaterialApp(
            home: NoteEditorScreen(
              noteToEdit: noteToEdit,
              initialTaskId: initialTaskId,
            ),
          ),
        );
      },
    );
  }

  testWidgets('NoteEditorScreen renders inputs and creates new note',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('New Note'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2)); // Title & Content

    // Enter title & content
    await tester.enterText(find.byType(TextField).first, 'Meeting Notes');
    await tester.enterText(
        find.byType(TextField).last, 'Discussed Q4 roadmap and design review.');
    await tester.pump();

    // Tap Save button
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(noteRepo.notes.length, 1);
    expect(noteRepo.notes.first.title, 'Meeting Notes');
    expect(noteRepo.notes.first.content,
        'Discussed Q4 roadmap and design review.');
  });

  testWidgets('NoteEditorScreen displays attached task card when linked',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final existingNote = NoteEntity(
      id: 'n_attached',
      title: 'Design System Notes',
      content: 'Tokens defined for Cyberpunk dark mode.',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      taskId: 'task_ui_1',
      taskTitle: 'Build Design System',
      isDateSpecific: true,
    );

    await tester.pumpWidget(buildTestWidget(noteToEdit: existingNote));
    await tester.pumpAndSettle();

    expect(find.text('View Note'), findsOneWidget);
    expect(find.text('Attached Task'), findsOneWidget);
    expect(find.text('Build Design System'), findsOneWidget);
    expect(find.text('Single Date Only'), findsOneWidget);
  });
}
