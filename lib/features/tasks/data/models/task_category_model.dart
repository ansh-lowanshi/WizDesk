import '../../domain/entities/task_category_entity.dart';

/// Data model for Task Category with Map serialization
class TaskCategoryModel extends TaskCategoryEntity {
  const TaskCategoryModel({
    required super.id,
    required super.name,
    required super.iconCode,
    required super.colorValue,
  });

  factory TaskCategoryModel.fromEntity(TaskCategoryEntity entity) {
    return TaskCategoryModel(
      id: entity.id,
      name: entity.name,
      iconCode: entity.iconCode,
      colorValue: entity.colorValue,
    );
  }

  factory TaskCategoryModel.fromMap(Map<dynamic, dynamic> map) {
    return TaskCategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      iconCode: map['iconCode'] as int,
      colorValue: map['colorValue'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconCode': iconCode,
      'colorValue': colorValue,
    };
  }
}
