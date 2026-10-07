import 'package:flutter/material.dart';

class UnitData {
  final int section;
  final int unit;
  final String title;
  final Color color;
  final Color nodeColor;
  final List<String> lessonTitles;
  final List<int> lessonIds;
  final List<int> chestAfter;

  const UnitData({
    required this.section,
    required this.unit,
    required this.title,
    required this.color,
    required this.nodeColor,
    required this.lessonTitles,
    required this.lessonIds,
    this.chestAfter = const [],
  });

  int get lessonCount => lessonTitles.length;

  int get chestCount =>
      chestAfter.toSet().where((n) => n >= 1 && n <= lessonCount).length;

  int get slotCount => lessonCount + chestCount;
}
