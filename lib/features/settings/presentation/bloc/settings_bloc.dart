import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/clear_all_data_usecase.dart';
import '../../domain/usecases/get_settings_usecase.dart';
import '../../domain/usecases/reset_settings_usecase.dart';
import '../../domain/usecases/save_settings_usecase.dart';
import 'settings_event.dart';
import 'settings_state.dart';

/// BLoC for managing User Settings, Timer Customization, Typography & Profile
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetSettingsUseCase getSettingsUseCase;
  final SaveSettingsUseCase saveSettingsUseCase;
  final ResetSettingsUseCase resetSettingsUseCase;
  final ClearAllDataUseCase clearAllDataUseCase;

  SettingsBloc({
    required this.getSettingsUseCase,
    required this.saveSettingsUseCase,
    required this.resetSettingsUseCase,
    required this.clearAllDataUseCase,
  }) : super(SettingsInitial()) {
    on<LoadSettingsEvent>(_onLoadSettings);
    on<UpdateTimerSettingsEvent>(_onUpdateTimerSettings);
    on<UpdateFontFamilyEvent>(_onUpdateFontFamily);
    on<UpdateGoalsEvent>(_onUpdateGoals);
    on<UpdateUserProfileEvent>(_onUpdateUserProfile);
    on<ResetSettingsEvent>(_onResetSettings);
    on<ClearAllDataConfirmedEvent>(_onClearAllData);
  }

  Future<void> _onLoadSettings(
    LoadSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      final preferences = await getSettingsUseCase();
      emit(SettingsLoaded(preferences: preferences));
    } catch (e) {
      emit(SettingsError('Failed to load settings: $e'));
    }
  }

  Future<void> _onUpdateTimerSettings(
    UpdateTimerSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final current = state is SettingsLoaded
        ? (state as SettingsLoaded).preferences
        : await getSettingsUseCase();

    final updated = current.copyWith(
      workDurationMinutes: event.workDurationMinutes,
      shortBreakMinutes: event.shortBreakMinutes,
      longBreakMinutes: event.longBreakMinutes,
      longBreakInterval: event.longBreakInterval,
      autoStartBreaks: event.autoStartBreaks,
      autoStartPomodoros: event.autoStartPomodoros,
    );

    try {
      await saveSettingsUseCase(updated);
      emit(SettingsLoaded(
        preferences: updated,
        successMessage: 'Timer configuration updated',
      ));
    } catch (e) {
      emit(SettingsError('Failed to update timer settings: $e'));
    }
  }

  Future<void> _onUpdateFontFamily(
    UpdateFontFamilyEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final current = state is SettingsLoaded
        ? (state as SettingsLoaded).preferences
        : await getSettingsUseCase();

    final updated = current.copyWith(fontFamily: event.fontFamily);

    try {
      await saveSettingsUseCase(updated);
      emit(SettingsLoaded(
        preferences: updated,
        successMessage: 'Font changed to ${event.fontFamily.displayName}',
      ));
    } catch (e) {
      emit(SettingsError('Failed to update font: $e'));
    }
  }

  Future<void> _onUpdateGoalsEvent(
    UpdateGoalsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final current = state is SettingsLoaded
        ? (state as SettingsLoaded).preferences
        : await getSettingsUseCase();

    final updated = current.copyWith(
      dailyTaskGoal: event.dailyTaskGoal,
      dailyFocusMinutesGoal: event.dailyFocusMinutesGoal,
    );

    try {
      await saveSettingsUseCase(updated);
      emit(SettingsLoaded(
        preferences: updated,
        successMessage: 'Productivity goals updated',
      ));
    } catch (e) {
      emit(SettingsError('Failed to update goals: $e'));
    }
  }

  Future<void> _onUpdateGoals(
    UpdateGoalsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await _onUpdateGoalsEvent(event, emit);
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfileEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final current = state is SettingsLoaded
        ? (state as SettingsLoaded).preferences
        : await getSettingsUseCase();

    final updated = current.copyWith(
      userName: event.userName,
      userTitle: event.userTitle,
    );

    try {
      await saveSettingsUseCase(updated);
      emit(SettingsLoaded(
        preferences: updated,
        successMessage: 'Profile updated',
      ));
    } catch (e) {
      emit(SettingsError('Failed to update profile: $e'));
    }
  }

  Future<void> _onResetSettings(
    ResetSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      await resetSettingsUseCase();
      final fresh = await getSettingsUseCase();
      emit(SettingsLoaded(
        preferences: fresh,
        successMessage: 'Settings reset to default',
      ));
    } catch (e) {
      emit(SettingsError('Failed to reset settings: $e'));
    }
  }

  Future<void> _onClearAllData(
    ClearAllDataConfirmedEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      await clearAllDataUseCase();
      final fresh = await getSettingsUseCase();
      emit(SettingsLoaded(
        preferences: fresh,
        successMessage: 'All data cleared & re-initialized',
      ));
    } catch (e) {
      emit(SettingsError('Failed to clear data: $e'));
    }
  }
}
