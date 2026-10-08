import 'package:shared_preferences/shared_preferences.dart';

import 'progress_sync.dart';

// Kosakata yang pernah salah dijawab, untuk halaman Latihan. Disimpan di HP
// dan ikut dikirim ke akun user (lewat ProgressSync), jadi tiap user punya
// daftar kesalahannya sendiri.
class MistakeService {
  // Kunci ini juga terdaftar di ProgressSync.keys
  static const String _mistakeKey = 'practice_mistake_vocabulary_ids';

  static Future<Set<int>> getMistakeIds() async {
    final preferences = await SharedPreferences.getInstance();

    final savedIds = preferences.getStringList(_mistakeKey) ?? [];

    return savedIds.map(int.tryParse).whereType<int>().toSet();
  }

  static Future<void> addMistake(int vocabularyId) async {
    final mistakeIds = await getMistakeIds();

    if (mistakeIds.add(vocabularyId)) {
      await _save(mistakeIds);
    }
  }

  static Future<void> removeMistake(int vocabularyId) async {
    final mistakeIds = await getMistakeIds();

    if (mistakeIds.remove(vocabularyId)) {
      await _save(mistakeIds);
    }
  }

  static Future<void> clearMistakes() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_mistakeKey);

    ProgressSync.instance.schedulePush();
  }

  static Future<void> _save(Set<int> mistakeIds) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setStringList(
      _mistakeKey,
      mistakeIds.map((id) => id.toString()).toList(),
    );

    ProgressSync.instance.schedulePush();
  }
}
