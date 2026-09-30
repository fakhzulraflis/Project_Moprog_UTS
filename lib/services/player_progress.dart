import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/reward_chest.dart';
import '../widgets/spin_wheel.dart';
import 'duck_pet.dart';

// Satu quest harian. Progress-nya dihitung dari data di PlayerProgress,
// jadi quest otomatis bergerak waktu pemain belajar.
class DailyQuest {
  final String id;
  final String title;
  final String icon;
  final int target;
  final ChestTier tier;
  final int Function(PlayerProgress p) progressOf;

  const DailyQuest({
    required this.id,
    required this.title,
    required this.icon,
    required this.target,
    required this.tier,
    required this.progressOf,
  });
}

// Menyimpan progress pemain di HP: gem, XP, quest harian, quest mingguan,
// challenge bulanan, streak, roda hadiah, dan item dari toko.
// Data tersimpan walaupun aplikasi ditutup.
//
// Dipakai sebagai satu objek bersama (PlayerProgress.instance) supaya
// halaman lesson, quests, dan shop membaca data yang sama.
class PlayerProgress extends ChangeNotifier {
  PlayerProgress._();

  static final PlayerProgress instance = PlayerProgress._();

  static const int xpPerLesson = 10;
  static const int monthlyTarget = 30;
  static const int weeklyTarget = 20;
  static const Duration xpBoostDuration = Duration(minutes: 15);

  static final List<DailyQuest> dailyQuests = [
    DailyQuest(
      id: 'earn_xp',
      title: 'Earn 50 XP',
      icon: 'assets/icons/xp.png',
      target: 50,
      tier: ChestTier.bronze,
      progressOf: (p) => p.xpToday,
    ),
    DailyQuest(
      id: 'complete_lessons',
      title: 'Complete 3 lessons',
      icon: 'assets/icons/guidebook.png',
      target: 3,
      tier: ChestTier.silver,
      progressOf: (p) => p.lessonsToday,
    ),
    DailyQuest(
      id: 'correct_answers',
      title: 'Answer 15 questions correctly',
      icon: 'assets/icons/dumbell.png',
      target: 15,
      tier: ChestTier.bronze,
      progressOf: (p) => p.correctToday,
    ),
  ];

  SharedPreferences? prefs;
  Future<void>? loading;

  bool get isLoaded => prefs != null;

  // Saldo dan item
  int gems = 50;
  int totalXp = 0;
  int bonusHearts = 0;
  DateTime? xpBoostUntil;

  // Progress hari ini
  String day = '';
  int xpToday = 0;
  int lessonsToday = 0;
  int correctToday = 0;
  Set<String> completedToday = {};
  Set<String> claimedToday = {};

  // Progress minggu ini (Senin - Minggu)
  String week = '';
  int lessonsThisWeek = 0;
  bool weeklyClaimed = false;

  // Progress bulan ini
  String month = '';
  int questsThisMonth = 0;
  bool monthlyClaimed = false;

  // Streak: jumlah hari berturut-turut menyelesaikan minimal 1 lesson
  int storedStreak = 0;
  int bestStreak = 0;
  String lastStudyDay = '';
  int streakGoal = 7;

  // Roda hadiah harian
  String lastSpinDay = '';
  int lastSpinPrize = -1;

  // Muat data dari HP. Aman dipanggil berkali-kali, hanya dimuat sekali.
  Future<void> load() {
    return loading ??= loadFromDisk();
  }

  Future<void> loadFromDisk() async {
    final p = await SharedPreferences.getInstance();

    gems = p.getInt('gems') ?? 50;
    totalXp = p.getInt('totalXp') ?? 0;
    bonusHearts = p.getInt('bonusHearts') ?? 0;
    final boost = p.getInt('xpBoostUntil');
    xpBoostUntil = boost == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(boost);

    day = p.getString('day') ?? '';
    xpToday = p.getInt('xpToday') ?? 0;
    lessonsToday = p.getInt('lessonsToday') ?? 0;
    correctToday = p.getInt('correctToday') ?? 0;
    completedToday = (p.getStringList('completedToday') ?? []).toSet();
    claimedToday = (p.getStringList('claimedToday') ?? []).toSet();

    week = p.getString('week') ?? '';
    lessonsThisWeek = p.getInt('lessonsThisWeek') ?? 0;
    weeklyClaimed = p.getBool('weeklyClaimed') ?? false;

    month = p.getString('month') ?? '';
    questsThisMonth = p.getInt('questsThisMonth') ?? 0;
    monthlyClaimed = p.getBool('monthlyClaimed') ?? false;

    storedStreak = p.getInt('streak') ?? 0;
    bestStreak = p.getInt('bestStreak') ?? 0;
    lastStudyDay = p.getString('lastStudyDay') ?? '';
    streakGoal = p.getInt('streakGoal') ?? 7;

    lastSpinDay = p.getString('lastSpinDay') ?? '';
    lastSpinPrize = p.getInt('lastSpinPrize') ?? -1;

    prefs = p;
    if (rollOver()) await save();
    notifyListeners();
  }

