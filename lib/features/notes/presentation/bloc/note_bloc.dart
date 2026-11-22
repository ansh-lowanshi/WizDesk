import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/add_note_usecase.dart';
import '../../domain/usecases/delete_note_usecase.dart';
import '../../domain/usecases/get_notes_usecase.dart';
import '../../domain/usecases/update_note_usecase.dart';
import 'note_event.dart';
import 'note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final GetNotesUseCase getNotesUseCase;
  final AddNoteUseCase addNoteUseCase;
  final UpdateNoteUseCase updateNoteUseCase;
  final DeleteNoteUseCase deleteNoteUseCase;

  NoteBloc({
    required this.getNotesUseCase,
    required this.addNoteUseCase,
    required this.updateNoteUseCase,
    required this.deleteNoteUseCase,
  }) : super(const NoteInitial()) {
    on<LoadNotesEvent>(_onLoadNotes);
    on<AddNoteEvent>(_onAddNote);
    on<UpdateNoteEvent>(_onUpdateNote);
    on<DeleteNoteEvent>(_onDeleteNote);
    on<ToggleNotePinEvent>(_onToggleNotePin);
  }

  Future<void> _onLoadNotes(
    LoadNotesEvent event,
    Emitter<NoteState> emit,
  ) async {
    emit(const NoteLoading());
    try {
      final notes = await getNotesUseCase(const NoParams());
      emit(NoteLoaded(notes));
    } catch (e) {
      emit(NoteError('Failed to load notes: $e'));
    }
  }

  Future<void> _onAddNote(
    AddNoteEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      await addNoteUseCase(event.note);
      final notes = await getNotesUseCase(const NoParams());
      emit(NoteLoaded(notes));
    } catch (e) {
      emit(NoteError('Failed to save note: $e'));
    }
  }

  Future<void> _onUpdateNote(
    UpdateNoteEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      await updateNoteUseCase(event.note);
      final notes = await getNotesUseCase(const NoParams());
      emit(NoteLoaded(notes));
    } catch (e) {
      emit(NoteError('Failed to update note: $e'));
    }
  }

  Future<void> _onDeleteNote(
    DeleteNoteEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      await deleteNoteUseCase(event.id);
      final notes = await getNotesUseCase(const NoParams());
      emit(NoteLoaded(notes));
    } catch (e) {
      emit(NoteError('Failed to delete note: $e'));
    }
  }

  Future<void> _onToggleNotePin(
    ToggleNotePinEvent event,
    Emitter<NoteState> emit,
  ) async {
    if (state is! NoteLoaded) return;
    final currentState = state as NoteLoaded;
    final noteIndex = currentState.allNotes.indexWhere((n) => n.id == event.id);
    if (noteIndex == -1) return;

    final targetNote = currentState.allNotes[noteIndex];
    final updatedNote = targetNote.copyWith(isPinned: !targetNote.isPinned);

    try {
      await updateNoteUseCase(updatedNote);
      final notes = await getNotesUseCase(const NoParams());
      emit(NoteLoaded(notes));
    } catch (e) {
      emit(NoteError('Failed to pin/unpin note: $e'));
    }
  }
}
