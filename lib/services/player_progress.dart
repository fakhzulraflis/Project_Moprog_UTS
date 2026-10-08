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

class PlayerProgress extends ChangeNotifier {
  PlayerProgress._();

  static final PlayerProgress instance = PlayerProgress._();

  static const int xpPerLesson = 10;
  static const int monthlyTarget = 30;
  static const int weeklyTarget = 20;
  static const int rerollPrice = 20;
  static const int itemFallbackGems = 20;
  static const String spinBoostItem = 'xp_boost_15';

  SharedPreferences? prefs;
  Future<void>? loading;

  bool get isLoaded => prefs != null;

  int gems = 50;
  int totalXp = 0;
  int bonusHearts = 0;
  DateTime? xpBoostUntil;

  Set<int> completedLessonIds = {};

  String day = '';
  int xpToday = 0;
  int lessonsToday = 0;
  int correctToday = 0;
  int petsToday = 0;
  int feedsToday = 0;
  int purchasesToday = 0;
  Set<String> completedToday = {};
  Set<String> claimedToday = {};

  List<String> todayQuestIds = [];
  bool rerolledToday = false;

  String week = '';
  int lessonsThisWeek = 0;
  bool weeklyClaimed = false;

  String month = '';
  int questsThisMonth = 0;
  bool monthlyClaimed = false;

  int storedStreak = 0;
  int bestStreak = 0;
  String lastStudyDay = '';
  int streakGoal = 7;

  Set<String> studiedDays = {};

  Set<int> claimedStreakMilestones = {};

  int? pendingStreakMilestone;

  String lastSpinDay = '';
  int lastSpinPrize = -1;

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

    completedLessonIds = (p.getStringList('completedLessonIds') ?? [])
        .map(int.parse)
        .toSet();

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

    if (dailyQuests.length != QuestPool.questsPerDay) {
      todayQuestIds = QuestPool.pickForDay(day);
      changed = true;
    }

    if (changed) {
      await save();
    }

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
      p.setStringList(
        'completedLessonIds',
        completedLessonIds.map((e) => e.toString()).toList(),
      ),
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

  static String weekKey(DateTime d) =>
      dayKey(DateTime(d.year, d.month, d.day - (d.weekday - 1)));

  static String yesterdayKey(DateTime d) =>
      dayKey(DateTime(d.year, d.month, d.day - 1));

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

  Future<void> refresh() async {
    await load();

    if (rollOver()) {
      notifyListeners();
      await save();
    }
  }

  void checkQuestCompletion() {
    for (final quest in dailyQuests) {
      if (quest.progressOf(this) >= quest.target &&
          completedToday.add(quest.id)) {
        questsThisMonth++;
      }
    }
  }

  List<DailyQuest> get dailyQuests =>
      todayQuestIds.map(QuestPool.byId).whereType<DailyQuest>().toList();

  bool get spunToday => lastSpinDay == day;

  bool canReroll(DailyQuest quest) =>
      !rerolledToday && chestStateOf(quest) == ChestState.locked;

