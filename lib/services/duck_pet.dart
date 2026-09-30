import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/duck_painter.dart';
import 'player_progress.dart';

// Data aksesoris di lemari Quacko.
class AccessoryInfo {
  final DuckAccessory type;
  final String name;
  final int price;

  const AccessoryInfo(this.type, this.name, this.price);
}

// Quacko, bebek peliharaan virtual.
//
// Punya dua nilai 0-100 yang turun seiring waktu:
// - kenyang (fullness): naik kalau diberi roti
// - senang (happiness): naik kalau pemain belajar atau Quacko dielus
//
// Nilainya dihitung dari selisih waktu sejak terakhir disimpan, jadi tetap
// turun walaupun aplikasi sedang ditutup.
class DuckPet extends ChangeNotifier {
  DuckPet._();

  static final DuckPet instance = DuckPet._();

  // Berkurang per jam
  static const double fullnessDecay = 4;
  static const double happinessDecay = 3;

  static const int breadPrice = 10;
  static const double breadFullness = 25;
  static const double lessonHappiness = 15;
  static const double petHappiness = 4;
  static const Duration petCooldown = Duration(minutes: 1);

  static const List<AccessoryInfo> wardrobe = [
    AccessoryInfo(DuckAccessory.scarf, 'Syal Merah', 25),
    AccessoryInfo(DuckAccessory.partyHat, 'Topi Pesta', 30),
    AccessoryInfo(DuckAccessory.sunglasses, 'Kacamata Hitam', 40),
    AccessoryInfo(DuckAccessory.crown, 'Mahkota', 120),
  ];

  // Jam sekarang. Bisa diganti waktu testing supaya bisa "lompat waktu".
  @visibleForTesting
  DateTime Function() clock = DateTime.now;

  SharedPreferences? prefs;
  Future<void>? loading;

  bool get isLoaded => prefs != null;

  String name = 'Quacko';
  double storedFullness = 80;
  double storedHappiness = 80;
  DateTime lastTick = DateTime.now();
  DateTime adoptedAt = DateTime.now();
  DateTime? lastPetAt;
  Set<DuckAccessory> owned = {};
  Set<DuckAccessory> equipped = {};

  Future<void> load() {
    return loading ??= loadFromDisk();
  }

  Future<void> loadFromDisk() async {
    final p = await SharedPreferences.getInstance();
    final now = clock();

    name = p.getString('pet_name') ?? 'Quacko';
    storedFullness = p.getDouble('pet_fullness') ?? 80;
    storedHappiness = p.getDouble('pet_happiness') ?? 80;
    lastTick = readTime(p, 'pet_lastTick') ?? now;
    adoptedAt = readTime(p, 'pet_adoptedAt') ?? now;
    lastPetAt = readTime(p, 'pet_lastPetAt');
    owned = readAccessories(p, 'pet_owned');
    equipped = readAccessories(p, 'pet_equipped');

    prefs = p;
    notifyListeners();
  }

