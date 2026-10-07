import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'api_service.dart';
import 'auth_session.dart';

// Efek yang bisa diaktifkan dari inventory.
enum ItemEffect { xpBoost, unlimitedHearts }

// Data tampilan satu jenis barang. Kuncinya sama dengan katalog di backend
// (InventoryItem::CATALOG).
class ItemInfo {
  final String key;
  final String name;
  final String description;
  final ItemEffect effect;
  final int minutes;
  final String image;
  final Color color;

  const ItemInfo({
    required this.key,
    required this.name,
    required this.description,
    required this.effect,
    required this.minutes,
    required this.image,
    required this.color,
  });

  static const Color xpColor = Color(0xFF7B61FF);
  static const Color heartColor = Color(0xFFFF4B4B);

  static const List<ItemInfo> all = [
    ItemInfo(
      key: 'xp_boost_15',
      name: 'XP Ganda 15 Menit',
      description: 'XP dari lesson jadi 2x lipat selama 15 menit.',
      effect: ItemEffect.xpBoost,
      minutes: 15,
      image: 'assets/icons/xp.png',
      color: xpColor,
    ),
    ItemInfo(
      key: 'xp_boost_30',
      name: 'XP Ganda 30 Menit',
      description: 'XP dari lesson jadi 2x lipat selama 30 menit.',
      effect: ItemEffect.xpBoost,
      minutes: 30,
      image: 'assets/icons/xp.png',
      color: xpColor,
    ),
    ItemInfo(
      key: 'xp_boost_60',
      name: 'XP Ganda 1 Jam',
      description: 'XP dari lesson jadi 2x lipat selama 1 jam.',
      effect: ItemEffect.xpBoost,
      minutes: 60,
      image: 'assets/icons/xp.png',
      color: xpColor,
    ),
    ItemInfo(
      key: 'unlimited_hearts_30',
      name: 'Hati Tak Terbatas 30 Menit',
      description:
          'Hati tidak berkurang waktu salah menjawab di lesson '
          'selama 30 menit.',
      effect: ItemEffect.unlimitedHearts,
      minutes: 30,
      image: 'assets/icons/hearts.png',
      color: heartColor,
    ),
    ItemInfo(
      key: 'unlimited_hearts_60',
      name: 'Hati Tak Terbatas 1 Jam',
      description:
          'Hati tidak berkurang waktu salah menjawab di lesson '
          'selama 1 jam.',
      effect: ItemEffect.unlimitedHearts,
      minutes: 60,
      image: 'assets/icons/hearts.png',
      color: heartColor,
    ),
  ];

  static ItemInfo? of(String key) {
    for (final item in all) {
      if (item.key == key) return item;
    }
    return null;
  }

  // Label durasi singkat untuk kotak di inventory, misalnya "15m" / "1j".
  String get shortDuration =>
      minutes % 60 == 0 ? '${minutes ~/ 60}j' : '${minutes}m';

  static String effectName(ItemEffect effect) {
    switch (effect) {
      case ItemEffect.xpBoost:
        return 'XP Ganda';
      case ItemEffect.unlimitedHearts:
        return 'Hati Tak Terbatas';
    }
  }
}

// Satu barang milik user, sesuai data dari backend.
class OwnedItem {
  final int id;
  final String key;
  final String status;
  final DateTime? activatedAt;
  final DateTime? expiresAt;

  const OwnedItem({
    required this.id,
    required this.key,
    required this.status,
    this.activatedAt,
    this.expiresAt,
  });

  ItemInfo? get info => ItemInfo.of(key);

  factory OwnedItem.fromJson(Map<String, dynamic> json) {
    DateTime? time(String field) {
      final value = json[field];
      return value == null ? null : DateTime.parse(value as String);
    }

    return OwnedItem(
      id: (json['id'] as num).toInt(),
      key: json['item_key'] as String,
      status: json['status'] as String,
      activatedAt: time('activated_at'),
      expiresAt: time('expires_at'),
    );
  }
}

class InventorySnapshot {
  final List<OwnedItem> items;
  final List<OwnedItem> active;
  final DateTime? serverTime;

  const InventorySnapshot({
    required this.items,
    required this.active,
    this.serverTime,
  });

  factory InventorySnapshot.fromJson(Map<String, dynamic> json) {
    List<OwnedItem> list(String field) => (json[field] as List? ?? [])
        .map((e) => OwnedItem.fromJson(e as Map<String, dynamic>))
        .where((item) => item.info != null)
        .toList();

    final server = json['server_time'];
    return InventorySnapshot(
      items: list('items'),
      active: list('active'),
      serverTime: server == null ? null : DateTime.parse(server as String),
    );
  }
}

class InventoryException implements Exception {
  final String message;
  const InventoryException(this.message);

  @override
  String toString() => message;
}

// Pesan error yang ramah untuk ditampilkan ke user.
String friendlyError(Object error) => error is InventoryException
    ? error.message
    : 'Server tidak bisa dihubungi. Pastikan backend menyala.';

// Penghubung ke backend. Dibuat sebagai abstract class supaya waktu
// testing bisa diganti dengan versi palsu tanpa server.
abstract class InventoryApi {
  Future<InventorySnapshot> fetch();
  Future<OwnedItem> add(String key, String source);
  Future<InventorySnapshot> use(int id);
}

