import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:moprog_uts/services/auth_session.dart';
import 'package:moprog_uts/services/duck_pet.dart';
import 'package:moprog_uts/services/inventory_service.dart';
import 'package:moprog_uts/services/player_progress.dart';
import 'package:moprog_uts/widgets/reward_chest.dart';
import 'package:moprog_uts/widgets/spin_wheel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_inventory_api.dart';

void main() {
  final progress = PlayerProgress.instance;
  final inventory = InventoryService.instance;
  late FakeInventoryApi server;

  DailyQuest questById(String id) => QuestPool.byId(id)!;

  const fixedQuests = ['earn_xp', 'complete_lessons', 'pet_duck'];

  Future<void> start([Map<String, Object> saved = const {}]) async {
    SharedPreferences.setMockInitialValues({
      'day': PlayerProgress.dayKey(DateTime.now()),
      'todayQuests': fixedQuests,
      ...saved,
    });

    progress.resetForTest();
    DuckPet.instance.resetForTest();
    server = FakeInventoryApi();
    inventory.resetForTest(server);
    AuthSession.instance.setForTest(token: 'token-test', userId: 1);
    await progress.load();
  }

  test('pemain baru mulai dengan 50 gem dan semua peti terkunci', () async {
    await start();

    expect(progress.gems, 50);

    for (final quest in progress.dailyQuests) {
      expect(progress.chestStateOf(quest), ChestState.locked);
    }

    expect(progress.monthlyChestState, ChestState.locked);
  });

  test('menyelesaikan 3 lesson membuka peti quest lesson', () async {
    await start();

    for (var i = 1; i <= 3; i++) {
      expect(await progress.completeLesson(i), PlayerProgress.xpPerLesson);
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

    for (var i = 1; i <= 3; i++) {
      await progress.completeLesson(i);
    }

    final quest = questById('complete_lessons');

    final before = progress.gems;

    await progress.claimQuest(quest, const ChestLoot(LootType.gems, 20));

    expect(progress.gems, before + 20);

    expect(progress.chestStateOf(quest), ChestState.claimed);

    await progress.claimQuest(quest, const ChestLoot(LootType.gems, 20));

    expect(progress.gems, before + 20);
  });

  test('XP dari peti ikut menggerakkan quest XP', () async {
    await start();

    for (var i = 1; i <= 3; i++) {
      await progress.completeLesson(i);
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

  test('XP Ganda dari toko masuk inventori dulu, belum aktif', () async {
    await start();

    expect(await progress.buyItem('xp_boost_15', 40), isNull);
    expect(progress.gems, 10);
    expect(inventory.unusedCount, 1);
    expect(progress.isXpBoostActive, isFalse);
    expect(await progress.completeLesson(), PlayerProgress.xpPerLesson);
  });

  test('XP Ganda yang dipakai dari inventori membuat XP 2x lipat', () async {
    await start();
    await progress.buyItem('xp_boost_15', 40);

    expect(await inventory.use(inventory.items.first), isNull);
    expect(progress.isXpBoostActive, isTrue);
    expect(progress.xpBoostLeft.inMinutes, greaterThanOrEqualTo(14));
    expect(await progress.completeLesson(), PlayerProgress.xpPerLesson * 2);
  });

  test('beli barang gagal: gem tidak dipotong', () async {
    await start({'gems': 10});
    expect(await progress.buyItem('xp_boost_15', 40), 'Gem kamu belum cukup.');
    expect(inventory.unusedCount, 0);

    await start();
    server.failing = true;
    expect(await progress.buyItem('xp_boost_15', 40), isNotNull);
    expect(progress.gems, 50);
  });

  test('barang dari peti masuk inventori, gagal = diganti gem', () async {
    await start();
    for (var i = 0; i < 3; i++) {
      await progress.completeLesson();
    }
    final before = progress.gems;
    await progress.claimQuest(
      questById('complete_lessons'),
      const ChestLoot.item('unlimited_hearts_30'),
    );
    expect(inventory.items.single.key, 'unlimited_hearts_30');
    expect(progress.gems, before);

    // Kalau server mati, hadiahnya diganti gem supaya tidak hilang
    server.failing = true;
    await progress.addLoot(const ChestLoot.item('xp_boost_60'));
    expect(progress.gems, before + PlayerProgress.itemFallbackGems);
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

    await progress.completeLesson(1);
    await progress.recordCorrectAnswer();
    await progress.spendGems(30);

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

      if (bronze.type == LootType.gems) {
        expect(bronze.amount, inInclusiveRange(5, 10));
      }

      if (gold.type == LootType.gems) {
        expect(gold.amount, inInclusiveRange(40, 60));
      }

      if (gold.type == LootType.xp) {
        expect(gold.amount, inInclusiveRange(60, 100));
      }
    }
  });

  group('quest mingguan', () {
    test('lesson dihitung ke quest mingguan dan peti terbuka di 20', () async {
      await start({
        'day': PlayerProgress.dayKey(DateTime.now()),
        'week': PlayerProgress.weekKey(DateTime.now()),
        'lessonsThisWeek': 19,
      });

      expect(progress.weeklyChestState, ChestState.locked);

      await progress.completeLesson(1);

      expect(progress.lessonsThisWeek, 20);

      expect(progress.weeklyChestState, ChestState.ready);

      await progress.claimWeekly(const ChestLoot(LootType.gems, 20));

      expect(progress.weeklyChestState, ChestState.claimed);

      expect(progress.gems, 70);
    });

    test('quest mingguan di-reset kalau sudah ganti minggu', () async {
      await start({
        'week': '2000-01-03',
        'lessonsThisWeek': 20,
        'weeklyClaimed': true,
      });

      expect(progress.lessonsThisWeek, 0);

      expect(progress.weeklyClaimed, isFalse);
    });

    test('kunci minggu selalu hari Senin', () {
      expect(PlayerProgress.weekKey(DateTime(2026, 10, 1)), '2026-09-28');

      expect(PlayerProgress.weekKey(DateTime(2026, 9, 28)), '2026-09-28');

      expect(PlayerProgress.weekKey(DateTime(2026, 10, 4)), '2026-09-28');
    });
  });

  group('streak', () {
    final now = DateTime.now();

    test('belajar hari ini melanjutkan streak dari kemarin', () async {
      await start({
        'lastStudyDay': PlayerProgress.yesterdayKey(now),
        'streak': 4,
        'bestStreak': 4,
      });

      expect(progress.streak, 4);
      expect(progress.studiedToday, isFalse);

      await progress.completeLesson(1);

      expect(progress.streak, 5);
      expect(progress.bestStreak, 5);
      expect(progress.studiedToday, isTrue);

      await progress.completeLesson(2);

      expect(progress.streak, 5);
    });

    test('streak putus kalau bolos lebih dari sehari', () async {
      await start({'lastStudyDay': '2000-01-01', 'streak': 9, 'bestStreak': 9});

      expect(progress.streak, 0);

      await progress.completeLesson(1);

      expect(progress.streak, 1);
      expect(progress.bestStreak, 9);
    });

    test('target streak dari halaman Streak Goal tersimpan', () async {
      await start();

      await progress.setStreakGoal(14);

      progress.resetForTest();

      await progress.load();

      expect(progress.streakGoal, 14);
    });
  });

  group('roda hadiah harian', () {
    int indexOf(PrizeType type, int amount) =>
        SpinPrize.all.indexWhere((p) => p.type == type && p.amount == amount);

    test('total peluang semua hadiah 100%', () {
      final total = SpinPrize.all.fold(0, (sum, p) => sum + p.chance);

      expect(total, 100);
    });

    test('angka acak dipetakan ke hadiah sesuai peluangnya', () {
      expect(SpinPrize.pickIndex(FixedRandom(0)), 0);

      expect(SpinPrize.pickIndex(FixedRandom(19)), 0);

      expect(SpinPrize.pickIndex(FixedRandom(20)), 1);

      expect(SpinPrize.pickIndex(FixedRandom(99)), SpinPrize.all.length - 1);
    });

    test('roda hanya bisa diputar sekali sehari', () async {
      await start();

      final jackpot = indexOf(PrizeType.gems, 50);

      expect(progress.canSpin, isTrue);

      expect(await progress.claimSpin(jackpot), isTrue);

      expect(progress.gems, 100);

      expect(progress.canSpin, isFalse);

      expect(progress.lastSpinPrize, jackpot);

      expect(await progress.claimSpin(jackpot), isFalse);

      expect(progress.gems, 100);
    });

    test('roda bisa diputar lagi besoknya', () async {
      await start({'lastSpinDay': '2000-01-01'});

      expect(progress.canSpin, isTrue);
    });

    test('hadiah XP Ganda dari roda masuk ke inventori', () async {
      await start();

      await progress.claimSpin(indexOf(PrizeType.xpBoost, 15));
      expect(inventory.items.single.key, PlayerProgress.spinBoostItem);
      expect(progress.isXpBoostActive, isFalse);
    });
  });

  group('quest acak harian', () {
    test('tiap hari 3 quest: 2 belajar dan 1 santai, grup berbeda', () {
      for (var d = 1; d <= 28; d++) {
        final day = PlayerProgress.dayKey(DateTime(2026, 10, d));

        final quests = QuestPool.pickForDay(day).map(QuestPool.byId).toList();

        expect(quests.length, 3);

        expect(quests.where((q) => q!.learning).length, 2);

        expect(quests.map((q) => q!.group).toSet().length, 3);
      }
    });

    test('hari yang sama selalu dapat quest yang sama', () {
      expect(
        QuestPool.pickForDay('2026-10-07'),
        QuestPool.pickForDay('2026-10-07'),
      );
    });

    test('quest berbeda-beda antar hari', () {
      final sets = {
        for (var d = 1; d <= 28; d++)
          QuestPool.pickForDay(PlayerProgress.dayKey(DateTime(2026, 10, d)))
              .join(','),
      };

      expect(sets.length, greaterThan(5));
    });

    test('pengguna lama tanpa daftar quest dibuatkan otomatis', () async {
      await start({'todayQuests': <String>[]});

      expect(progress.dailyQuests.length, 3);
    });

    test('quest bisa diganti sekali sehari dengan bayar gem', () async {
      await start();

      final old = questById('earn_xp');

      final replacement = await progress.rerollQuest(old);

      expect(replacement, isNotNull);

      expect(replacement!.learning, isTrue);

      expect(replacement.group, 'correct');

      expect(progress.todayQuestIds, isNot(contains('earn_xp')));

      expect(progress.todayQuestIds, contains(replacement.id));

      expect(progress.gems, 50 - PlayerProgress.rerollPrice);

      expect(await progress.rerollQuest(replacement), isNull);

      expect(progress.gems, 50 - PlayerProgress.rerollPrice);
    });

    test('pengganti quest tidak boleh yang sudah selesai', () async {
      await start({'lessonsToday': 1});

      for (var i = 0; i < 20; i++) {
        final pick = QuestPool.replacementFor(questById('correct_answers'), [
          questById('earn_xp'),
          questById('correct_answers'),
        ], isDone: (q) => q.progressOf(progress) >= q.target);

        expect(pick!.id, 'complete_lessons');
      }
    });

    test('quest yang sudah selesai tidak bisa diganti', () async {
      await start();

      for (var i = 1; i <= 3; i++) {
        await progress.completeLesson(i);
      }

      expect(progress.canReroll(questById('complete_lessons')), isFalse);

      expect(progress.canReroll(questById('earn_xp')), isTrue);
    });

    test('quest santai: putar roda dan belanja di toko', () async {
      await start();

      expect(progress.progressOf(questById('daily_spin')), 0);

      await progress.claimSpin(0);

      expect(progress.progressOf(questById('daily_spin')), 1);

      expect(progress.progressOf(questById('shop_purchase')), 0);

      await progress.buyMysteryChest(30);

      expect(progress.progressOf(questById('shop_purchase')), 1);

      expect(progress.gems, 50 + 5 - 30);
    });
  });
}

class FixedRandom implements Random {
  final int value;

  FixedRandom(this.value);

  @override
  int nextInt(int max) => value;

  @override
  double nextDouble() => value / 100;

  @override
  bool nextBool() => value.isOdd;
}
