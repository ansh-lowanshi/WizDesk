import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/constants/app_constants.dart';
import 'core/di/injection_container.dart' as di;
import 'core/localization/app_language.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/bloc/locale_bloc.dart';
import 'core/localization/bloc/locale_event.dart';
import 'core/localization/bloc/locale_state.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/bloc/theme_bloc.dart';
import 'core/theme/bloc/theme_event.dart';
import 'core/theme/bloc/theme_state.dart';
import 'core/utils/app_bloc_observer.dart';
import 'features/analytics/presentation/bloc/analytics_bloc.dart';
import 'features/focus/presentation/bloc/focus_bloc.dart';
import 'features/navigation/presentation/screens/main_navigation_screen.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/settings/presentation/bloc/settings_event.dart';
import 'features/notes/presentation/bloc/note_bloc.dart';
import 'features/notes/presentation/bloc/note_event.dart';
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
      designSize: const Size(
        AppConstants.designWidth,
        AppConstants.designHeight,
      ),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<LocaleBloc>(
              create: (context) =>
                  di.sl<LocaleBloc>()..add(const InitLocaleEvent()),
            ),
            BlocProvider<ThemeBloc>(
              create: (context) =>
                  di.sl<ThemeBloc>()..add(const InitThemeEvent()),
            ),
            BlocProvider<TaskBloc>(
              create: (context) =>
                  di.sl<TaskBloc>()..add(const LoadTasksEvent()),
            ),
            BlocProvider<FocusBloc>(create: (context) => di.sl<FocusBloc>()),
            BlocProvider<AnalyticsBloc>(
              create: (context) => di.sl<AnalyticsBloc>(),
            ),
            BlocProvider<SettingsBloc>(
              create: (context) =>
                  di.sl<SettingsBloc>()..add(const LoadSettingsEvent()),
            ),
            BlocProvider<NoteBloc>(
              create: (context) =>
                  di.sl<NoteBloc>()..add(const LoadNotesEvent()),
            ),
          ],
          child: BlocBuilder<LocaleBloc, LocaleState>(
            builder: (context, localeState) {
              return BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, themeState) {
                  AppColors.isDarkMode = themeState.isDarkMode;
                  return MaterialApp(
                    title: AppConstants.appName,
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.lightTheme,
                    darkTheme: AppTheme.darkTheme,
                    themeMode: themeState.themeMode.toFlutterThemeMode,
                    locale: localeState.locale,
                    supportedLocales: AppLanguage.supportedLocales,
                    localizationsDelegates: const [
                      AppLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    home: child,
                  );
                },
              );
            },
          ),
        );
      },
      child: const MainNavigationScreen(),
    );
  }
}
