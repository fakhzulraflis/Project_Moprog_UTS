import 'package:moprog_uts/services/inventory_service.dart';

// Server inventory palsu untuk test, supaya test tidak butuh backend
// menyala. Aturannya meniru InventoryController di backend.
class FakeInventoryApi implements InventoryApi {
  final List<OwnedItem> stored = [];
  int nextId = 1;

  // Kalau true, semua permintaan gagal seperti server mati.
  bool failing = false;

  DateTime Function() clock = DateTime.now;

  void check() {
    if (failing) throw const InventoryException('Server mati.');
  }

  InventorySnapshot snapshot() {
    final now = clock();
    return InventorySnapshot(
      items: stored.where((i) => i.status == 'unused').toList(),
      active: stored
          .where((i) => i.status == 'active' && i.expiresAt!.isAfter(now))
          .toList(),
      serverTime: now,
    );
  }

  @override
  Future<InventorySnapshot> fetch() async {
    check();
    return snapshot();
  }

  @override
  Future<OwnedItem> add(String key, String source) async {
    check();
    if (ItemInfo.of(key) == null) {
      throw const InventoryException('Barang tidak dikenal.');
    }
    final item = OwnedItem(id: nextId++, key: key, status: 'unused');
    stored.add(item);
    return item;
  }

  @override
  Future<InventorySnapshot> use(int id) async {
    check();
    final index = stored.indexWhere((i) => i.id == id);
    if (index < 0) throw const InventoryException('Barang tidak ditemukan.');
    final item = stored[index];
    if (item.status != 'unused') {
      throw const InventoryException('Barang ini sudah dipakai.');
    }

    // Efek yang sama disambung dari akhir efek yang masih aktif
    final now = clock();
    var start = now;
    for (final other in stored) {
      if (other.status == 'active' &&
          other.info!.effect == item.info!.effect &&
          other.expiresAt!.isAfter(start)) {
        start = other.expiresAt!;
      }
    }

    stored[index] = OwnedItem(
      id: item.id,
      key: item.key,
      status: 'active',
      activatedAt: now,
      expiresAt: start.add(Duration(minutes: item.info!.minutes)),
    );
    return snapshot();
  }
}
