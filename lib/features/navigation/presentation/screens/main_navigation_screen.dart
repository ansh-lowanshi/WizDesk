import 'package:flutter/material.dart';
import '../../../analytics/presentation/screens/analytics_screen.dart';
import '../../../focus/presentation/screens/focus_timer_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/presentation/screens/add_edit_task_screen.dart';
import '../../../tasks/presentation/screens/home_dashboard_screen.dart';
import '../widgets/app_bottom_nav_bar.dart';

/// Main Root Navigation Screen with Persistent IndexedStack & Floating Nav Bar
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
      _currentIndex = 1; // Switch to Focus tab
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            // Tab 0: Home Tasks Dashboard
            HomeDashboardScreen(
              onNavigateToAddTask: _openAddTaskModal,
              onStartTaskFocus: _startTaskFocus,
            ),

            // Tab 1: Focus Timer Hub
            FocusTimerScreen(
              key: ValueKey('focus_tab_${_focusedTask?.id ?? 'idle'}'),
              initialTask: _focusedTask,
            ),

            // Tab 2: Analytics & Insights
            const AnalyticsScreen(),

            // Tab 3: Profile & Settings
            const SettingsScreen(),
          ],
        ),
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: _currentIndex,
          onTabSelected: _onTabSelected,
          onQuickAdd: _openAddTaskModal,
        ),
      ),
    );
  }
}
