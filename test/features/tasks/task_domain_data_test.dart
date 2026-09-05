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

    test('TaskProgressMode enum parsing works correctly', () {
      expect(
        TaskProgressMode.fromString('individual'),
        TaskProgressMode.individual,
      );
      expect(
        TaskProgressMode.fromString('cumulative'),
        TaskProgressMode.cumulative,
      );
      expect(
        TaskProgressMode.fromString('invalid'),
        TaskProgressMode.individual,
      );
    });

    test(
      'Individual progress mode tracks daily progress and resets fresh on day 2',
      () {
        final day1 = DateTime(2026, 9, 1);
        final day2 = DateTime(2026, 9, 2);
        final day1Key = TaskEntity.formatDateKey(day1);

        final recurringTask = TaskEntity(
          id: 'task_daily_1',
          title: 'Daily Exercise',
          description: 'Morning workout 30 mins',
          categoryId: 'cat_health',
          frequency: TaskFrequency.daily,
          progressMode: TaskProgressMode.individual,
          dailyProgress: {day1Key: 50},
          dailySpentMinutes: {day1Key: 15},
          dailyDescriptions: {day1Key: 'Focused on cardio today'},
          estimatedMinutes: 30,
          createdAt: day1,
        );

        // On Day 1: progress is 50%, spent is 15m, description is overridden
        expect(recurringTask.getProgressPercentFor(day1), 50);
        expect(recurringTask.getSpentMinutesFor(day1), 15);
        expect(
          recurringTask.getDescriptionFor(day1),
          'Focused on cardio today',
        );

        // On Day 2: progress starts fresh at 0%, spent is 0m, description falls back to base
        expect(recurringTask.getProgressPercentFor(day2), 0);
        expect(recurringTask.getSpentMinutesFor(day2), 0);
        expect(
          recurringTask.getDescriptionFor(day2),
          'Morning workout 30 mins',
        );

        // Test Serialization & Deserialization preserves daily maps and progressMode
        final model = TaskModel.fromEntity(recurringTask);
        final map = model.toMap();
        expect(map['progressMode'], 'individual');
        expect(map['dailyProgress'][day1Key], 50);
        expect(map['dailyDescriptions'][day1Key], 'Focused on cardio today');

        final fromMap = TaskModel.fromMap(map);
        expect(fromMap.progressMode, TaskProgressMode.individual);
        expect(fromMap.getProgressPercentFor(day1), 50);
        expect(fromMap.getProgressPercentFor(day2), 0);
        expect(fromMap.getDescriptionFor(day1), 'Focused on cardio today');
        expect(fromMap.getDescriptionFor(day2), 'Morning workout 30 mins');
      },
    );

    test('Cumulative progress mode carries progress across all days', () {
      final day1 = DateTime(2026, 9, 1);
      final day2 = DateTime(2026, 9, 2);

      final cumulativeTask = TaskEntity(
        id: 'task_cumul_1',
        title: 'Read Book',
        description: 'Read 200 pages',
        categoryId: 'cat_study',
        frequency: TaskFrequency.daily,
        progressMode: TaskProgressMode.cumulative,
        progressPercent: 42,
        spentMinutes: 80,
        estimatedMinutes: 120,
        createdAt: day1,
      );

      // In cumulative mode, both day 1 and day 2 reflect the continuous progress
      expect(cumulativeTask.getProgressPercentFor(day1), 42);
      expect(cumulativeTask.getProgressPercentFor(day2), 42);
      expect(cumulativeTask.getSpentMinutesFor(day1), 80);
      expect(cumulativeTask.getSpentMinutesFor(day2), 80);
    });
  });
}
