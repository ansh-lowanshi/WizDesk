import 'package:equatable/equatable.dart';
import '../../domain/entities/note_entity.dart';

abstract class NoteEvent extends Equatable {
  const NoteEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotesEvent extends NoteEvent {
  const LoadNotesEvent();
}

class AddNoteEvent extends NoteEvent {
  final NoteEntity note;

  const AddNoteEvent(this.note);

  @override
  List<Object?> get props => [note];
}

class UpdateNoteEvent extends NoteEvent {
  final NoteEntity note;

  const UpdateNoteEvent(this.note);

  @override
  List<Object?> get props => [note];
}

class DeleteNoteEvent extends NoteEvent {
  final String id;

  const DeleteNoteEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class ToggleNotePinEvent extends NoteEvent {
  final String id;

  const ToggleNotePinEvent(this.id);

  @override
  List<Object?> get props => [id];
}
