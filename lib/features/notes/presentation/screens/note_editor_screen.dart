import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../../../core/widgets/responsive_wrapper.dart';
import '../../domain/entities/note_entity.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_event.dart';
import '../widgets/attach_task_sheet.dart';

/// Fullscreen Note View and Editor Screen
class NoteEditorScreen extends StatefulWidget {
  final NoteEntity? noteToEdit;
  final DateTime? initialDate;
  final String? initialTaskId;
  final String? initialTaskTitle;
  final bool initialIsDateSpecific;

  const NoteEditorScreen({
    super.key,
    this.noteToEdit,
    this.initialDate,
    this.initialTaskId,
    this.initialTaskTitle,
    this.initialIsDateSpecific = true,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final FocusNode _contentFocusNode;

  late DateTime _selectedDate;
  String? _attachedTaskId;
  String? _attachedTaskTitle;
  late bool _isDateSpecific;
  int? _selectedColor;
  late bool _isPinned;

  bool _isDirty = false;

  final List<int> _paletteColors = const [
    0xFF3874FF, // Primary Blue
    0xFF00F0FF, // Accent Cyan
    0xFF7F56D9, // Purple
    0xFF6366F1, // Indigo
    0xFFFFB020, // Amber
    0xFFFF4D4D, // Rose / Coral
    0xFF10B981, // Emerald Green
  ];

  @override
  void initState() {
    super.initState();
    final note = widget.noteToEdit;

    _titleController = TextEditingController(text: note?.title ?? '');
    _contentController = TextEditingController(text: note?.content ?? '');
    _contentFocusNode = FocusNode();

    _selectedDate = note?.date ??
        note?.createdAt ??
        widget.initialDate ??
        DateTime.now();

    _attachedTaskId = note?.taskId ?? widget.initialTaskId;
    _attachedTaskTitle = note?.taskTitle ?? widget.initialTaskTitle;
    _isDateSpecific = note?.isDateSpecific ?? widget.initialIsDateSpecific;
    _selectedColor = note?.colorValue ?? _paletteColors.first;
    _isPinned = note?.isPinned ?? false;

    _titleController.addListener(_markDirty);
    _contentController.addListener(_markDirty);
  }

  void _markDirty() {
    if (!_isDirty) {
      setState(() => _isDirty = true);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: (AppColors.isDarkMode
                    ? const ColorScheme.dark()
                    : const ColorScheme.light())
                .copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surfaceElevated,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _isDirty = true;
      });
    }
  }

  Future<void> _openAttachTaskSheet() async {
    final result = await AttachTaskSheet.show(
      context,
      currentTaskId: _attachedTaskId,
      currentIsDateSpecific: _isDateSpecific,
      targetDate: _selectedDate,
    );

    if (result != null) {
      setState(() {
        if (result.task != null) {
          _attachedTaskId = result.task!.id;
          _attachedTaskTitle = result.task!.title;
          _isDateSpecific = result.isDateSpecific;
        } else {
          _attachedTaskId = null;
          _attachedTaskTitle = null;
        }
        _isDirty = true;
      });
    }
  }