  Future<void> save() async {
    final p = prefs!;
    await Future.wait([
      p.setInt('gems', gems),
      p.setInt('totalXp', totalXp),
      p.setInt('bonusHearts', bonusHearts),
      if (xpBoostUntil == null)
        p.remove('xpBoostUntil')
      else
        p.setInt('xpBoostUntil', xpBoostUntil!.millisecondsSinceEpoch),
      p.setString('day', day),
      p.setInt('xpToday', xpToday),
      p.setInt('lessonsToday', lessonsToday),
      p.setInt('correctToday', correctToday),
      p.setStringList('completedToday', completedToday.toList()),
      p.setStringList('claimedToday', claimedToday.toList()),
      p.setString('week', week),
      p.setInt('lessonsThisWeek', lessonsThisWeek),
      p.setBool('weeklyClaimed', weeklyClaimed),
      p.setString('month', month),
      p.setInt('questsThisMonth', questsThisMonth),
      p.setBool('monthlyClaimed', monthlyClaimed),
      p.setInt('streak', storedStreak),
      p.setInt('bestStreak', bestStreak),
      p.setString('lastStudyDay', lastStudyDay),
      p.setInt('streakGoal', streakGoal),
      p.setString('lastSpinDay', lastSpinDay),
      p.setInt('lastSpinPrize', lastSpinPrize),
    ]);
  }

  // Semua perubahan data lewat sini: pastikan data sudah dimuat, cek
  // apakah sudah ganti hari, jalankan perubahan, lalu simpan.
  Future<void> update(void Function() change) async {
    await load();
    rollOver();
    change();
    checkQuestCompletion();
    notifyListeners();
    await save();
  }

