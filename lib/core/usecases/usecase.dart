import 'package:equatable/equatable.dart';

/// Base UseCase contract for Clean Architecture
/// [ReturnType] is the return type, [Params] is the parameter class
abstract class UseCase<ReturnType, Params> {
  Future<ReturnType> call(Params params);
}

/// Helper class for use cases that require no parameters
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}

