import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/bloc/theme_bloc.dart';
import '../../../../core/theme/bloc/theme_state.dart';
import '../../../analytics/presentation/screens/analytics_screen.dart';
import '../../../calendar/presentation/screens/calendar_screen.dart';
import '../../../focus/presentation/screens/focus_timer_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/presentation/screens/add_edit_task_screen.dart';
import '../../../tasks/presentation/screens/home_dashboard_screen.dart';
import '../../../focus/presentation/bloc/focus_bloc.dart';
import '../../../focus/presentation/bloc/focus_state.dart';
import '../../../tasks/presentation/bloc/task_bloc.dart';
import '../../../tasks/presentation/bloc/task_event.dart';
import '../widgets/app_bottom_nav_bar.dart';

/// Main Root Navigation Screen with Persistent IndexedStack & 5-Tab Floating Nav Bar
class MainNavigationScreen extends StatefulWidget {
  final int initialTabIndex;

  const MainNavigationScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;
  TaskEntity? _focusedTask;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
  }

  void _onTabSelected(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _openAddTaskModal() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AddEditTaskScreen(),
      ),
    );
  }

  void _startTaskFocus(TaskEntity task) {
    setState(() {
      _focusedTask = task;
      _currentIndex = 2; // Switch to Focus tab (Index 2)
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: BlocListener<FocusBloc, FocusState>(
            listenWhen: (previous, current) =>
                previous.activeTask?.spentMinutes != current.activeTask?.spentMinutes &&
                current.activeTask != null,
            listener: (context, state) {
              if (state.activeTask != null) {
                context.read<TaskBloc>().add(UpdateTaskEvent(state.activeTask!));
              }
            },
            child: Scaffold(
              backgroundColor: AppColors.background,
              extendBody: true,
              body: IndexedStack(
                index: _currentIndex,
                children: [
                  // Tab 0: Today (Home Tasks Dashboard)
                  HomeDashboardScreen(
                    onNavigateToAddTask: _openAddTaskModal,
                    onStartTaskFocus: _startTaskFocus,
                  ),

                  // Tab 1: Calendar (Month Grid & Daily Task Schedule)
                  CalendarScreen(
                    onStartTaskFocus: _startTaskFocus,
                  ),

                  // Tab 2: Focus Timer Hub
                  FocusTimerScreen(
                    key: ValueKey('focus_tab_${_focusedTask?.id ?? 'idle'}'),
                    initialTask: _focusedTask,
                  ),

                  // Tab 3: Analytics & Insights
                  const AnalyticsScreen(),

                  // Tab 4: Profile & Settings
                  const SettingsScreen(),
                ],
              ),
              bottomNavigationBar: AppBottomNavBar(
                currentIndex: _currentIndex,
                onTabSelected: _onTabSelected,
              ),
            ),
          ),
        );
      },
    );
  }
}
