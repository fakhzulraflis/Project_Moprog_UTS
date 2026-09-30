import 'package:flutter_test/flutter_test.dart';
import 'package:moprog_uts/services/player_progress.dart';
import 'package:moprog_uts/widgets/reward_chest.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final progress = PlayerProgress.instance;

  DailyQuest questById(String id) =>
      PlayerProgress.dailyQuests.firstWhere((q) => q.id == id);

  // Mulai tiap test dengan data HP yang bersih (atau data tertentu).
  Future<void> start([Map<String, Object> saved = const {}]) async {
    SharedPreferences.setMockInitialValues(saved);
    progress.resetForTest();
    await progress.load();
  }

  test('pemain baru mulai dengan 50 gem dan semua peti terkunci', () async {
    await start();

    expect(progress.gems, 50);
    for (final quest in PlayerProgress.dailyQuests) {
      expect(progress.chestStateOf(quest), ChestState.locked);
    }
    expect(progress.monthlyChestState, ChestState.locked);
  });

  test('menyelesaikan 3 lesson membuka peti quest lesson', () async {
    await start();

    for (var i = 0; i < 3; i++) {
      expect(await progress.completeLesson(), PlayerProgress.xpPerLesson);
    }

    expect(progress.lessonsToday, 3);
    expect(progress.xpToday, 30);
    expect(
      progress.chestStateOf(questById('complete_lessons')),
      ChestState.ready,
    );
    expect(progress.chestStateOf(questById('earn_xp')), ChestState.locked);
    expect(progress.questsThisMonth, 1);
  });

  test('peti hanya bisa diklaim sekali dan isinya masuk saldo', () async {
    await start();
    for (var i = 0; i < 3; i++) {
      await progress.completeLesson();
    }
    final quest = questById('complete_lessons');

    await progress.claimQuest(quest, const ChestLoot(LootType.gems, 20));
    expect(progress.gems, 70);
    expect(progress.chestStateOf(quest), ChestState.claimed);

    await progress.claimQuest(quest, const ChestLoot(LootType.gems, 20));
    expect(progress.gems, 70);
  });

  test('XP dari peti ikut menggerakkan quest XP', () async {
    await start();
    for (var i = 0; i < 3; i++) {
      await progress.completeLesson();
    }

    await progress.claimQuest(
      questById('complete_lessons'),
      const ChestLoot(LootType.xp, 25),
    );

    expect(progress.xpToday, 55);
    expect(progress.chestStateOf(questById('earn_xp')), ChestState.ready);
    expect(progress.questsThisMonth, 2);
  });

  test('quest harian di-reset kalau sudah ganti hari', () async {
    final today = PlayerProgress.dayKey(DateTime.now());
    final thisMonth = PlayerProgress.monthKey(DateTime.now());

    await start({
      'day': '2000-01-01',
      'month': thisMonth,
      'xpToday': 40,
      'lessonsToday': 3,
      'claimedToday': ['complete_lessons'],
      'questsThisMonth': 12,
      'gems': 99,
    });

    expect(progress.day, today);
    expect(progress.xpToday, 0);
    expect(progress.lessonsToday, 0);
    expect(progress.claimedToday, isEmpty);
    // Yang bukan harian tidak ikut di-reset
    expect(progress.questsThisMonth, 12);
    expect(progress.gems, 99);
  });

  test('challenge bulanan di-reset kalau sudah ganti bulan', () async {
    await start({
      'day': '2000-01-31',
      'month': '2000-01',
      'questsThisMonth': 30,
      'monthlyClaimed': true,
    });

    expect(progress.questsThisMonth, 0);
    expect(progress.monthlyClaimed, isFalse);
  });

  test('peti emas bulanan terbuka setelah 30 quest', () async {
    await start({
      'day': PlayerProgress.dayKey(DateTime.now()),
      'month': PlayerProgress.monthKey(DateTime.now()),
      'questsThisMonth': 30,
    });

    expect(progress.monthlyChestState, ChestState.ready);
    await progress.claimMonthly(const ChestLoot(LootType.gems, 50));
    expect(progress.gems, 100);
    expect(progress.monthlyChestState, ChestState.claimed);
  });

  test('XP Boost membuat XP lesson jadi 2x lipat', () async {
    await start();

    expect(await progress.buyXpBoost(40), isTrue);
    expect(progress.gems, 10);
    expect(progress.isXpBoostActive, isTrue);
    expect(await progress.completeLesson(), PlayerProgress.xpPerLesson * 2);

    // Tidak bisa dibeli lagi selama masih aktif
    expect(await progress.buyXpBoost(0), isFalse);
  });

  test('pembelian gagal kalau gem tidak cukup', () async {
    await start({'gems': 10});

    expect(await progress.spendGems(30), isFalse);
    expect(await progress.buyBonusHearts(25, 2), isFalse);
    expect(progress.gems, 10);
    expect(progress.bonusHearts, 0);
  });

  test('hati tambahan dipakai sekali di lesson berikutnya', () async {
    await start();

    await progress.buyBonusHearts(25, 2);
    await progress.addLoot(const ChestLoot(LootType.hearts, 1));

    expect(await progress.takeBonusHearts(), 3);
    expect(await progress.takeBonusHearts(), 0);
  });

  test('data tetap ada setelah aplikasi dibuka ulang', () async {
    await start();
    await progress.completeLesson();
    await progress.recordCorrectAnswer();
    await progress.spendGems(30);

    // Simulasi aplikasi ditutup lalu dibuka lagi
    progress.resetForTest();
    await progress.load();

    expect(progress.lessonsToday, 1);
    expect(progress.correctToday, 1);
    expect(progress.gems, 20);
    expect(progress.totalXp, PlayerProgress.xpPerLesson);
  });

  test('isi peti emas selalu lebih besar dari peti perunggu', () {
    for (var i = 0; i < 200; i++) {
      final bronze = ChestLoot.roll(ChestTier.bronze);
      final gold = ChestLoot.roll(ChestTier.gold);
      if (bronze.type == LootType.gems) expect(bronze.amount, inInclusiveRange(5, 10));
      if (gold.type == LootType.gems) expect(gold.amount, inInclusiveRange(40, 60));
      if (gold.type == LootType.xp) expect(gold.amount, inInclusiveRange(60, 100));
    }
  });
}
