import 'package:flutter_test/flutter_test.dart';
import 'package:moprog_uts/services/auth_session.dart';
import 'package:moprog_uts/services/duck_pet.dart';
import 'package:moprog_uts/services/inventory_service.dart';
import 'package:moprog_uts/services/mistake_service.dart';
import 'package:moprog_uts/services/player_progress.dart';
import 'package:moprog_uts/services/progress_sync.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_inventory_api.dart';

// Database palsu: progres disimpan per user, sama seperti tabel
// user_progress di backend.
class FakeProgressApi implements ProgressApi {
  final Map<int, Map<String, dynamic>> byUser = {};

  // XP akun di server (users.xp), bisa lebih besar dari isi progres
  final Map<int, int> xpByUser = {};
  bool failing = false;
  int saveCount = 0;

  int get currentUser => AuthSession.instance.userId!;

  @override
  Future<RemoteProgress> fetch() async {
    if (failing) throw Exception('server mati');
    final data = byUser[currentUser];
    return RemoteProgress(
      progress: data == null ? null : Map<String, dynamic>.from(data),
      xp: xpByUser[currentUser] ?? 0,
    );
  }

  @override
  Future<void> save(Map<String, dynamic> progress) async {
    if (failing) throw Exception('server mati');
    saveCount++;
    byUser[currentUser] = Map<String, dynamic>.from(progress);
  }
}

