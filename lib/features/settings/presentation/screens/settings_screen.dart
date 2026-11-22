import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glassmorphic_card.dart';
import '../../../../core/widgets/responsive_wrapper.dart';
import '../../../tasks/presentation/bloc/task_bloc.dart';
import '../../../tasks/presentation/bloc/task_event.dart';
import '../../../tasks/presentation/bloc/task_state.dart';
import '../../../tasks/presentation/widgets/manage_categories_sheet.dart';
import '../../domain/models/user_preferences_model.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../widgets/about_app_section.dart';
import '../widgets/data_management_section.dart';
import '../widgets/day_reset_section.dart';
import '../widgets/goals_settings_section.dart';
import '../widgets/language_selector_section.dart';
import '../widgets/profile_hero_card.dart';
import '../widgets/timer_settings_section.dart';

/// Full Settings, Profile & Timer Customization Screen
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<SettingsBloc>();
    if (bloc.state is! SettingsLoaded) {
      bloc.add(const LoadSettingsEvent());
    }
  }

  void _openEditProfileDialog(
    BuildContext context,
    UserPreferencesModel preferences,
  ) {
    final l10n = context.l10n;
    final nameController = TextEditingController(text: preferences.userName);
    final titleController = TextEditingController(text: preferences.userTitle);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.r),
        ),
        title: Text(l10n.editProfile, style: AppTypography.heading3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.displayName, style: AppTypography.titleSmall),
            SizedBox(height: 6.h),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: l10n.displayName,
                prefixIcon: const Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.accentCyan,
                ),
              ),
            ),
            SizedBox(height: 14.h),
            Text(l10n.titleRole, style: AppTypography.titleSmall),
            SizedBox(height: 6.h),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: l10n.titleRole,
                prefixIcon: const Icon(
                  Icons.badge_outlined,
                  color: AppColors.accentCyan,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              l10n.cancel,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              final newName = nameController.text.trim();
              final newTitle = titleController.text.trim();
              if (newName.isNotEmpty) {
                context.read<SettingsBloc>().add(
                  UpdateUserProfileEvent(
                    userName: newName,
                    userTitle: newTitle.isNotEmpty
                        ? newTitle
                        : 'Focus Architect',
                  ),
                );
              }
              Navigator.of(ctx).pop();
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18.r,
                  color: AppColors.textPrimary,
                ),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: Text(l10n.settingsAndProfile, style: AppTypography.heading3),
      ),
      body: SafeArea(
        child: ResponsiveWrapper(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: BlocConsumer<SettingsBloc, SettingsState>(
            listener: (context, state) {
              if (state is SettingsLoaded) {
                if (state.successMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.successMessage!),
                      backgroundColor: AppColors.primary,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              } else if (state is SettingsError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is SettingsLoading && state is! SettingsLoaded) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.accentCyan),
                );
              }

              final preferences = state is SettingsLoaded
                  ? state.preferences
                  : const UserPreferencesModel();

              return BlocBuilder<TaskBloc, TaskState>(
                builder: (context, taskState) {
                  int totalCompletedTasks = 0;
                  int totalFocusMinutes = 0;

                  if (taskState is TaskLoaded) {
                    totalCompletedTasks = taskState.completedTasksCount;
                    totalFocusMinutes = taskState.allTasks.fold<int>(
                      0,
                      (sum, t) => sum + t.spentMinutes,
                    );
                  }

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Profile Banner
                        ProfileHeroCard(
                          preferences: preferences,
                          totalCompletedTasks: totalCompletedTasks,
                          totalFocusMinutes: totalFocusMinutes,
                          onEditProfile: () =>
                              _openEditProfileDialog(context, preferences),
                        ),

                        SizedBox(height: 20.h),

                        // 2. Language Selector Section
                        const LanguageSelectorSection(),

                        SizedBox(height: 20.h),

                        // 3. Timer Customization Section
                        TimerSettingsSection(
                          preferences: preferences,
                          onChanged: (updated) {
                            context.read<SettingsBloc>().add(
                              UpdateTimerSettingsEvent(
                                workDurationMinutes:
                                    updated.workDurationMinutes,
                                shortBreakMinutes: updated.shortBreakMinutes,
                                longBreakMinutes: updated.longBreakMinutes,
                                longBreakInterval: updated.longBreakInterval,
                                autoStartBreaks: updated.autoStartBreaks,
                                autoStartPomodoros: updated.autoStartPomodoros,
                              ),
                            );
                          },
                        ),

                        // SizedBox(height: 20.h),

                        // 3. Appearance & Theme Switcher Section
                        // ThemeSwitcherSection(
                        //   selectedThemeMode: preferences.themeMode,
                        //   onThemeSelected: (theme) {
                        //     context
                        //         .read<ThemeBloc>()
                        //         .add(SetThemeModeEvent(theme));
                        //     context
                        //         .read<SettingsBloc>()
                        //         .add(UpdateThemeModeEvent(theme));
                        //   },
                        // ),
                        SizedBox(height: 20.h),

                        // 4. Day Rollover / Reset Time Section
                        DayResetSection(
                          selectedResetHour: preferences.dayResetHour,
                          onResetHourSelected: (hour) {
                            context.read<SettingsBloc>().add(
                              UpdateDayResetHourEvent(hour),
                            );
                          },
                        ),

                        SizedBox(height: 20.h),

                        // 5. Productivity Targets Section
                        GoalsSettingsSection(
                          preferences: preferences,
                          onChanged: (updated) {
                            context.read<SettingsBloc>().add(
                              UpdateGoalsEvent(
                                dailyTaskGoal: updated.dailyTaskGoal,
                                dailyFocusMinutesGoal:
                                    updated.dailyFocusMinutesGoal,
                              ),
                            );
                          },
                        ),

                        SizedBox(height: 20.h),

                        // 6. Category Management
                        GlassmorphicCard(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                          child: InkWell(
                            key: const ValueKey(
                              'settings_manage_categories_btn',
                            ),
                            onTap: () => ManageCategoriesSheet.show(context),
                            borderRadius: BorderRadius.circular(16.r),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10.r),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentCyan.withAlpha(25),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.accentCyan.withAlpha(60),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.category_rounded,
                                    color: AppColors.accentCyan,
                                    size: 20.r,
                                  ),
                                ),
                                SizedBox(width: 14.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.taskCategories,
                                        style: AppTypography.titleSmall
                                            .copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        l10n.taskCategoriesSubtitle,
                                        style: AppTypography.caption.copyWith(
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 14.r,
                                  color: AppColors.textMuted,
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 20.h),

                        // 7. Data Management & Danger Zone
                        DataManagementSection(
                          onResetSettings: () {
                            context.read<SettingsBloc>().add(
                              const ResetSettingsEvent(),
                            );
                          },
                          onClearAllData: () {
                            context.read<SettingsBloc>().add(
                              const ClearAllDataConfirmedEvent(),
                            );
                            // Refresh tasks after wipe
                            context.read<TaskBloc>().add(
                              const LoadTasksEvent(),
                            );
                          },
                        ),

                        SizedBox(height: 20.h),

                        // 8. About App Section
                        const AboutAppSection(),

                        SizedBox(height: 90.h),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
