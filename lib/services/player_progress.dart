import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/reward_chest.dart';
import '../widgets/spin_wheel.dart';
import 'api_service.dart';
import 'auth_session.dart';
import 'duck_pet.dart';
import 'inventory_service.dart';
import 'progress_sync.dart';
import 'quest_pool.dart';

export 'quest_pool.dart' show DailyQuest, QuestPool;

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
  static const int rerollPrice = 20;

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
  int petsToday = 0;
  int feedsToday = 0;
  int purchasesToday = 0;
  Set<String> completedToday = {};
  Set<String> claimedToday = {};

  // Quest harian hari ini, dipilih acak dari QuestPool
  List<String> todayQuestIds = [];
  bool rerolledToday = false;

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

  Set<String> studiedDays = {};

  // Kelipatan streakGoal yang sudah pernah dapat reward, supaya reward
  // tidak diberikan dua kali untuk kelipatan yang sama (misal 7, 14, 21).
  Set<int> claimedStreakMilestones = {};

  // Diisi sesaat setelah streak baru saja mencapai kelipatan streakGoal,
  // supaya UI bisa menampilkan perayaan sekali lalu dikosongkan lagi
  // lewat clearPendingStreakMilestone(). Tidak disimpan ke disk karena
  // sifatnya cuma notifikasi sekali-tampil, bukan data permanen.
  int? pendingStreakMilestone;

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
    petsToday = p.getInt('petsToday') ?? 0;
    feedsToday = p.getInt('feedsToday') ?? 0;
    purchasesToday = p.getInt('purchasesToday') ?? 0;
    todayQuestIds = p.getStringList('todayQuests') ?? [];
    rerolledToday = p.getBool('rerolledToday') ?? false;
    completedToday = (p.getStringList('completedToday') ?? []).toSet();
    claimedToday = (p.getStringList('claimedToday') ?? []).toSet();

    week = p.getString('week') ?? '';
    lessonsThisWeek = p.getInt('lessonsThisWeek') ?? 0;
    weeklyClaimed = p.getBool('weeklyClaimed') ?? false;

    month = p.getString('month') ?? '';
    questsThisMonth = p.getInt('questsThisMonth') ?? 0;
    monthlyClaimed = p.getBool('monthlyClaimed') ?? false;

    studiedDays = (p.getStringList('studiedDays') ?? []).toSet();
    claimedStreakMilestones = (p.getStringList('claimedStreakMilestones') ?? [])
        .map(int.parse)
        .toSet();
    storedStreak = p.getInt('streak') ?? 0;
    bestStreak = p.getInt('bestStreak') ?? 0;
    lastStudyDay = p.getString('lastStudyDay') ?? '';
    streakGoal = p.getInt('streakGoal') ?? 7;

    lastSpinDay = p.getString('lastSpinDay') ?? '';
    lastSpinPrize = p.getInt('lastSpinPrize') ?? -1;

    prefs = p;
    var changed = rollOver();

    // Pengguna lama belum punya daftar quest acak, jadi dibuatkan sekarang
    if (dailyQuests.length != QuestPool.questsPerDay) {
      todayQuestIds = QuestPool.pickForDay(day);
      changed = true;
    }

    if (changed) await save();
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
      p.setInt('petsToday', petsToday),
      p.setInt('feedsToday', feedsToday),
      p.setInt('purchasesToday', purchasesToday),
      p.setStringList('todayQuests', todayQuestIds),
      p.setBool('rerolledToday', rerolledToday),
      p.setStringList('completedToday', completedToday.toList()),
      p.setStringList('claimedToday', claimedToday.toList()),
      p.setString('week', week),
      p.setInt('lessonsThisWeek', lessonsThisWeek),
      p.setBool('weeklyClaimed', weeklyClaimed),
      p.setString('month', month),
      p.setInt('questsThisMonth', questsThisMonth),
      p.setBool('monthlyClaimed', monthlyClaimed),
      p.setStringList('studiedDays', studiedDays.toList()),
      p.setStringList(
        'claimedStreakMilestones',
        claimedStreakMilestones.map((e) => e.toString()).toList(),
      ),
      p.setInt('streak', storedStreak),
      p.setInt('bestStreak', bestStreak),
      p.setString('lastStudyDay', lastStudyDay),
      p.setInt('streakGoal', streakGoal),
      p.setString('lastSpinDay', lastSpinDay),
      p.setInt('lastSpinPrize', lastSpinPrize),
    ]);

    // Kirim juga ke database supaya progres tersimpan di akun user
    ProgressSync.instance.schedulePush();
  }

  // Muat ulang dari HP. Dipakai setelah progres diganti dari server
  // (misalnya waktu login atau ganti akun).
  Future<void> reload() {
    prefs = null;
    loading = null;
    return load();
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
      petsToday = 0;
      feedsToday = 0;
      purchasesToday = 0;
      completedToday = {};
      claimedToday = {};
      todayQuestIds = QuestPool.pickForDay(day);
      rerolledToday = false;
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

  // Quest harian hari ini, sesuai urutan yang dipilih.
  List<DailyQuest> get dailyQuests =>
      todayQuestIds.map(QuestPool.byId).whereType<DailyQuest>().toList();

  bool get spunToday => lastSpinDay == day;

  // Quest bisa diganti sekali sehari, selama belum selesai.
  bool canReroll(DailyQuest quest) =>
      !rerolledToday && chestStateOf(quest) == ChestState.locked;

  // Ganti satu quest dengan quest lain secara acak, bayar pakai gem.
  // Mengembalikan quest penggantinya, atau null kalau gagal.
  Future<DailyQuest?> rerollQuest(DailyQuest quest) async {
    DailyQuest? replacement;
    await update(() {
      if (!canReroll(quest) || gems < rerollPrice) return;
      replacement = QuestPool.replacementFor(
        quest,
        dailyQuests,
        isDone: (q) => q.progressOf(this) >= q.target,
      );
      if (replacement == null) return;

      gems -= rerollPrice;
      rerolledToday = true;
      final index = todayQuestIds.indexOf(quest.id);
      todayQuestIds = [...todayQuestIds]..[index] = replacement!.id;
    });
    return replacement;
  }

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

  Future<void> claimQuest(DailyQuest quest, ChestLoot loot) async {
    var claimed = false;
    await update(() {
      if (chestStateOf(quest) != ChestState.ready) return;
      claimedToday.add(quest.id);
      applyLoot(loot);
      claimed = true;
    });
    if (claimed) await deliverItem(loot);
  }

  ChestState get weeklyChestState {
    if (weeklyClaimed) return ChestState.claimed;
    return lessonsThisWeek >= weeklyTarget
        ? ChestState.ready
        : ChestState.locked;
  }

  Future<void> claimWeekly(ChestLoot loot) async {
    var claimed = false;
    await update(() {
      if (weeklyChestState != ChestState.ready) return;
      weeklyClaimed = true;
      applyLoot(loot);
      claimed = true;
    });
    if (claimed) await deliverItem(loot);
  }

  Future<void> claimMonthly(ChestLoot loot) async {
    var claimed = false;
    await update(() {
      if (monthlyChestState != ChestState.ready) return;
      monthlyClaimed = true;
      applyLoot(loot);
      claimed = true;
    });
    if (claimed) await deliverItem(loot);
  }

  // Gem pengganti kalau barang dari peti gagal disimpan ke inventory
  // (misalnya server mati), supaya hadiahnya tidak hilang begitu saja.
  static const int itemFallbackGems = 20;

  // Barang dari peti tidak langsung aktif, tapi dikirim ke inventory.
  Future<void> deliverItem(ChestLoot loot) async {
    if (loot.type != LootType.item) return;
    final saved = await InventoryService.instance.add(
      loot.itemKey!,
      source: 'chest',
    );
    if (!saved) await update(() => gems += itemFallbackGems);
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
      case LootType.item:
        // Barang inventory diurus deliverItem(), bukan langsung ke saldo
        break;
    }
  }

  // ---------- Dipanggil dari halaman lesson ----------

  // XP Ganda aktif kalau dipakai dari inventory. xpBoostUntil masih dibaca
  // untuk data lama sebelum ada inventory.
  bool get isXpBoostActive =>
      InventoryService.instance.isActive(ItemEffect.xpBoost) ||
      (xpBoostUntil != null && DateTime.now().isBefore(xpBoostUntil!));

  Duration get xpBoostLeft {
    final fromInventory = InventoryService.instance.timeLeft(
      ItemEffect.xpBoost,
    );
    final legacy =
        xpBoostUntil != null && DateTime.now().isBefore(xpBoostUntil!)
        ? xpBoostUntil!.difference(DateTime.now())
        : Duration.zero;
    return fromInventory > legacy ? fromInventory : legacy;
  }

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

    // Quacko ikut senang dan dapat XP kalau pemainnya belajar
    await DuckPet.instance.onLessonCompleted(earned);

    _syncXpToServer();

    return earned;
  }

  Future<void> _syncXpToServer() async {
    if (!AuthSession.instance.isLoggedIn) return;
    try {
      await http.put(
        Uri.parse('${ApiService.baseUrl}/profile/xp'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthSession.instance.token}',
        },
        body: jsonEncode({'xp': totalXp}),
      );
    } catch (_) {

    }
  }

  Future<void> recordCorrectAnswer() {
    return update(() => correctToday++);
  }

  // Dipanggil DuckPet untuk quest santai.
  Future<void> recordPet() => update(() => petsToday++);

  Future<void> recordFeed() => update(() => feedsToday++);

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
    studiedDays.add(today);
    if (lastStudyDay == today) return;

    storedStreak = lastStudyDay == yesterdayKey(now) ? storedStreak + 1 : 1;
    lastStudyDay = today;
    if (storedStreak > bestStreak) bestStreak = storedStreak;

    if (streakGoal > 0 &&
        storedStreak % streakGoal == 0 &&
        claimedStreakMilestones.add(storedStreak)) {
      applyLoot(ChestLoot(LootType.gems, 20));
      pendingStreakMilestone = storedStreak;
    }
  }

  int get streakCycleProgress {
    if (streakGoal <= 0 || streak == 0) return 0;
    final remainder = streak % streakGoal;
    return remainder == 0 ? streakGoal : remainder;
  }

  void clearPendingStreakMilestone() {
    pendingStreakMilestone = null;
    notifyListeners();
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
    final prize = SpinPrize.all[index];
    await update(() {
      if (!canSpin) return;
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
          // Masuk ke inventory, dikirim setelah data disimpan (di bawah)
          break;
        case PrizeType.none:
          break;
      }
      ok = true;
    });

    if (ok && prize.type == PrizeType.xpBoost) {
      await deliverItem(const ChestLoot.item(spinBoostItem));
    }
    return ok;
  }

  // Hadiah XP Ganda dari roda masuk ke inventory sebagai barang ini.
  static const String spinBoostItem = 'xp_boost_15';

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

  // Beli barang inventory di toko. Barang disimpan ke inventory dulu,
  // gem baru dipotong kalau penyimpanan berhasil. Mengembalikan pesan
  // error, atau null kalau berhasil.
  Future<String?> buyItem(String itemKey, int price) async {
    await load();
    if (gems < price) return 'Gem kamu belum cukup.';

    final saved = await InventoryService.instance.add(itemKey, source: 'shop');
    if (!saved) {
      return InventoryService.instance.error ?? 'Gagal menyimpan barang.';
    }

    await update(() {
      gems -= price;
      purchasesToday++;
    });
    return null;
  }

  Future<bool> buyBonusHearts(int price, int amount) async {
    var ok = false;
    await update(() {
      if (gems < price) return;
      gems -= price;
      bonusHearts += amount;
      purchasesToday++;
      ok = true;
    });
    return ok;
  }

  // Bayar Mystery Chest. Isinya dibuka di halaman toko.
  Future<bool> buyMysteryChest(int price) async {
    var ok = false;
    await update(() {
      if (gems < price) return;
      gems -= price;
      purchasesToday++;
      ok = true;
    });
    return ok;
  }

  // Dipakai Peti Misteri dari toko.
  Future<void> addLoot(ChestLoot loot) async {
    await update(() => applyLoot(loot));
    await deliverItem(loot);
  }

  @visibleForTesting
  void resetForTest() {
    prefs = null;
    loading = null;
  }
}
