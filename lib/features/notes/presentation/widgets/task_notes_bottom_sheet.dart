import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../domain/entities/note_entity.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_event.dart';
import '../bloc/note_state.dart';
import '../screens/note_editor_screen.dart';
import 'note_card.dart';

/// Bottom sheet displaying all notes attached to a specific task
class TaskNotesBottomSheet extends StatelessWidget {
  final TaskEntity task;
  final DateTime? date;

  const TaskNotesBottomSheet({
    super.key,
    required this.task,
    this.date,
  });

  static Future<void> show(
    BuildContext context, {
    required TaskEntity task,
    DateTime? date,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskNotesBottomSheet(task: task, date: date),
    );
  }

  void _openAddNote(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NoteEditorScreen(
          initialTaskId: task.id,
          initialTaskTitle: task.title,
          initialDate: date ?? DateTime.now(),
          initialIsDateSpecific: date != null,
        ),
      ),
    );
  }

  void _openEditNote(BuildContext context, NoteEntity note) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NoteEditorScreen(
          noteToEdit: note,
          initialDate: date,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            border: Border.all(color: AppColors.border, width: 1.2),
          ),
          child: Column(
            children: [
              SizedBox(height: 10.h),
              // Handle
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withAlpha(120),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 14.h),

              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.notes_rounded,
                                color: AppColors.accentCyan,
                                size: 20.r,
                              ),
                              SizedBox(width: 8.w),
                              Flexible(
                                child: Text(
                                  'Notes for Task',
                                  style: AppTypography.heading3.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            task.title,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _openAddNote(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                      ),
                      icon: Icon(Icons.add_rounded,
                          size: 16.r, color: Colors.white),
                      label: Text(
                        'Add Note',
                        style: AppTypography.buttonSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Divider(
                color: AppColors.border.withAlpha(120),
                height: 24.h,
              ),

              // Notes list
              Expanded(
                child: BlocBuilder<NoteBloc, NoteState>(
                  builder: (context, state) {
                    if (state is! NoteLoaded) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accentCyan,
                        ),
                      );
                    }

                    final taskNotes = state.getNotesForTask(task.id);

                    if (taskNotes.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.note_alt_outlined,
                              size: 44.r,
                              color: AppColors.textMuted,
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              'No notes attached yet',
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Add standalone thoughts or daily logs for this task.',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            ElevatedButton.icon(
                              onPressed: () => _openAddNote(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              icon: const Icon(Icons.add_rounded,
                                  color: Colors.white),
                              label: const Text('Create First Note',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      controller: scrollController,
                      padding: EdgeInsets.symmetric(
                        horizontal: 18.w,
                        vertical: 8.h,
                      ),
                      itemCount: taskNotes.length,
                      separatorBuilder: (_, _) => SizedBox(height: 10.h),
                      itemBuilder: (context, index) {
                        final note = taskNotes[index];
                        return NoteCard(
                          note: note,
                          onTap: () => _openEditNote(context, note),
                          onDelete: () {
                            context
                                .read<NoteBloc>()
                                .add(DeleteNoteEvent(note.id));
                          },
                          onTogglePin: () {
                            context
                                .read<NoteBloc>()
                                .add(ToggleNotePinEvent(note.id));
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
