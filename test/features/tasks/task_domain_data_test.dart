import 'package:flutter_test/flutter_test.dart';
import 'package:wizdesk/features/tasks/data/models/task_category_model.dart';
import 'package:wizdesk/features/tasks/data/models/task_model.dart';
import 'package:wizdesk/features/tasks/domain/entities/task_category_entity.dart';
import 'package:wizdesk/features/tasks/domain/entities/task_entity.dart';
import 'package:wizdesk/features/tasks/domain/entities/task_enums.dart';

void main() {
  group('Task Domain & Data Models Test', () {
    final testDate = DateTime(2026, 6, 14, 10, 30);

    final tTaskEntity = TaskEntity(
      id: 'task_1',
      title: 'Complete Clean Architecture',
      description: 'Implement domain and data layers for Wiz Desk',
      categoryId: 'cat_coding',
      priority: TaskPriority.urgent,
      status: TaskStatus.inProgress,
      dueDate: testDate,
      frequency: TaskFrequency.daily,
      estimatedMinutes: 50,
      spentMinutes: 25,
      isFocusModeEnabled: true,
      createdAt: testDate,
    );

    final tCategoryEntity = const TaskCategoryEntity(
      id: 'cat_coding',
      name: 'Coding',
      iconCode: 0xe194,
      colorValue: 0xFF00F0FF,
    );

    test('TaskModel should convert to and from Map accurately', () {
      final model = TaskModel.fromEntity(tTaskEntity);
      final map = model.toMap();

      expect(map['id'], 'task_1');
      expect(map['priority'], 'urgent');
      expect(map['status'], 'inProgress');
      expect(map['estimatedMinutes'], 50);

      final fromMap = TaskModel.fromMap(map);
      expect(fromMap.id, tTaskEntity.id);
      expect(fromMap.title, tTaskEntity.title);
      expect(fromMap.priority, TaskPriority.urgent);
      expect(fromMap.status, TaskStatus.inProgress);
      expect(fromMap.progressPercentage, 0.5);
    });

    test('TaskCategoryModel should convert to and from Map accurately', () {
      final catModel = TaskCategoryModel.fromEntity(tCategoryEntity);
      final map = catModel.toMap();

      expect(map['id'], 'cat_coding');
      expect(map['name'], 'Coding');

      final fromMap = TaskCategoryModel.fromMap(map);
      expect(fromMap.id, tCategoryEntity.id);
      expect(fromMap.name, tCategoryEntity.name);
      expect(fromMap.colorValue, 0xFF00F0FF);
    });

    test('TaskPriority and TaskStatus enum parsing works correctly', () {
      expect(TaskPriority.fromString('urgent'), TaskPriority.urgent);
      expect(TaskPriority.fromString('High'), TaskPriority.high);
      expect(TaskPriority.fromString('invalid'), TaskPriority.medium);

      expect(TaskStatus.fromString('completed'), TaskStatus.completed);
      expect(TaskStatus.fromString('inProgress'), TaskStatus.inProgress);
      expect(TaskStatus.fromString('unknown'), TaskStatus.todo);
    });
  });
}
