import 'package:flutter/material.dart';

class UnitData {
  final int section; // nomor bagian
  final int unit; // nomor unit
  final String title; // judul unit
  final Color color; // warna header
  final Color nodeColor; // warna lingkaran & popup
  final List<String> lessonTitles; // jumlah item = jumlah pelajaran

  final List<int> chestAfter;

  const UnitData({
    required this.section,
    required this.unit,
    required this.title,
    required this.color,
    required this.nodeColor,
    required this.lessonTitles,
    this.chestAfter = const [],
  });

  int get lessonCount => lessonTitles.length;

  int get chestCount =>
      chestAfter.toSet().where((n) => n >= 1 && n <= lessonCount).length;

  /// Total slot di jalur = pelajaran + peti
  int get slotCount => lessonCount + chestCount;
}
