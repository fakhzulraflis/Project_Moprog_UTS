import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:moprog_uts/services/duck_pet.dart';
import 'package:moprog_uts/services/player_progress.dart';
import 'package:moprog_uts/widgets/reward_chest.dart';
import 'package:moprog_uts/widgets/spin_wheel.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final progress = PlayerProgress.instance;

  DailyQuest questById(String id) =>
      PlayerProgress.dailyQuests.firstWhere((q) => q.id == id);

  // Mulai tiap test dengan data HP yang bersih (atau data tertentu).
  Future<void> start([Map<String, Object> saved = const {}]) async {
    SharedPreferences.setMockInitialValues(saved);
    progress.resetForTest();
    DuckPet.instance.resetForTest();
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
      await progress.completeLesson();
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
      // 1 Oktober 2026 hari Kamis, Senin-nya 28 September
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

      await progress.completeLesson();
      expect(progress.streak, 5);
      expect(progress.bestStreak, 5);
      expect(progress.studiedToday, isTrue);

      // Lesson kedua di hari yang sama tidak menambah streak
      await progress.completeLesson();
      expect(progress.streak, 5);
    });

    test('streak putus kalau bolos lebih dari sehari', () async {
      await start({'lastStudyDay': '2000-01-01', 'streak': 9, 'bestStreak': 9});

      expect(progress.streak, 0);
      await progress.completeLesson();
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

    test('hadiah XP Boost dari roda mengaktifkan boost', () async {
      await start();
      await progress.claimSpin(indexOf(PrizeType.xpBoost, 15));
      expect(progress.isXpBoostActive, isTrue);
      expect(progress.xpBoostLeft.inMinutes, greaterThanOrEqualTo(14));
    });
  });
}

// Random palsu yang selalu mengembalikan angka yang sama, supaya hasil
// undian bisa diuji.
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