void main() {
  final sync = ProgressSync.instance;
  final progress = PlayerProgress.instance;
  final pet = DuckPet.instance;
  late FakeProgressApi server;

  Future<void> start([Map<String, Object> saved = const {}]) async {
    SharedPreferences.setMockInitialValues(saved);
    server = FakeProgressApi();
    sync.resetForTest(server);
    progress.resetForTest();
    pet.resetForTest();
    InventoryService.instance.resetForTest(FakeInventoryApi());
  }

  // Login sebagai user tertentu, seperti setelah halaman Login berhasil.
  Future<void> loginAs(int userId) async {
    AuthSession.instance.setForTest(token: 'token-$userId', userId: userId);
    await sync.onLogin();
  }

  test('user baru: progres awal langsung dibuat di server', () async {
    await start();
    await loginAs(1);

    expect(sync.ready, isTrue);
    expect(server.byUser[1], isNotNull);
    expect(server.byUser[1]!['gems'], 50);
    expect(progress.gems, 50);
  });

  test('user lama: progres dari server dipasang di HP', () async {
    await start();
    server.byUser[1] = {
      'gems': 777,
      'totalXp': 1200,
      'streakGoal': 14,
      'pet_name': 'Bebeku',
      // JSON bisa mengirim 80 (bukan 80.0) untuk nilai desimal
      'pet_fullness': 80,
      'pet_owned': ['crown'],
      'pet_equipped': ['crown'],
    };

    await loginAs(1);

    expect(progress.gems, 777);
    expect(progress.totalXp, 1200);
    expect(progress.streakGoal, 14);
    expect(pet.name, 'Bebeku');
    expect(pet.storedFullness, 80.0);
    expect(pet.equipped.map((a) => a.name), ['crown']);
  });

  test('perubahan dikirim ke server', () async {
    await start();
    await loginAs(1);

    await progress.spendGems(20);
    await pet.rename('Kwek');
    await sync.flush();

    expect(server.byUser[1]!['gems'], 30);
    expect(server.byUser[1]!['pet_name'], 'Kwek');
  });

  test('ganti akun di HP yang sama: progres tidak tertukar', () async {
    await start();

    // User 1 bermain lalu logout
    await loginAs(1);
    await progress.spendGems(40);
    await sync.onLogout();
    expect(server.byUser[1]!['gems'], 10);

    // User 2 login di HP yang sama: mulai dari awal, bukan memakai
    // progres user 1
    await loginAs(2);
    expect(progress.gems, 50);
    await progress.buyBonusHearts(25, 2);
    await sync.onLogout();
    expect(server.byUser[2]!['gems'], 25);

    // User 1 login lagi: progresnya kembali
    await loginAs(1);
    expect(progress.gems, 10);
    expect(progress.bonusHearts, 0);
  });

  test('progres lama di HP diunggah saat pertama kali login', () async {
    // HP sudah dipakai sebelum fitur ini ada (belum ada pemiliknya)
    await start({'gems': 400, 'totalXp': 900});
    await loginAs(1);

    expect(progress.gems, 400);
    expect(server.byUser[1]!['gems'], 400);
    expect(server.byUser[1]!['totalXp'], 900);
  });

  test(
    'server mati: progres user lain tidak terlihat dan tidak dikirim',
    () async {
      await start();
      await loginAs(1);
      await progress.spendGems(40);
      await sync.onLogout();

      server.failing = true;
      await loginAs(2);

      // User 2 tidak boleh melihat gem milik user 1
      expect(progress.gems, 50);
      expect(sync.ready, isFalse);

      // Selama belum berhasil mengambil data, tidak ada yang dikirim
      server.failing = false;
      final before = server.saveCount;
      await progress.spendGems(5);
      await sync.flush();
      expect(server.saveCount, before);
      expect(server.byUser[2], isNull);
    },
  );

  test('belum login: tidak ada yang dikirim', () async {
    await start();
    AuthSession.instance.setForTest(token: null);

    await progress.spendGems(10);
    await sync.flush();
    expect(server.saveCount, 0);
  });

  test(
    'lesson yang sudah selesai tersimpan di akun dan kembali saat login',
    () async {
      await start();
      await loginAs(1);

      await progress.completeLesson(5);
      await progress.completeLesson(6);
      await sync.flush();

      expect(server.byUser[1]!['completedLessonIds'], containsAll(['5', '6']));
      expect(server.byUser[1]!['totalXp'], 20);

      // Ganti akun lalu kembali: progres belajar user 1 masih ada
      await sync.onLogout();
      await loginAs(2);
      expect(progress.isLessonCompleted(5), isFalse);
      await sync.onLogout();

      await loginAs(1);
      expect(progress.isLessonCompleted(5), isTrue);
      expect(progress.isLessonCompleted(6), isTrue);
      expect(progress.totalXp, 20);
    },
  );

  test(
    'peti yang sudah dibuka tidak bisa dibuka lagi setelah login ulang',
    () async {
      await start();
      await loginAs(1);

      expect(await progress.markChestOpened(7), isTrue);
      expect(await progress.markChestOpened(7), isFalse);
      await sync.onLogout();

      await loginAs(1);
      expect(progress.isChestOpened(7), isTrue);
      expect(await progress.markChestOpened(7), isFalse);

      // User lain punya peti sendiri
      await sync.onLogout();
      await loginAs(2);
      expect(progress.isChestOpened(7), isFalse);
    },
  );

  test('XP bertambah dari XP akun di server, bukan dari 0', () async {
    await start();
    server.xpByUser[1] = 300;

    await loginAs(1);
    expect(progress.totalXp, 300);

    await progress.completeLesson(1);
    await sync.flush();

    expect(progress.totalXp, 310);
    expect(server.byUser[1]!['totalXp'], 310);
  });

  test('XP tidak lebih kecil dari XP lesson yang sudah selesai', () async {
    // Data lama: 12 lesson selesai tetapi XP belum pernah dicatat
    await start({'completedLessonIds': List.generate(12, (i) => '${i + 1}')});
    await loginAs(1);

    expect(progress.totalXp, 120);
    expect(server.byUser[1]!['totalXp'], 120);

    await progress.completeLesson(13);
    expect(progress.totalXp, 130);
  });

  test(
    'main saat offline: progres tidak tertimpa data lama di server',
    () async {
      await start();
      await loginAs(1);
      await progress.completeLesson(1);
      await sync.flush();

      // Server mati: lesson berikutnya hanya tersimpan di HP
      server.failing = true;
      await progress.completeLesson(2);
      await progress.completeLesson(3);
      expect(server.byUser[1]!['completedLessonIds'], ['1']);

      // Server hidup lagi dan user login: lesson 2 dan 3 tidak hilang
      server.failing = false;
      await loginAs(1);

      expect(progress.isLessonCompleted(2), isTrue);
      expect(progress.isLessonCompleted(3), isTrue);
      expect(progress.totalXp, 30);
      expect(
        server.byUser[1]!['completedLessonIds'],
        containsAll(['1', '2', '3']),
      );
    },
  );

  test('kosakata yang salah dikirim ke akun dan terpisah antar user', () async {
    await start();
    await loginAs(1);

    await MistakeService.addMistake(9);
    await MistakeService.addMistake(12);
    await sync.flush();
    expect(
      server.byUser[1]!['practice_mistake_vocabulary_ids'],
      containsAll(['9', '12']),
    );

    await sync.onLogout();
    await loginAs(2);
    expect(await MistakeService.getMistakeIds(), isEmpty);
    await sync.onLogout();

    await loginAs(1);
    expect(await MistakeService.getMistakeIds(), {9, 12});
  });

  test('penggabungan: kunci yang hanya bertambah tidak bisa berkurang', () {
    final merged = ProgressSync.mergeProgress(
      local: {
        'gems': 20,
        'totalXp': 50,
        'completedLessonIds': ['1', '4'],
      },
      remote: {
        'gems': 90,
        'totalXp': 80,
        'bestStreak': 6,
        'completedLessonIds': ['1', '2', '3'],
      },
    );

    expect(merged['gems'], 20); // nilai HP lebih baru
    expect(merged['totalXp'], 80); // XP tidak turun
    expect(merged['bestStreak'], 6);
    expect((merged['completedLessonIds'] as List).toSet(), {
      '1',
      '2',
      '3',
      '4',
    });
  });
}
