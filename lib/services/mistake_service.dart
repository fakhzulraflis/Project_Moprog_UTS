import 'package:shared_preferences/shared_preferences.dart';

class MistakeService {
  static const String _mistakeKey = 'practice_mistake_vocabulary_ids';

  static Future<Set<int>> getMistakeIds() async {
    final preferences = await SharedPreferences.getInstance();

    final savedIds = preferences.getStringList(_mistakeKey) ?? [];

    return savedIds.map(int.tryParse).whereType<int>().toSet();
  }

  static Future<void> addMistake(int vocabularyId) async {
    final preferences = await SharedPreferences.getInstance();

    final mistakeIds = await getMistakeIds();

    mistakeIds.add(vocabularyId);

    await preferences.setStringList(
      _mistakeKey,
      mistakeIds.map((id) => id.toString()).toList(),
    );
  }

  static Future<void> removeMistake(int vocabularyId) async {
    final preferences = await SharedPreferences.getInstance();

    final mistakeIds = await getMistakeIds();

    mistakeIds.remove(vocabularyId);

    await preferences.setStringList(
      _mistakeKey,
      mistakeIds.map((id) => id.toString()).toList(),
    );
  }

  static Future<void> clearMistakes() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_mistakeKey);
  }
}