  Future<DailyQuest?> rerollQuest(DailyQuest quest) async {
    DailyQuest? replacement;

    await update(() {
      if (!canReroll(quest) || gems < rerollPrice) {
        return;
      }

      replacement = QuestPool.replacementFor(
        quest,
        dailyQuests,
        isDone: (q) => q.progressOf(this) >= q.target,
      );

      if (replacement == null) {
        return;
      }

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
    if (claimedToday.contains(quest.id)) {
      return ChestState.claimed;
    }

    return quest.progressOf(this) >= quest.target
        ? ChestState.ready
        : ChestState.locked;
  }

  ChestState get monthlyChestState {
    if (monthlyClaimed) {
      return ChestState.claimed;
    }

    return questsThisMonth >= monthlyTarget
        ? ChestState.ready
        : ChestState.locked;
  }

  Future<void> claimQuest(DailyQuest quest, ChestLoot loot) async {
    var claimed = false;

    await update(() {
      if (chestStateOf(quest) != ChestState.ready) {
        return;
      }

      claimedToday.add(quest.id);
      applyLoot(loot);
      claimed = true;
    });

    if (claimed) {
      await deliverItem(loot);
    }
  }

  ChestState get weeklyChestState {
    if (weeklyClaimed) {
      return ChestState.claimed;
    }

    return lessonsThisWeek >= weeklyTarget
        ? ChestState.ready
        : ChestState.locked;
  }

  Future<void> claimWeekly(ChestLoot loot) async {
    var claimed = false;

    await update(() {
      if (weeklyChestState != ChestState.ready) {
        return;
      }

      weeklyClaimed = true;
      applyLoot(loot);
      claimed = true;
    });

    if (claimed) {
      await deliverItem(loot);
    }
  }

  Future<void> claimMonthly(ChestLoot loot) async {
    var claimed = false;

    await update(() {
      if (monthlyChestState != ChestState.ready) {
        return;
      }

      monthlyClaimed = true;
      applyLoot(loot);
      claimed = true;
    });

    if (claimed) {
      await deliverItem(loot);
    }
  }

  Future<void> deliverItem(ChestLoot loot) async {
    if (loot.type != LootType.item) {
      return;
    }

    final saved = await InventoryService.instance.add(
      loot.itemKey!,
      source: 'chest',
    );

    if (!saved) {
      await update(() => gems += itemFallbackGems);
    }
  }

  void applyLoot(ChestLoot loot) {
    switch (loot.type) {
      case LootType.gems:
        gems += loot.amount;
      case LootType.xp:
        totalXp += loot.amount;
        xpToday += loot.amount;
      case LootType.hearts:
        bonusHearts += loot.amount;
      case LootType.item:
        break;
    }
  }

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

  bool isLessonCompleted(int lessonId) {
    return completedLessonIds.contains(lessonId);
  }

  int completedLessonsInUnit(List<int> lessonIds) {
    return lessonIds.where(completedLessonIds.contains).length;
  }

  bool isUnitCompleted(List<int> lessonIds) {
    if (lessonIds.isEmpty) {
      return false;
    }

    return lessonIds.every(completedLessonIds.contains);
  }

  Future<int> completeLesson(int lessonId) async {
    var earned = 0;
    var completedNow = false;

    await update(() {
      if (completedLessonIds.contains(lessonId)) {
        return;
      }

      completedLessonIds.add(lessonId);

      earned = xpPerLesson;

      if (isXpBoostActive) {
        earned *= 2;
      }

      totalXp += earned;
      xpToday += earned;
      lessonsToday++;
      lessonsThisWeek++;

      recordStudyDay(DateTime.now());

      completedNow = true;
    });

    if (completedNow) {
      await DuckPet.instance.onLessonCompleted(earned);
      await _syncXpToServer();
    }

    return earned;
  }

  Future<void> _syncXpToServer() async {
    if (!AuthSession.instance.isLoggedIn) {
      return;
    }

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
    } catch (_) {}
  }

  Future<void> recordCorrectAnswer() {
    return update(() => correctToday++);
  }

  Future<void> recordPet() {
    return update(() => petsToday++);
  }

  Future<void> recordFeed() {
    return update(() => feedsToday++);
  }

  Future<int> takeBonusHearts() async {
    var taken = 0;

    await update(() {
      taken = bonusHearts;
      bonusHearts = 0;
    });

    return taken;
  }

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

    if (lastStudyDay == today) {
      return;
    }

    storedStreak = lastStudyDay == yesterdayKey(now) ? storedStreak + 1 : 1;

    lastStudyDay = today;

    if (storedStreak > bestStreak) {
      bestStreak = storedStreak;
    }

    if (streakGoal > 0 &&
        storedStreak % streakGoal == 0 &&
        claimedStreakMilestones.add(storedStreak)) {
      applyLoot(ChestLoot(LootType.gems, 20));

      pendingStreakMilestone = storedStreak;
    }
  }

  int get streakCycleProgress {
    if (streakGoal <= 0 || streak == 0) {
      return 0;
    }

    final remainder = streak % streakGoal;

    return remainder == 0 ? streakGoal : remainder;
  }

  void clearPendingStreakMilestone() {
    pendingStreakMilestone = null;
    notifyListeners();
  }

  Future<void> setStreakGoal(int days) {
    return update(() => streakGoal = days);
  }

  bool get canSpin => lastSpinDay != dayKey(DateTime.now());

  Future<bool> claimSpin(int index) async {
    var ok = false;

    if (index < 0 || index >= SpinPrize.all.length) {
      return false;
    }

    final prize = SpinPrize.all[index];

    await update(() {
      if (!canSpin) {
        return;
      }

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

  Future<bool> spendGems(int price) async {
    var ok = false;

    await update(() {
      if (gems < price) {
        return;
      }

      gems -= price;
      ok = true;
    });

    return ok;
  }

  Future<String?> buyItem(String itemKey, int price) async {
    await load();

    if (gems < price) {
      return 'Gem kamu belum cukup.';
    }

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
      if (gems < price) {
        return;
      }

      gems -= price;
      bonusHearts += amount;
      purchasesToday++;
      ok = true;
    });

    return ok;
  }

  Future<bool> buyMysteryChest(int price) async {
    var ok = false;

    await update(() {
      if (gems < price) {
        return;
      }

      gems -= price;
      purchasesToday++;
      ok = true;
    });

    return ok;
  }

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
