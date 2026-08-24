import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/constants/app_constants.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'core/theme/app_typography.dart';
import 'core/utils/app_bloc_observer.dart';
import 'features/analytics/presentation/bloc/analytics_bloc.dart';
import 'features/focus/presentation/bloc/focus_bloc.dart';
import 'features/navigation/presentation/screens/main_navigation_screen.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/settings/presentation/bloc/settings_event.dart';
import 'features/settings/presentation/bloc/settings_state.dart';
import 'features/tasks/presentation/bloc/task_bloc.dart';
import 'features/tasks/presentation/bloc/task_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set up BLoC observer for debugging
  Bloc.observer = AppBlocObserver();

  // Initialize dependencies
  await di.initServiceLocator();

  runApp(const WizDeskApp());
}

class WizDeskApp extends StatelessWidget {
  const WizDeskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(AppConstants.designWidth, AppConstants.designHeight),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<TaskBloc>(
              create: (context) =>
                  di.sl<TaskBloc>()..add(const LoadTasksEvent()),
            ),
            BlocProvider<FocusBloc>(
              create: (context) => di.sl<FocusBloc>(),
            ),
            BlocProvider<AnalyticsBloc>(
              create: (context) => di.sl<AnalyticsBloc>(),
            ),
            BlocProvider<SettingsBloc>(
              create: (context) =>
                  di.sl<SettingsBloc>()..add(const LoadSettingsEvent()),
            ),
          ],
          child: BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, settingsState) {
              if (settingsState is SettingsLoaded) {
                AppTypography.currentFontFamily =
                    settingsState.preferences.fontFamily;
              }
              return MaterialApp(
                title: AppConstants.appName,
                debugShowCheckedModeBanner: false,
                theme: AppTheme.darkTheme,
                home: child,
              );
            },
          ),
        );
      },
      child: const MainNavigationScreen(),
    );
  }
}
