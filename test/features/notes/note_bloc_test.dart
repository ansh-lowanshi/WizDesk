import 'package:flutter_test/flutter_test.dart';
import 'package:wizdesk/features/notes/domain/entities/note_entity.dart';
import 'package:wizdesk/features/notes/domain/repositories/note_repository.dart';
import 'package:wizdesk/features/notes/domain/usecases/add_note_usecase.dart';
import 'package:wizdesk/features/notes/domain/usecases/delete_note_usecase.dart';
import 'package:wizdesk/features/notes/domain/usecases/get_notes_usecase.dart';
import 'package:wizdesk/features/notes/domain/usecases/update_note_usecase.dart';
import 'package:wizdesk/features/notes/presentation/bloc/note_bloc.dart';
import 'package:wizdesk/features/notes/presentation/bloc/note_event.dart';
import 'package:wizdesk/features/notes/presentation/bloc/note_state.dart';

class MockNoteRepository implements NoteRepository {
  final List<NoteEntity> _notes = [];

  @override
  Future<List<NoteEntity>> getNotes() async => List.from(_notes);

  @override
  Future<NoteEntity?> getNoteById(String id) async {
    try {
      return _notes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<NoteEntity>> getNotesForTask(String taskId) async {
    return _notes.where((n) => n.taskId == taskId).toList();
  }

  @override
  Future<void> saveNote(NoteEntity note) async {
    final idx = _notes.indexWhere((n) => n.id == note.id);
    if (idx != -1) {
      _notes[idx] = note;
    } else {
      _notes.add(note);
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
  }
}

void main() {
  late MockNoteRepository repo;
  late NoteBloc bloc;

  setUp(() {
    repo = MockNoteRepository();
    bloc = NoteBloc(
      getNotesUseCase: GetNotesUseCase(repo),
      addNoteUseCase: AddNoteUseCase(repo),
      updateNoteUseCase: UpdateNoteUseCase(repo),
      deleteNoteUseCase: DeleteNoteUseCase(repo),
    );
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state is NoteInitial', () {
    expect(bloc.state, const NoteInitial());
  });

  test('LoadNotesEvent emits NoteLoading and NoteLoaded', () async {
    final now = DateTime(2026, 10, 13);
    repo._notes.add(
      NoteEntity(
        id: 'n1',
        title: 'Title',
        content: 'Content',
        createdAt: now,
        updatedAt: now,
        date: now,
      ),
    );

    bloc.add(const LoadNotesEvent());

    await expectLater(
      bloc.stream,
      emitsInOrder([
        const NoteLoading(),
        isA<NoteLoaded>().having(
          (s) => s.allNotes.length,
          'notes count',
          1,
        ),
      ]),
    );
  });

  test('AddNoteEvent saves note and refreshes state', () async {
    final now = DateTime(2026, 10, 13);
    final newNote = NoteEntity(
      id: 'n2',
      title: 'New Note',
      content: 'Note Body',
      createdAt: now,
      updatedAt: now,
      date: now,
      taskId: 'task_abc',
      isDateSpecific: true,
    );

    bloc.add(AddNoteEvent(newNote));

    await expectLater(
      bloc.stream,
      emitsThrough(
        isA<NoteLoaded>().having(
          (s) => s.allNotes.any((n) => n.id == 'n2'),
          'contains note n2',
          isTrue,
        ),
      ),
    );
  });

  test('ToggleNotePinEvent toggles isPinned flag', () async {
    final now = DateTime(2026, 10, 13);
    final initialNote = NoteEntity(
      id: 'n_pin',
      title: 'Pin Test',
      content: 'Body',
      createdAt: now,
      updatedAt: now,
      isPinned: false,
    );
    repo._notes.add(initialNote);

    bloc.add(const LoadNotesEvent());
    await bloc.stream.firstWhere((s) => s is NoteLoaded);

    bloc.add(const ToggleNotePinEvent('n_pin'));

    await expectLater(
      bloc.stream,
      emitsThrough(
        isA<NoteLoaded>().having(
          (s) => s.allNotes.firstWhere((n) => n.id == 'n_pin').isPinned,
          'note is pinned',
          isTrue,
        ),
      ),
    );
  });
}
