import 'dart:math';

import 'package:flutter/material.dart';

import '../widgets/reward_chest.dart';
import 'player_progress.dart';

// Satu jenis quest harian. Progress-nya dihitung dari data di
// PlayerProgress, jadi quest otomatis bergerak waktu pemain beraktivitas.
class DailyQuest {
  final String id;
  final String title;
  final int target;
  final ChestTier tier;
  final int Function(PlayerProgress p) progressOf;

  // Quest belajar (lesson, XP, jawaban) atau quest santai (Quacko, roda,
  // toko). Tiap hari selalu ada 2 quest belajar dan 1 quest santai.
  final bool learning;

  // Quest dengan grup yang sama tidak muncul bersamaan di hari yang sama,
  // misalnya "Kumpulkan 50 XP" dan "Kumpulkan 100 XP".
  final String group;

  // Ikon berupa gambar dari assets, atau ikon bawaan Flutter.
  final String? image;
  final IconData? iconData;
  final Color iconColor;

  const DailyQuest({
    required this.id,
    required this.title,
    required this.target,
    required this.tier,
    required this.progressOf,
    required this.learning,
    required this.group,
    this.image,
    this.iconData,
    this.iconColor = Colors.white,
  });
}

// Kumpulan semua quest harian yang mungkin muncul.
class QuestPool {
  static const int questsPerDay = 3;
  static const int learningPerDay = 2;

  static final List<DailyQuest> all = [
    // ---------- Quest belajar ----------
    DailyQuest(
      id: 'earn_xp',
      title: 'Kumpulkan 50 XP',
      image: 'assets/icons/xp.png',
      target: 50,
      tier: ChestTier.bronze,
      learning: true,
      group: 'xp',
      progressOf: (p) => p.xpToday,
    ),
    DailyQuest(
      id: 'earn_xp_big',
      title: 'Kumpulkan 100 XP',
      image: 'assets/icons/xp.png',
      target: 100,
      tier: ChestTier.silver,
      learning: true,
      group: 'xp',
      progressOf: (p) => p.xpToday,
    ),
    DailyQuest(
      id: 'complete_lesson',
      title: 'Selesaikan 1 lesson',
      image: 'assets/icons/guidebook.png',
      target: 1,
      tier: ChestTier.bronze,
      learning: true,
      group: 'lesson',
      progressOf: (p) => p.lessonsToday,
    ),
    DailyQuest(
      id: 'complete_lessons',
      title: 'Selesaikan 3 lesson',
      image: 'assets/icons/guidebook.png',
      target: 3,
      tier: ChestTier.silver,
      learning: true,
      group: 'lesson',
      progressOf: (p) => p.lessonsToday,
    ),
    DailyQuest(
      id: 'correct_answers',
      title: 'Jawab 15 soal dengan benar',
      image: 'assets/icons/dumbell.png',
      target: 15,
      tier: ChestTier.bronze,
      learning: true,
      group: 'correct',
      progressOf: (p) => p.correctToday,
    ),
    DailyQuest(
      id: 'correct_answers_big',
      title: 'Jawab 30 soal dengan benar',
      image: 'assets/icons/dumbell.png',
      target: 30,
      tier: ChestTier.silver,
      learning: true,
      group: 'correct',
      progressOf: (p) => p.correctToday,
    ),

    // ---------- Quest santai ----------
    DailyQuest(
      id: 'pet_duck',
      title: 'Elus Quacko 3 kali',
      iconData: Icons.pan_tool_alt,
      iconColor: Color(0xFFFF6B9A),
      target: 3,
      tier: ChestTier.bronze,
      learning: false,
      group: 'pet',
      progressOf: (p) => p.petsToday,
    ),
    DailyQuest(
      id: 'feed_duck',
      title: 'Beri makan Quacko',
      iconData: Icons.bakery_dining,
      iconColor: Color(0xFFFF9A1F),
      target: 1,
      tier: ChestTier.bronze,
      learning: false,
      group: 'feed',
      progressOf: (p) => p.feedsToday,
    ),
    DailyQuest(
      id: 'daily_spin',
      title: 'Putar Roda Harian',
      iconData: Icons.casino,
      iconColor: Color(0xFF7B61FF),
      target: 1,
      tier: ChestTier.bronze,
      learning: false,
      group: 'spin',
      progressOf: (p) => p.spunToday ? 1 : 0,
    ),
    DailyQuest(
      id: 'shop_purchase',
      title: 'Beli 1 barang di Toko',
      iconData: Icons.storefront,
      iconColor: Color(0xFF1CB0F6),
      target: 1,
      tier: ChestTier.bronze,
      learning: false,
      group: 'shop',
      progressOf: (p) => p.purchasesToday,
    ),
  ];

  static DailyQuest? byId(String id) {
    for (final quest in all) {
      if (quest.id == id) return quest;
    }
    return null;
  }

  // Pilih quest untuk satu hari. Angka acaknya memakai tanggal sebagai
  // "seed", jadi di hari yang sama hasilnya selalu sama (tidak berubah
  // walaupun aplikasi dibuka-tutup), tapi besoknya berbeda.
  static List<String> pickForDay(String dayKey) {
    final seed = int.parse(dayKey.replaceAll('-', ''));
    final rng = Random(seed);

    final learning = all.where((q) => q.learning).toList()..shuffle(rng);
    final fun = all.where((q) => !q.learning).toList()..shuffle(rng);

    final picked = <DailyQuest>[];
    for (final quest in learning) {
      if (picked.length == learningPerDay) break;
      if (picked.every((p) => p.group != quest.group)) picked.add(quest);
    }
    picked.add(fun.first);

    return picked.map((q) => q.id).toList();
  }

  // Cari pengganti untuk sebuah quest: jenisnya sama (belajar/santai),
  // grupnya belum dipakai quest lain hari ini. Quest yang ternyata sudah
  // selesai ([isDone]) tidak dipilih, supaya ganti quest tidak bisa dipakai
  // untuk langsung dapat peti.
  static DailyQuest? replacementFor(
    DailyQuest old,
    List<DailyQuest> today, {
    bool Function(DailyQuest quest)? isDone,
    Random? random,
  }) {
    final usedGroups = today
        .where((q) => q.id != old.id)
        .map((q) => q.group)
        .toSet();
    final candidates = all
        .where(
          (q) =>
              q.learning == old.learning &&
              q.group != old.group &&
              !usedGroups.contains(q.group) &&
              !(isDone?.call(q) ?? false),
        )
        .toList();
    if (candidates.isEmpty) return null;
    return candidates[(random ?? Random()).nextInt(candidates.length)];
  }
}
