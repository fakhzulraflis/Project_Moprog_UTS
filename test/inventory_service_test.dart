import 'package:flutter_test/flutter_test.dart';
import 'package:moprog_uts/services/auth_session.dart';
import 'package:moprog_uts/services/inventory_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_inventory_api.dart';

void main() {
  final inventory = InventoryService.instance;
  late FakeInventoryApi server;
  late DateTime now;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    now = DateTime(2026, 10, 8, 10);
    server = FakeInventoryApi()..clock = () => now;
    inventory.resetForTest(server);
    AuthSession.instance.setForTest(token: 'token-test', userId: 1);
  });

  test('katalog sama dengan backend', () {
    expect(ItemInfo.all.map((i) => i.key), [
      'xp_boost_15',
      'xp_boost_30',
      'xp_boost_60',
      'unlimited_hearts_30',
      'unlimited_hearts_60',
    ]);
    expect(ItemInfo.of('xp_boost_60')!.shortDuration, '1j');
    expect(ItemInfo.of('xp_boost_15')!.shortDuration, '15m');
  });

  test('barang sejenis dikelompokkan dengan jumlahnya', () async {
    await inventory.add('xp_boost_15', source: 'shop');
    await inventory.add('xp_boost_15', source: 'spin');
    await inventory.add('unlimited_hearts_30', source: 'chest');

    final groups = inventory.grouped;
    expect(groups.length, 2);
    expect(groups.first.key.key, 'xp_boost_15');
    expect(groups.first.value.length, 2);
    expect(inventory.unusedCount, 3);
  });

  test('barang baru berefek setelah dipakai', () async {
    await inventory.add('unlimited_hearts_30', source: 'shop');
    await inventory.load();
    expect(inventory.isActive(ItemEffect.unlimitedHearts), isFalse);

    expect(await inventory.use(inventory.items.first), isNull);
    expect(inventory.unusedCount, 0);
    expect(inventory.isActive(ItemEffect.unlimitedHearts), isTrue);
    expect(inventory.isActive(ItemEffect.xpBoost), isFalse);
  });

  test('efek yang sama disambung, bukan diganti', () async {
    await inventory.add('xp_boost_15', source: 'shop');
    await inventory.add('xp_boost_30', source: 'shop');
    await inventory.load();

    await inventory.use(inventory.items.first);
    await inventory.use(inventory.items.first);

    expect(
      inventory.activeUntil(ItemEffect.xpBoost)!.difference(now),
      const Duration(minutes: 45),
    );
  });

  test('efek berhenti setelah waktunya habis', () async {
    await inventory.add('xp_boost_15', source: 'shop');
    await inventory.load();
    await inventory.use(inventory.items.first);

    // Jam HP dibuat sama dengan jam server palsu
    inventory.clockOffset = now.difference(DateTime.now());
    expect(inventory.isActive(ItemEffect.xpBoost), isTrue);

    inventory.clockOffset = now
        .add(const Duration(minutes: 16))
        .difference(DateTime.now());
    expect(inventory.isActive(ItemEffect.xpBoost), isFalse);
    expect(inventory.timeLeft(ItemEffect.xpBoost), Duration.zero);
  });

  test('barang yang sudah dipakai tidak bisa dipakai lagi', () async {
    await inventory.add('xp_boost_15', source: 'shop');
    await inventory.load();
    final item = inventory.items.first;

    expect(await inventory.use(item), isNull);
    expect(await inventory.use(item), 'Barang ini sudah dipakai.');
  });

  test('server mati: add gagal dan pesan error ramah', () async {
    server.failing = true;
    expect(await inventory.add('xp_boost_15', source: 'shop'), isFalse);
    expect(inventory.error, 'Server mati.');

    await inventory.load();
    expect(inventory.isLoaded, isFalse);
  });

  test('belum login: API asli menolak tanpa menghubungi server', () async {
    AuthSession.instance.setForTest(token: null);
    inventory.resetForTest(HttpInventoryApi());

    expect(await inventory.add('xp_boost_15', source: 'shop'), isFalse);
    expect(inventory.error, contains('Masuk ke akunmu dulu'));
  });

  test('ganti akun: inventory user lama dibuang', () async {
    await inventory.add('xp_boost_15', source: 'shop');
    expect(inventory.unusedCount, 1);

    server.stored.clear();
    await inventory.reload();
    expect(inventory.unusedCount, 0);
  });
}
