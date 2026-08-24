import 'package:equatable/equatable.dart';
import '../../domain/models/user_preferences_model.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final UserPreferencesModel preferences;
  final String? successMessage;

  const SettingsLoaded({
    required this.preferences,
    this.successMessage,
  });

  @override
  List<Object?> get props => [preferences, successMessage];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object?> get props => [message];
}
