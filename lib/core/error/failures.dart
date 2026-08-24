import 'package:equatable/equatable.dart';

/// Base Failure class for Clean Architecture Domain layer
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Failed to load or save data locally.']);
}

class TaskFailure extends Failure {
  const TaskFailure([super.message = 'A task operation failure occurred.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Please check the entered values.']);
}