  static String dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static String monthKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}';

  // Minggu ditandai dengan tanggal hari Senin-nya.
  static String weekKey(DateTime d) =>
      dayKey(DateTime(d.year, d.month, d.day - (d.weekday - 1)));

  static String yesterdayKey(DateTime d) =>
      dayKey(DateTime(d.year, d.month, d.day - 1));

  // Reset quest harian kalau sudah ganti hari, quest mingguan kalau sudah
  // ganti minggu, dan challenge bulanan kalau sudah ganti bulan.
  // Mengembalikan true kalau ada yang direset.
  bool rollOver([DateTime? now]) {
    now ??= DateTime.now();
    var changed = false;

    if (day != dayKey(now)) {
      day = dayKey(now);
      xpToday = 0;
      lessonsToday = 0;
      correctToday = 0;
      completedToday = {};
      claimedToday = {};
      changed = true;
    }

    if (week != weekKey(now)) {
      week = weekKey(now);
      lessonsThisWeek = 0;
      weeklyClaimed = false;
      changed = true;
    }

    if (month != monthKey(now)) {
      month = monthKey(now);
      questsThisMonth = 0;
      monthlyClaimed = false;
      changed = true;
    }

    return changed;
  }

  // Dipanggil tiap menit oleh halaman quests, supaya quest langsung
  // ter-reset tepat tengah malam walaupun halamannya sedang dibuka.
  Future<void> refresh() async {
    await load();
    if (rollOver()) {
      notifyListeners();
      await save();
    }
  }

  // Quest yang baru saja mencapai target dihitung ke challenge bulanan.
  void checkQuestCompletion() {
    for (final quest in dailyQuests) {
      if (quest.progressOf(this) >= quest.target &&
          completedToday.add(quest.id)) {
        questsThisMonth++;
      }
    }
  }

  // ---------- Quest ----------

  int progressOf(DailyQuest quest) =>
      quest.progressOf(this).clamp(0, quest.target);

  ChestState chestStateOf(DailyQuest quest) {
    if (claimedToday.contains(quest.id)) return ChestState.claimed;
    return quest.progressOf(this) >= quest.target
        ? ChestState.ready
        : ChestState.locked;
  }

  ChestState get monthlyChestState {
    if (monthlyClaimed) return ChestState.claimed;
    return questsThisMonth >= monthlyTarget
        ? ChestState.ready
        : ChestState.locked;
  }

  Future<void> claimQuest(DailyQuest quest, ChestLoot loot) {
    return update(() {
      if (chestStateOf(quest) != ChestState.ready) return;
      claimedToday.add(quest.id);
      applyLoot(loot);
    });
  }

  ChestState get weeklyChestState {
    if (weeklyClaimed) return ChestState.claimed;
    return lessonsThisWeek >= weeklyTarget
        ? ChestState.ready
        : ChestState.locked;
  }

  Future<void> claimWeekly(ChestLoot loot) {
    return update(() {
      if (weeklyChestState != ChestState.ready) return;
      weeklyClaimed = true;
      applyLoot(loot);
    });
  }

  Future<void> claimMonthly(ChestLoot loot) {
    return update(() {
      if (monthlyChestState != ChestState.ready) return;
      monthlyClaimed = true;
      applyLoot(loot);
    });
  }

  void applyLoot(ChestLoot loot) {
    switch (loot.type) {
      case LootType.gems:
        gems += loot.amount;
      case LootType.xp:
        // XP dari peti tidak ikut dikali boost
        totalXp += loot.amount;
        xpToday += loot.amount;
      case LootType.hearts:
        bonusHearts += loot.amount;
    }
  }

  // ---------- Dipanggil dari halaman lesson ----------

  bool get isXpBoostActive =>
      xpBoostUntil != null && DateTime.now().isBefore(xpBoostUntil!);

  Duration get xpBoostLeft => isXpBoostActive
      ? xpBoostUntil!.difference(DateTime.now())
      : Duration.zero;

  // Mengembalikan jumlah XP yang didapat (sudah termasuk boost).
  Future<int> completeLesson() async {
    var earned = xpPerLesson;
    await update(() {
      if (isXpBoostActive) earned *= 2;
      totalXp += earned;
      xpToday += earned;
      lessonsToday++;
      lessonsThisWeek++;
      recordStudyDay(DateTime.now());
    });

    // Quacko ikut senang kalau pemainnya belajar
    await DuckPet.instance.onLessonCompleted();
    return earned;
  }

  Future<void> recordCorrectAnswer() {
    return update(() => correctToday++);
  }

  // Hati tambahan dipakai sekaligus di awal lesson berikutnya.
  Future<int> takeBonusHearts() async {
    var taken = 0;
    await update(() {
      taken = bonusHearts;
      bonusHearts = 0;
    });
    return taken;
  }

  // ---------- Streak ----------

  // Streak yang masih berlaku. Kalau kemarin tidak belajar, streak putus.
  int get streak {
    final now = DateTime.now();
    final active =
        lastStudyDay == dayKey(now) || lastStudyDay == yesterdayKey(now);
    return active ? storedStreak : 0;
  }

  bool get studiedToday => lastStudyDay == dayKey(DateTime.now());

  void recordStudyDay(DateTime now) {
    final today = dayKey(now);
    if (lastStudyDay == today) return;

    storedStreak = lastStudyDay == yesterdayKey(now) ? storedStreak + 1 : 1;
    lastStudyDay = today;
    if (storedStreak > bestStreak) bestStreak = storedStreak;
  }

  // Dipanggil dari halaman Streak Goal waktu pemain memilih target.
  Future<void> setStreakGoal(int days) {
    return update(() => streakGoal = days);
  }

  // ---------- Roda hadiah harian ----------

  bool get canSpin => lastSpinDay != dayKey(DateTime.now());

  // Hadiah langsung disimpan sebelum animasi roda berputar, jadi keluar dari
  // halaman di tengah animasi tidak bisa dipakai untuk memutar ulang.
  Future<bool> claimSpin(int index) async {
    var ok = false;
    await update(() {
      if (!canSpin) return;
      final prize = SpinPrize.all[index];
      lastSpinDay = dayKey(DateTime.now());
      lastSpinPrize = index;

      switch (prize.type) {
        case PrizeType.gems:
          applyLoot(ChestLoot(LootType.gems, prize.amount));
        case PrizeType.hearts:
          applyLoot(ChestLoot(LootType.hearts, prize.amount));
        case PrizeType.xp:
          applyLoot(ChestLoot(LootType.xp, prize.amount));
        case PrizeType.xpBoost:
          // Kalau boost masih aktif, waktunya ditambah
          final from = isXpBoostActive ? xpBoostUntil! : DateTime.now();
          xpBoostUntil = from.add(Duration(minutes: prize.amount));
        case PrizeType.none:
          break;
      }
      ok = true;
    });
    return ok;
  }

  // ---------- Toko ----------

  // Mengurangi gem kalau cukup. Mengembalikan false kalau gem kurang.
  Future<bool> spendGems(int price) async {
    var ok = false;
    await update(() {
      if (gems < price) return;
      gems -= price;
      ok = true;
    });
    return ok;
  }

  Future<bool> buyXpBoost(int price) async {
    var ok = false;
    await update(() {
      if (gems < price || isXpBoostActive) return;
      gems -= price;
      xpBoostUntil = DateTime.now().add(xpBoostDuration);
      ok = true;
    });
    return ok;
  }

  Future<bool> buyBonusHearts(int price, int amount) async {
    var ok = false;
    await update(() {
      if (gems < price) return;
      gems -= price;
      bonusHearts += amount;
      ok = true;
    });
    return ok;
  }

  Future<void> addLoot(ChestLoot loot) => update(() => applyLoot(loot));

  @visibleForTesting
  void resetForTest() {
    prefs = null;
    loading = null;
  }
}