  static DateTime? readTime(SharedPreferences p, String key) {
    final ms = p.getInt(key);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  static Set<DuckAccessory> readAccessories(SharedPreferences p, String key) {
    final names = p.getStringList(key) ?? [];
    return DuckAccessory.values.where((a) => names.contains(a.name)).toSet();
  }

  Future<void> save() async {
    final p = prefs!;
    await Future.wait([
      p.setString('pet_name', name),
      p.setDouble('pet_fullness', storedFullness),
      p.setDouble('pet_happiness', storedHappiness),
      p.setInt('pet_lastTick', lastTick.millisecondsSinceEpoch),
      p.setInt('pet_adoptedAt', adoptedAt.millisecondsSinceEpoch),
      if (lastPetAt != null)
        p.setInt('pet_lastPetAt', lastPetAt!.millisecondsSinceEpoch),
      p.setStringList('pet_owned', owned.map((a) => a.name).toList()),
      p.setStringList('pet_equipped', equipped.map((a) => a.name).toList()),
    ]);
  }

  // ---------- Nilai saat ini ----------

  double get hoursSinceTick =>
      clock().difference(lastTick).inSeconds / Duration.secondsPerHour;

  double get fullness =>
      (storedFullness - fullnessDecay * hoursSinceTick).clamp(0, 100);

  double get happiness =>
      (storedHappiness - happinessDecay * hoursSinceTick).clamp(0, 100);

  // Malam hari (22.00 - 06.00) Quacko tidur.
  bool get isSleeping {
    final hour = clock().hour;
    return hour >= 22 || hour < 6;
  }

  DuckMood get mood {
    if (isSleeping) return DuckMood.sleeping;
    if (fullness < 25) return DuckMood.hungry;
    if (happiness < 25) return DuckMood.sad;
    if (fullness >= 70 && happiness >= 70) return DuckMood.happy;
    return DuckMood.normal;
  }

  String get moodLabel {
    switch (mood) {
      case DuckMood.happy:
        return 'Senang banget';
      case DuckMood.normal:
        return 'Santai';
      case DuckMood.hungry:
        return 'Lapar';
      case DuckMood.sad:
        return 'Sedih';
      case DuckMood.sleeping:
        return 'Tidur';
    }
  }

  String get speech {
    switch (mood) {
      case DuckMood.happy:
        return 'Aku senang banget belajar bareng kamu!';
      case DuckMood.normal:
        return 'Yuk selesaikan satu lesson lagi!';
      case DuckMood.hungry:
        return 'Perutku keroncongan... ada roti?';
      case DuckMood.sad:
        return 'Kamu ke mana aja? Aku kangen belajar bareng.';
      case DuckMood.sleeping:
        return 'Zzz... Aku tidur dulu ya, besok pagi kita belajar lagi.';
    }
  }

  int get daysTogether => clock().difference(adoptedAt).inDays + 1;

  bool get canPet =>
      !isSleeping &&
      (lastPetAt == null || clock().difference(lastPetAt!) >= petCooldown);

  // ---------- Mengubah data ----------

  // Semua perubahan lewat sini: hitung dulu nilai sekarang (setelah
  // berkurang karena waktu), jalankan perubahan, lalu simpan.
  Future<void> update(void Function() change) async {
    await load();
    storedFullness = fullness;
    storedHappiness = happiness;
    lastTick = clock();
    change();
    storedFullness = storedFullness.clamp(0, 100);
    storedHappiness = storedHappiness.clamp(0, 100);
    notifyListeners();
    await save();
  }

  // Beri roti. Gagal kalau gem kurang atau Quacko sudah kenyang.
  Future<String?> feed() async {
    await load();
    if (fullness >= 95) return 'Quacko sudah kenyang!';
    final paid = await PlayerProgress.instance.spendGems(breadPrice);
    if (!paid) return 'Gem kamu belum cukup.';

    await update(() {
      storedFullness += breadFullness;
      storedHappiness += 5;
    });
    return null;
  }

  // Elus Quacko. Ada jeda 1 menit supaya tidak bisa di-spam.
  Future<bool> pet() async {
    await load();
    if (!canPet) return false;
    await update(() {
      storedHappiness += petHappiness;
      lastPetAt = clock();
    });
    return true;
  }

  // Dipanggil PlayerProgress setiap lesson selesai.
  Future<void> onLessonCompleted() {
    return update(() => storedHappiness += lessonHappiness);
  }

  Future<String?> buyAccessory(AccessoryInfo item) async {
    await load();
    if (owned.contains(item.type)) return null;
    final paid = await PlayerProgress.instance.spendGems(item.price);
    if (!paid) return 'Gem kamu belum cukup.';

    await update(() {
      owned.add(item.type);
      wear(item.type);
      storedHappiness += 10;
    });
    return null;
  }

  // Pakai atau lepas aksesoris. Aksesoris lain di slot yang sama dilepas.
  Future<void> toggleAccessory(DuckAccessory type) {
    return update(() {
      if (!owned.contains(type)) return;
      if (equipped.contains(type)) {
        equipped.remove(type);
      } else {
        wear(type);
      }
    });
  }

  void wear(DuckAccessory type) {
    equipped.removeWhere((a) => a.slot == type.slot);
    equipped.add(type);
  }

  Future<void> rename(String newName) {
    final trimmed = newName.trim();
    return update(() {
      if (trimmed.isNotEmpty) name = trimmed;
    });
  }

  @visibleForTesting
  void resetForTest() {
    prefs = null;
    loading = null;
  }
}