class HttpInventoryApi implements InventoryApi {
  Map<String, String> get headers {
    final token = AuthSession.instance.token;
    if (token == null) {
      throw const InventoryException(
        'Masuk ke akunmu dulu untuk memakai inventori.',
      );
    }
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> decode(http.Response response) {
    final Object? body;
    try {
      body = jsonDecode(response.body);
    } on FormatException {
      throw const InventoryException('Gagal menghubungi server.');
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body! as Map<String, dynamic>;
    }
    if (response.statusCode == 401) {
      throw const InventoryException('Sesi login habis. Silakan masuk lagi.');
    }
    final message = body is Map ? body['message'] as String? : null;
    throw InventoryException(message ?? 'Gagal menghubungi server.');
  }

  @override
  Future<InventorySnapshot> fetch() async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/inventory'),
      headers: headers,
    );
    return InventorySnapshot.fromJson(decode(response)['data']);
  }

  @override
  Future<OwnedItem> add(String key, String source) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/inventory'),
      headers: headers,
      body: jsonEncode({'item_key': key, 'source': source}),
    );
    return OwnedItem.fromJson(decode(response)['data']);
  }

  @override
  Future<InventorySnapshot> use(int id) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/inventory/$id/use'),
      headers: headers,
    );
    return InventorySnapshot.fromJson(decode(response)['data']);
  }
}

// Inventory milik user yang sedang login. Datanya disimpan di database
// backend, jadi tiap user punya barangnya sendiri.
class InventoryService extends ChangeNotifier {
  InventoryService._();

  static final InventoryService instance = InventoryService._();

  @visibleForTesting
  InventoryApi api = HttpInventoryApi();

  List<OwnedItem> items = [];
  List<OwnedItem> active = [];
  bool isLoading = false;
  bool isLoaded = false;
  String? error;

  // Selisih jam server dan jam HP, supaya sisa waktu efek tetap benar
  // walaupun jam HP tidak sama persis dengan server.
  Duration clockOffset = Duration.zero;

  DateTime get now => DateTime.now().add(clockOffset);

  Future<void> load() async {
    if (isLoading) return;
    isLoading = true;
    notifyListeners();
    try {
      await AuthSession.instance.load();
      applySnapshot(await api.fetch());
      error = null;
      isLoaded = true;
    } catch (e) {
      error = friendlyError(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Dipanggil setelah login: buang data user lama, lalu muat ulang.
  Future<void> reload() {
    items = [];
    active = [];
    isLoaded = false;
    error = null;
    return load();
  }

  void applySnapshot(InventorySnapshot snapshot) {
    items = snapshot.items;
    active = snapshot.active;
    if (snapshot.serverTime != null) {
      clockOffset = snapshot.serverTime!.difference(DateTime.now());
    }
  }

  // Simpan barang baru ke inventory. Mengembalikan false kalau gagal
  // (belum login atau server tidak bisa dihubungi).
  Future<bool> add(String key, {required String source}) async {
    try {
      await AuthSession.instance.load();
      final item = await api.add(key, source);
      items = [...items, item];
      error = null;
      notifyListeners();
      return true;
    } catch (e) {
      error = friendlyError(e);
      notifyListeners();
      return false;
    }
  }

  // Pakai barang. Mengembalikan pesan error, atau null kalau berhasil.
  Future<String?> use(OwnedItem item) async {
    try {
      applySnapshot(await api.use(item.id));
      notifyListeners();
      return null;
    } catch (e) {
      return friendlyError(e);
    }
  }

  bool isActive(ItemEffect effect) {
    final until = activeUntil(effect);
    return until != null && until.isAfter(now);
  }

  // Kapan efek ini berakhir (yang paling lama), atau null kalau tidak aktif.
  DateTime? activeUntil(ItemEffect effect) {
    DateTime? latest;
    for (final item in active) {
      final end = item.expiresAt;
      if (item.info?.effect != effect || end == null || !end.isAfter(now)) {
        continue;
      }
      if (latest == null || end.isAfter(latest)) latest = end;
    }
    return latest;
  }

  Duration timeLeft(ItemEffect effect) {
    final until = activeUntil(effect);
    return until == null ? Duration.zero : until.difference(now);
  }

  int get unusedCount => items.length;

  // Barang belum dipakai, dikelompokkan per jenis (untuk angka jumlah di
  // kotak inventory). Urutannya mengikuti katalog.
  List<MapEntry<ItemInfo, List<OwnedItem>>> get grouped {
    final result = <MapEntry<ItemInfo, List<OwnedItem>>>[];
    for (final info in ItemInfo.all) {
      final owned = items.where((i) => i.key == info.key).toList();
      if (owned.isNotEmpty) result.add(MapEntry(info, owned));
    }
    return result;
  }

  @visibleForTesting
  void resetForTest(InventoryApi fakeApi) {
    api = fakeApi;
    items = [];
    active = [];
    isLoaded = false;
    isLoading = false;
    error = null;
    clockOffset = Duration.zero;
  }
}
