import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/unit_data.dart';
import 'api_service.dart';

class CoursePath {
  final String ttsCode;
  final List<UnitData> units;

  const CoursePath({required this.ttsCode, required this.units});
}

class _UnitTheme {
  final Color header;
  final Color node;

  const _UnitTheme(this.header, this.node);
}

class CourseService {
  CourseService._();

  static const List<_UnitTheme> _themes = [
    _UnitTheme(Color(0xFFFCCF10), Color(0xFFFCCF10)),
    _UnitTheme(Color(0xFF1CB0F6), Color(0xFFFF9600)),
    _UnitTheme(Color(0xFFCE82FF), Color(0xFFFCCF10)),
    _UnitTheme(Color(0xFF58CC02), Color(0xFFFF9600)),
  ];

  static Future<CoursePath> getPath(String code) async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/languages/$code/path'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal memuat jalur belajar (${response.statusCode})');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>;
    final language = data['language'] as Map<String, dynamic>;
    final sections = (data['sections'] as List?) ?? [];

    final units = <UnitData>[];

    for (int s = 0; s < sections.length; s++) {
      final section = sections[s] as Map<String, dynamic>;
      final sectionUnits = (section['units'] as List?) ?? [];

      for (int u = 0; u < sectionUnits.length; u++) {
        final unit = sectionUnits[u] as Map<String, dynamic>;
        final lessons = (unit['lessons'] as List?) ?? [];

        if (lessons.isEmpty) continue;

        final theme = _themes[units.length % _themes.length];

        final titles = lessons
            .map(
              (lesson) =>
                  (lesson['title'] ?? lesson['name'] ?? 'Pelajaran').toString(),
            )
            .toList();

        final ids = lessons
            .map<int>((lesson) => (lesson['id'] as num).toInt())
            .toList();

        units.add(
          UnitData(
            section: s + 1,
            unit: u + 1,
            title: (unit['title'] ?? unit['name'] ?? 'Unit ${u + 1}')
                .toString(),
            color: theme.header,
            nodeColor: theme.node,
            lessonTitles: titles,
            lessonIds: ids,
            chestAfter: _chestAfter(unit, titles.length),
          ),
        );
      }
    }

    return CoursePath(
      ttsCode: (language['tts_code'] ?? 'en-US').toString(),
      units: units,
    );
  }

  static List<int> _chestAfter(Map<String, dynamic> unit, int lessonCount) {
    final raw = unit['chest_after'];

    if (raw is List) {
      return raw.map<int>((value) => (value as num).toInt()).toList();
    }

    if (lessonCount >= 3) {
      return [(lessonCount / 2).ceil()];
    }

    return [];
  }
}
