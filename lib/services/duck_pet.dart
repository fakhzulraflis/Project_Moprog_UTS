import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/duck_painter.dart';
import '../widgets/reward_chest.dart';
import 'player_progress.dart';
import 'progress_sync.dart';

// Data aksesoris di lemari Quacko.
class AccessoryInfo {
  final DuckAccessory type;
  final String name;
  final int price;

  const AccessoryInfo(this.type, this.name, this.price);
}

// Quacko, bebek peliharaan virtual.
//
// Quacko punya level (1-10) dari XP yang didapat waktu pemain belajar dan
// merawatnya. Makin tinggi levelnya, Quacko tumbuh dari anak bebek jadi
// remaja lalu dewasa.
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

  // XP Quacko dari tiap kegiatan. XP dari lesson sama dengan XP lesson-nya.
  static const int feedXp = 5;
  static const int petXp = 2;
  static const int accessoryXp = 10;
  static const int maxLevel = 10;
  static const int gemsPerLevel = 10;

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
  int xp = 0;

  // Level baru yang belum dirayakan (0 kalau tidak ada). Disimpan supaya
  // naik level yang terjadi di halaman lesson tetap dirayakan nanti waktu
  // halaman Quacko dibuka.
  int pendingLevelUp = 0;

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
    xp = p.getInt('pet_xp') ?? 0;
    pendingLevelUp = p.getInt('pet_pendingLevelUp') ?? 0;

    prefs = p;

    // Quacko baru: langsung disimpan supaya tanggal adopsinya tetap
    // (dan ikut tersimpan di akun user)
    if (!p.containsKey('pet_adoptedAt')) await save();

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
      p.setInt('pet_xp', xp),
      p.setInt('pet_pendingLevelUp', pendingLevelUp),
    ]);

    // Kirim juga ke database supaya Quacko tersimpan di akun user
    ProgressSync.instance.schedulePush();
  }

  // Muat ulang dari HP. Dipakai setelah progres diganti dari server.
  Future<void> reload() {
    prefs = null;
    loading = null;
    return load();
  }

  // ---------- Level ----------

  // Total XP yang dibutuhkan untuk mencapai sebuah level.
  // Level 2 = 30 XP, level 3 = 90 XP, level 4 = 180 XP, dan seterusnya.
  static int xpForLevel(int level) => 15 * level * (level - 1);

  static int levelForXp(int xp) {
    var level = 1;
    while (level < maxLevel && xp >= xpForLevel(level + 1)) {
      level++;
    }
    return level;
  }

  static DuckStage stageForLevel(int level) {
    if (level >= 7) return DuckStage.adult;
    if (level >= 4) return DuckStage.teen;
    return DuckStage.duckling;
  }

  static String stageName(DuckStage stage) {
    switch (stage) {
      case DuckStage.duckling:
        return 'Anak Bebek';
      case DuckStage.teen:
        return 'Bebek Remaja';
      case DuckStage.adult:
        return 'Bebek Dewasa';
    }
  }

  // Level minimal untuk tiap tahap, dipakai di tampilan evolusi.
  static int levelForStage(DuckStage stage) {
    switch (stage) {
      case DuckStage.duckling:
        return 1;
      case DuckStage.teen:
        return 4;
      case DuckStage.adult:
        return 7;
    }
  }

  int get level => levelForXp(xp);

  DuckStage get stage => stageForLevel(level);

  bool get isMaxLevel => level >= maxLevel;

  // XP yang sudah terkumpul di level sekarang dan yang dibutuhkan untuk
  // naik ke level berikutnya, untuk progress bar.
  int get xpIntoLevel => xp - xpForLevel(level);

  int get xpToNextLevel =>
      isMaxLevel ? 0 : xpForLevel(level + 1) - xpForLevel(level);

  // Tambah XP. Mengembalikan jumlah gem hadiah kalau naik level.
  int gainXp(int amount) {
    final before = level;
    xp += amount;
    final after = level;
    if (after <= before) return 0;

    pendingLevelUp = after;
    var reward = 0;
    for (var l = before + 1; l <= after; l++) {
      reward += gemsPerLevel * l;
    }
    return reward;
  }

  // Dipanggil setelah perayaan naik level ditampilkan.
  Future<void> clearLevelUp() => update(() => pendingLevelUp = 0);

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
  // [gainedXp] menambah XP Quacko, dan hadiah naik level langsung
  // dimasukkan ke saldo gem.
  Future<void> update(void Function() change, {int gainedXp = 0}) async {
    await load();
    storedFullness = fullness;
    storedHappiness = happiness;
    lastTick = clock();
    change();
    storedFullness = storedFullness.clamp(0, 100);
    storedHappiness = storedHappiness.clamp(0, 100);
    final reward = gainedXp > 0 ? gainXp(gainedXp) : 0;
    notifyListeners();
    await save();

    if (reward > 0) {
      await PlayerProgress.instance.addLoot(ChestLoot(LootType.gems, reward));
    }
  }

  // Beri roti. Gagal kalau gem kurang atau Quacko sudah kenyang.
  Future<String?> feed() async {
    await load();
    if (fullness >= 95) return '$name sudah kenyang!';
    final paid = await PlayerProgress.instance.spendGems(breadPrice);
    if (!paid) return 'Gem kamu belum cukup.';

    await update(() {
      storedFullness += breadFullness;
      storedHappiness += 5;
    }, gainedXp: feedXp);
    await PlayerProgress.instance.recordFeed();
    return null;
  }

  // Elus Quacko. Ada jeda 1 menit supaya tidak bisa di-spam.
  Future<bool> pet() async {
    await load();
    if (!canPet) return false;
    await update(() {
      storedHappiness += petHappiness;
      lastPetAt = clock();
    }, gainedXp: petXp);
    await PlayerProgress.instance.recordPet();
    return true;
  }

  // Dipanggil PlayerProgress setiap lesson selesai, dengan XP yang didapat.
  Future<void> onLessonCompleted(int lessonXp) {
    return update(() => storedHappiness += lessonHappiness, gainedXp: lessonXp);
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
    }, gainedXp: accessoryXp);
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
