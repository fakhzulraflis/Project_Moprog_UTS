import 'package:flutter_test/flutter_test.dart';
import 'package:moprog_uts/services/auth_session.dart';
import 'package:moprog_uts/services/duck_pet.dart';
import 'package:moprog_uts/services/inventory_service.dart';
import 'package:moprog_uts/services/player_progress.dart';
import 'package:moprog_uts/services/progress_sync.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_inventory_api.dart';

// Database palsu: progres disimpan per user, sama seperti tabel
// user_progress di backend.
class FakeProgressApi implements ProgressApi {
  final Map<int, Map<String, dynamic>> byUser = {};
  bool failing = false;
  int saveCount = 0;

  int get currentUser => AuthSession.instance.userId!;

  @override
  Future<Map<String, dynamic>?> fetch() async {
    if (failing) throw Exception('server mati');
    final data = byUser[currentUser];
    return data == null ? null : Map<String, dynamic>.from(data);
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
}
