import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../domain/entities/note_entity.dart';

class NoteCard extends StatelessWidget {
  final NoteEntity note;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onTogglePin;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.onDelete,
    this.onTogglePin,
  });

  Future<void> _confirmAndDelete(BuildContext context) async {
    if (onDelete == null) return;
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

    if (confirmed == true && onDelete != null) {
      onDelete!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final noteColor = note.colorValue != null
        ? Color(note.colorValue!)
        : AppColors.accentCyan;

    final formattedTime = DateFormat('MMM d • h:mm a').format(note.updatedAt);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: GlassmorphicCard(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        borderRadius: 18.r,
        borderColor: note.isPinned
            ? AppColors.accentCyan.withAlpha(120)
            : AppColors.border,
        backgroundColor: AppColors.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Pin / Color Indicator + Title + More Popup
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Color Dot
                Container(
                  width: 8.r,
                  height: 8.r,
                  margin: EdgeInsets.only(top: 6.h, right: 10.w),
                  decoration: BoxDecoration(
                    color: noteColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: noteColor.withAlpha(140),
                        blurRadius: 6,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),

                // Note Title
                Expanded(
                  child: Text(
                    note.title.trim().isNotEmpty ? note.title : 'Untitled Note',
                    style: AppTypography.heading3.copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                if (note.isPinned) ...[
                  SizedBox(width: 6.w),
                  Icon(
                    Icons.push_pin_rounded,
                    size: 16.r,
                    color: AppColors.accentCyan,
                  ),
                ],

                SizedBox(width: 4.w),

                // 3-dot menu
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_horiz_rounded,
                    size: 18.r,
                    color: AppColors.textSecondary,
                  ),
                  color: AppColors.surfaceElevated,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    side: BorderSide(color: AppColors.border),
                  ),
                  onSelected: (value) {
                    if (value == 'open') {
                      onTap();
                    } else if (value == 'pin' && onTogglePin != null) {
                      onTogglePin!();
                    } else if (value == 'delete') {
                      _confirmAndDelete(context);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'open',
                      child: Row(
                        children: [
                          Icon(Icons.fullscreen_rounded,
                              size: 18.r, color: AppColors.accentCyan),
                          SizedBox(width: 8.w),
                          Text('Open Full Screen',
                              style: AppTypography.bodyMedium),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'pin',
                      child: Row(
                        children: [
                          Icon(
                            note.isPinned
                                ? Icons.push_pin_outlined
                                : Icons.push_pin_rounded,
                            size: 18.r,
                            color: AppColors.textPrimary,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            note.isPinned ? 'Unpin' : 'Pin to Top',
                            style: AppTypography.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded,
                              size: 18.r, color: AppColors.error),
                          SizedBox(width: 8.w),
                          Text(
                            'Delete',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Content preview (if present)
            if (note.content.trim().isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(
                note.content.trim(),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                  fontSize: 13.sp,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            SizedBox(height: 12.h),

            // Bottom Badges: Task Link Chip + Timestamp
            Row(
              children: [
                // Attached Task Chip (if linked)
                if (note.hasAttachedTask) ...[
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: note.isDateSpecific
                            ? AppColors.primary.withAlpha(40)
                            : AppColors.accentCyan.withAlpha(35),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: note.isDateSpecific
                              ? AppColors.primary.withAlpha(120)
                              : AppColors.accentCyan.withAlpha(120),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            note.isDateSpecific
                                ? Icons.calendar_today_rounded
                                : Icons.all_inclusive_rounded,
                            size: 11.r,
                            color: note.isDateSpecific
                                ? AppColors.primaryLight
                                : AppColors.accentCyan,
                          ),
                          SizedBox(width: 4.w),
                          Flexible(
                            child: Text(
                              note.taskTitle ?? 'Task',
                              style: AppTypography.caption.copyWith(
                                color: note.isDateSpecific
                                    ? AppColors.primaryLight
                                    : AppColors.accentCyan,
                                fontWeight: FontWeight.w600,
                                fontSize: 11.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            note.isDateSpecific ? '• Date' : '• Task',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                ],

                const Spacer(),

                // Timestamp
                Text(
                  formattedTime,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
