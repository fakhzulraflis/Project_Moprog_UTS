import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService._();

  static const String _keySelectedLanguage = 'selected_language';
  static const String _keyXp = 'xp';
  static const String _keyGems = 'gems';
  static const String _keyStreak = 'streak';
  static const String _keyCompletedLessons = 'completed_lessons';

  static Future<SharedPreferences> _prefs() async {
    return SharedPreferences.getInstance();
  }

  static Future<void> saveSelectedLanguage(String language) async {
    final prefs = await _prefs();
    await prefs.setString(_keySelectedLanguage, language);
  }

  static Future<String?> getSelectedLanguage() async {
    final prefs = await _prefs();
    return prefs.getString(_keySelectedLanguage);
  }

  static Future<void> saveXp(int xp) async {
    final prefs = await _prefs();
    await prefs.setInt(_keyXp, xp);
  }

  static Future<int> getXp() async {
    final prefs = await _prefs();
    return prefs.getInt(_keyXp) ?? 0;
  }

  static Future<void> saveGems(int gems) async {
    final prefs = await _prefs();
    await prefs.setInt(_keyGems, gems);
  }

  static Future<int> getGems() async {
    final prefs = await _prefs();
    return prefs.getInt(_keyGems) ?? 0;
  }

  static Future<void> saveStreak(int streak) async {
    final prefs = await _prefs();
    await prefs.setInt(_keyStreak, streak);
  }

  static Future<int> getStreak() async {
    final prefs = await _prefs();
    return prefs.getInt(_keyStreak) ?? 0;
  }

  static Future<void> saveCompletedLessons(Set<int> lessonIds) async {
    final prefs = await _prefs();

    final list = lessonIds.toList()..sort();

    await prefs.setString(_keyCompletedLessons, jsonEncode(list));
  }

  static Future<Set<int>> getCompletedLessons() async {
    final prefs = await _prefs();

    final raw = prefs.getString(_keyCompletedLessons);

    if (raw == null || raw.isEmpty) {
      return {};
    }

    try {
      final decoded = jsonDecode(raw);

      if (decoded is! List) {
        return {};
      }

      return decoded.whereType<num>().map((value) => value.toInt()).toSet();
    } catch (_) {
      return {};
    }
  }
}
