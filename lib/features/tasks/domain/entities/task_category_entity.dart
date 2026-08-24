import 'package:equatable/equatable.dart';

/// Domain entity representing a task category (e.g. Work, Study, Coding, Design)
class TaskCategoryEntity extends Equatable {
  final String id;
  final String name;
  final int iconCode;
  final int colorValue;

  const TaskCategoryEntity({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.colorValue,
  });

  @override
  List<Object?> get props => [id, name, iconCode, colorValue];

  TaskCategoryEntity copyWith({
    String? id,
    String? name,
    int? iconCode,
    int? colorValue,
  }) {
    return TaskCategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCode: iconCode ?? this.iconCode,
      colorValue: colorValue ?? this.colorValue,
    );
  }
}
