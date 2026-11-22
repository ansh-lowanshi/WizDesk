import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import '../../../../core/localization/app_localizations.dart';

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

  /// Returns the localized name for standard default categories, or custom name
  String localizedName(BuildContext context) {
    final l10n = context.l10n;
    switch (id) {
      case 'cat_work':
        return l10n.categoryWork;
      case 'cat_study':
        return l10n.categoryStudy;
      case 'cat_coding':
        return l10n.categoryCoding;
      case 'cat_design':
        return l10n.categoryDesign;
      case 'cat_fitness':
        return l10n.categoryFitness;
      case 'cat_personal':
        return l10n.categoryPersonal;
      default:
        return name;
    }
  }

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