  void _insertFormatting(String prefix, [String suffix = '']) {
    final text = _contentController.text;
    final selection = _contentController.selection;
    final start = selection.start >= 0 ? selection.start : text.length;
    final end = selection.end >= 0 ? selection.end : text.length;

    final selectedText = text.substring(start, end);
    final replacement = '$prefix$selectedText$suffix';

    final newText = text.replaceRange(start, end, replacement);
    _contentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: start + prefix.length + selectedText.length,
      ),
    );
    _markDirty();
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title or content for your note'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final now = DateTime.now();
    final isEditing = widget.noteToEdit != null;

    final note = NoteEntity(
      id: widget.noteToEdit?.id ?? const Uuid().v4(),
      title: title.isNotEmpty ? title : 'Untitled Note',
      content: content,
      createdAt: widget.noteToEdit?.createdAt ?? now,
      updatedAt: now,
      date: _selectedDate,
      taskId: _attachedTaskId,
      taskTitle: _attachedTaskTitle,
      isDateSpecific: _isDateSpecific,
      colorValue: _selectedColor,
      isPinned: _isPinned,
      tags: widget.noteToEdit?.tags ?? const [],
    );

    final noteBloc = context.read<NoteBloc>();
    if (isEditing) {
      noteBloc.add(UpdateNoteEvent(note));
    } else {
      noteBloc.add(AddNoteEvent(note));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEditing ? 'Note updated' : 'Note created'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.of(context).pop(note);
  }

  Future<void> _deleteNote() async {
    if (widget.noteToEdit == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: BorderSide(color: AppColors.border, width: 1.2),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(40),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: 22.r,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Delete Note',
                style: AppTypography.heading3.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete this note? This action cannot be undone.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: AppTypography.buttonMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Delete',
              style: AppTypography.buttonMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<NoteBloc>().add(DeleteNoteEvent(widget.noteToEdit!.id));
      Navigator.of(context).pop();
    }
  }

  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Note Color',
                style: AppTypography.heading3.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 16.h),
              Wrap(
                spacing: 16.w,
                runSpacing: 12.h,
                children: _paletteColors.map((colorVal) {
                  final color = Color(colorVal);
                  final isSelected = _selectedColor == colorVal;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = colorVal;
                        _isDirty = true;
                      });
                      Navigator.of(ctx).pop();
                    },
                    child: Container(
                      width: 42.r,
                      height: 42.r,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withAlpha(120),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 22,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat('EEE, MMM d, yyyy').format(_selectedDate);
    final isEditing = widget.noteToEdit != null;
    final activeColor = _selectedColor != null
        ? Color(_selectedColor!)
        : AppColors.accentCyan;

    final wordCount = _contentController.text.trim().isEmpty
        ? 0
        : _contentController.text.trim().split(RegExp(r'\s+')).length;
    final charCount = _contentController.text.length;

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldDiscard = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surfaceElevated,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.r),
              side: BorderSide(color: AppColors.border),
            ),
            title: Text('Unsaved Changes',
                style: AppTypography.heading3),
            content: Text(
              'You have unsaved changes. Do you want to discard them or save before leaving?',
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text('Discard',
                    style: AppTypography.buttonMedium
                        .copyWith(color: AppColors.error)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop(false);
                  _saveNote();
                },
                child: Text('Save',
                    style: AppTypography.buttonMedium
                        .copyWith(color: Colors.white)),
              ),
            ],
          ),
        );
        if ((shouldDiscard ?? false) && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20.r,
              color: AppColors.textPrimary,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(
            isEditing ? 'View Note' : 'New Note',
            style: AppTypography.heading3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            // Color picker button
            IconButton(
              icon: Container(
                width: 22.r,
                height: 22.r,
                decoration: BoxDecoration(
                  color: activeColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: activeColor.withAlpha(140),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              tooltip: 'Choose Color',
              onPressed: _showColorPicker,
            ),

            // Pin toggle button
            IconButton(
              icon: Icon(
                _isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                color: _isPinned
                    ? AppColors.accentCyan
                    : AppColors.textSecondary,
                size: 22.r,
              ),
              tooltip: _isPinned ? 'Unpin' : 'Pin',
              onPressed: () {
                setState(() {
                  _isPinned = !_isPinned;
                  _isDirty = true;
                });
              },
            ),

            // Delete button (if editing)
            if (isEditing)
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                  size: 22.r,
                ),
                tooltip: 'Delete Note',
                onPressed: _deleteNote,
              ),

            // Save button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              child: ElevatedButton(
                onPressed: _saveNote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_rounded, color: Colors.white, size: 18.r),
                    SizedBox(width: 4.w),
                    Text(
                      'Save',
                      style: AppTypography.buttonSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ResponsiveWrapper(
                  padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 6.h),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Associated Calendar Date Pill
                        Align(
                          alignment: Alignment.centerLeft,
                          child: InkWell(
                            onTap: _pickDate,
                            borderRadius: BorderRadius.circular(12.r),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: AppColors.border,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_month_rounded,
                                    size: 15.r,
                                    color: activeColor,
                                  ),
                                  SizedBox(width: 6.w),
                                  Flexible(
                                    child: Text(
                                      dateFormatted,
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Icon(
                                    Icons.arrow_drop_down_rounded,
                                    size: 18.r,
                                    color: AppColors.textMuted,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 12.h),

                        // 2. Task Attachment Card
                        if (_attachedTaskId != null)
                          GlassmorphicCard(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 10.h,
                            ),
                            borderRadius: 14.r,
                            borderColor: _isDateSpecific
                                ? AppColors.primaryLight.withAlpha(140)
                                : AppColors.accentCyan.withAlpha(140),
                            backgroundColor: _isDateSpecific
                                ? AppColors.primary.withAlpha(35)
                                : AppColors.accentCyan.withAlpha(25),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.assignment_turned_in_rounded,
                                      color: _isDateSpecific
                                          ? AppColors.primaryLight
                                          : AppColors.accentCyan,
                                      size: 18.r,
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Attached Task',
                                            style:
                                                AppTypography.caption.copyWith(
                                              color: AppColors.textMuted,
                                              fontSize: 10.sp,
                                            ),
                                          ),
                                          Text(
                                            _attachedTaskTitle ?? 'Task',
                                            style: AppTypography.bodyMedium
                                                .copyWith(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit_note_rounded,
                                        color: AppColors.textSecondary,
                                        size: 20.r,
                                      ),
                                      tooltip: 'Change Task',
                                      onPressed: _openAttachTaskSheet,
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.close_rounded,
                                        color: AppColors.error,
                                        size: 18.r,
                                      ),
                                      tooltip: 'Detach Task',
                                      onPressed: () {
                                        setState(() {
                                          _attachedTaskId = null;
                                          _attachedTaskTitle = null;
                                          _isDirty = true;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6.h),
                                // Scope Toggle
                                Wrap(
                                  spacing: 8.w,
                                  runSpacing: 6.h,
                                  children: [
                                    GestureDetector(
                                      onTap: () => setState(() {
                                        _isDateSpecific = true;
                                        _isDirty = true;
                                      }),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 4.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _isDateSpecific
                                              ? AppColors.primary
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(8.r),
                                          border: Border.all(
                                            color: _isDateSpecific
                                                ? AppColors.primary
                                                : AppColors.border,
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Text(
                                          'Single Date Only',
                                          style:
                                              AppTypography.caption.copyWith(
                                            color: _isDateSpecific
                                                ? Colors.white
                                                : AppColors.textMuted,
                                            fontWeight: _isDateSpecific
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            fontSize: 11.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => setState(() {
                                        _isDateSpecific = false;
                                        _isDirty = true;
                                      }),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 4.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: !_isDateSpecific
                                              ? AppColors.accentCyan
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(8.r),
                                          border: Border.all(
                                            color: !_isDateSpecific
                                                ? AppColors.accentCyan
                                                : AppColors.border,
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Text(
                                          'Throughout Task',
                                          style:
                                              AppTypography.caption.copyWith(
                                            color: !_isDateSpecific
                                                ? Colors.black
                                                : AppColors.textMuted,
                                            fontWeight: !_isDateSpecific
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            fontSize: 11.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        else
                          Align(
                            alignment: Alignment.centerLeft,
                            child: InkWell(
                              onTap: _openAttachTaskSheet,
                              borderRadius: BorderRadius.circular(12.r),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceElevated.withAlpha(120),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: AppColors.border.withAlpha(120),
                                    style: BorderStyle.solid,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.link_rounded,
                                      size: 16.r,
                                      color: AppColors.accentCyan,
                                    ),
                                    SizedBox(width: 6.w),
                                    Flexible(
                                      child: Text(
                                        'Attach Task (Optional)',
                                        style: AppTypography.caption.copyWith(
                                          color: AppColors.accentCyan,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        SizedBox(height: 16.h),

                        // 3. Note Title Input
                        TextField(
                          controller: _titleController,
                          style: AppTypography.heading2.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 22.sp,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Note Title...',
                            hintStyle: AppTypography.heading2.copyWith(
                              color: AppColors.textMuted.withAlpha(140),
                              fontWeight: FontWeight.w700,
                              fontSize: 22.sp,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          textInputAction: TextInputAction.next,
                        ),

                        Divider(
                          color: AppColors.border.withAlpha(100),
                          thickness: 1,
                          height: 24.h,
                        ),

                        // 4. Note Content Input (Expands full screen)
                        TextField(
                          controller: _contentController,
                          focusNode: _contentFocusNode,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            height: 1.5,
                            fontSize: 15.sp,
                          ),
                          maxLines: null,
                          minLines: 12,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            hintText:
                                'Start writing your notes, checklist, ideas, reflections...\n\nSupports bullet lists •\nCheckboxes [ ]\nHeadings #',
                            hintStyle: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textMuted.withAlpha(140),
                              height: 1.5,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Formatting Accessory Bar & Word/Char Counter
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  border: Border(
                    top: BorderSide(
                      color: AppColors.border,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildToolbarButton(
                              icon: Icons.check_box_outlined,
                              tooltip: 'Checkbox',
                              onPressed: () => _insertFormatting('[ ] '),
                            ),
                            _buildToolbarButton(
                              icon: Icons.format_list_bulleted_rounded,
                              tooltip: 'Bullet',
                              onPressed: () => _insertFormatting('• '),
                            ),
                            _buildToolbarButton(
                              icon: Icons.format_list_numbered_rounded,
                              tooltip: 'Numbered List',
                              onPressed: () => _insertFormatting('1. '),
                            ),
                            _buildToolbarButton(
                              icon: Icons.title_rounded,
                              tooltip: 'Heading',
                              onPressed: () => _insertFormatting('# '),
                            ),
                            _buildToolbarButton(
                              icon: Icons.format_bold_rounded,
                              tooltip: 'Bold',
                              onPressed: () => _insertFormatting('**', '**'),
                            ),
                            _buildToolbarButton(
                              icon: Icons.format_quote_rounded,
                              tooltip: 'Quote',
                              onPressed: () => _insertFormatting('> '),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '$wordCount w • $charCount c',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.all(6.r),
      constraints: const BoxConstraints(),
      icon: Icon(icon, size: 20.r, color: AppColors.textSecondary),
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }
}
