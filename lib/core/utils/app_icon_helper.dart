import 'package:flutter/material.dart';

/// Helper to safely resolve Material IconData from integer codePoints
class AppIconHelper {
  static IconData getCategoryIcon(int iconCode) {
    switch (iconCode) {
      case 0xe6f2:
        return Icons.work_outline_rounded;
      case 0xe559:
        return Icons.school_outlined;
      case 0xe194:
        return Icons.code_rounded;
      case 0xe471:
        return Icons.palette_outlined;
      case 0xe294:
        return Icons.fitness_center_rounded;
      case 0xe491:
        return Icons.person_outline_rounded;
      case 0xe3e7:
        return Icons.menu_book_rounded;
      case 0xe0be:
        return Icons.call_outlined;
      case 0xe318:
        return Icons.lightbulb_outline_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}
