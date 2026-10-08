import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';
import 'auth_session.dart';
import 'duck_pet.dart';
import 'player_progress.dart';

// Tipe data tiap kunci yang disimpan di HP.
enum StoreType { intValue, doubleValue, boolValue, stringValue, stringList }

// Penghubung ke backend. Dibuat abstract supaya waktu testing bisa diganti
// versi palsu tanpa server.
abstract class ProgressApi {
  // null artinya user ini belum pernah menyimpan progres di server
  Future<Map<String, dynamic>?> fetch();
  Future<void> save(Map<String, dynamic> progress);
}

class HttpProgressApi implements ProgressApi {
  // Supaya login tidak menunggu terlalu lama kalau server lambat
  static const Duration timeout = Duration(seconds: 8);

  Map<String, String> get headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${AuthSession.instance.token}',
  };

  @override
  Future<Map<String, dynamic>?> fetch() async {
    final response = await http
        .get(Uri.parse('${ApiService.baseUrl}/progress'), headers: headers)
        .timeout(timeout);
    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil progres: ${response.statusCode}');
    }
    final data = jsonDecode(response.body)['data'] as Map<String, dynamic>;
    return data['progress'] as Map<String, dynamic>?;
  }

  @override
  Future<void> save(Map<String, dynamic> progress) async {
    final response = await http
        .put(
          Uri.parse('${ApiService.baseUrl}/progress'),
          headers: headers,
          body: jsonEncode({'progress': progress}),
        )
        .timeout(timeout);
    if (response.statusCode != 200) {
      throw Exception('Gagal menyimpan progres: ${response.statusCode}');
    }
  }
}

// Menyambungkan progres halaman Misi ke database, supaya tiap user punya
// gem, XP, misi, streak, roda harian, dan Quacko masing-masing.
//
// Cara kerjanya:
// - Saat login: progres user diambil dari server lalu dipasang di HP.
// - Saat bermain: setiap perubahan dikirim ke server (ditunda 2 detik
//   supaya tidak mengirim terus-menerus).
// - Saat logout: perubahan terakhir dikirim dulu.
//
// Data tetap disimpan juga di HP (shared_preferences) sebagai cache, jadi
// aplikasi tetap bisa dipakai walaupun server sedang tidak bisa dihubungi.
class ProgressSync {
  ProgressSync._();

  static final ProgressSync instance = ProgressSync._();

  @visibleForTesting
  ProgressApi api = HttpProgressApi();

  static const Duration pushDelay = Duration(seconds: 2);

  // Menandai milik siapa progres yang sedang tersimpan di HP ini.
  static const String ownerKey = 'progress_owner';

  // Semua kunci progres beserta tipenya (dari PlayerProgress dan DuckPet).
  static const Map<String, StoreType> keys = {
    // PlayerProgress
    'gems': StoreType.intValue,
    'totalXp': StoreType.intValue,
    'bonusHearts': StoreType.intValue,
    'xpBoostUntil': StoreType.intValue,
    'day': StoreType.stringValue,
    'xpToday': StoreType.intValue,
    'lessonsToday': StoreType.intValue,
    'correctToday': StoreType.intValue,
    'petsToday': StoreType.intValue,
    'feedsToday': StoreType.intValue,
    'purchasesToday': StoreType.intValue,
    'completedToday': StoreType.stringList,
    'claimedToday': StoreType.stringList,
    'todayQuests': StoreType.stringList,
    'rerolledToday': StoreType.boolValue,
    'week': StoreType.stringValue,
    'lessonsThisWeek': StoreType.intValue,
    'weeklyClaimed': StoreType.boolValue,
    'month': StoreType.stringValue,
    'questsThisMonth': StoreType.intValue,
    'monthlyClaimed': StoreType.boolValue,
    'studiedDays': StoreType.stringList,
    'claimedStreakMilestones': StoreType.stringList,
    'streak': StoreType.intValue,
    'bestStreak': StoreType.intValue,
    'lastStudyDay': StoreType.stringValue,
    'streakGoal': StoreType.intValue,
    'lastSpinDay': StoreType.stringValue,
    'lastSpinPrize': StoreType.intValue,
    // DuckPet
    'pet_name': StoreType.stringValue,
    'pet_fullness': StoreType.doubleValue,
    'pet_happiness': StoreType.doubleValue,
    'pet_lastTick': StoreType.intValue,
    'pet_adoptedAt': StoreType.intValue,
    'pet_lastPetAt': StoreType.intValue,
    'pet_owned': StoreType.stringList,
    'pet_equipped': StoreType.stringList,
    'pet_xp': StoreType.intValue,
    'pet_pendingLevelUp': StoreType.intValue,
  };

  // true setelah progres user yang login berhasil diambil dari server.
  // Selama false, tidak ada yang dikirim ke server, supaya data di server
  // tidak tertimpa progres kosong atau progres milik user lain.
  bool ready = false;

  Timer? pending;

  // ---------- Login & logout ----------

  Future<void> onLogin() async {
    ready = false;
    pending?.cancel();
    pending = null;

    final userId = AuthSession.instance.userId;
    if (userId == null) return;

    final prefs = await SharedPreferences.getInstance();
    final owner = prefs.getInt(ownerKey);

    Map<String, dynamic>? remote;
    try {
      remote = await api.fetch();
    } catch (_) {
      // Server tidak bisa dihubungi. Kalau progres di HP milik user lain,
      // dikosongkan supaya tidak terlihat oleh user ini. Tidak dikirim ke
      // server sampai login berikutnya berhasil mengambil data.
      if (owner != null && owner != userId) await resetLocal(userId);
      await reloadAll();
      return;
    }

    if (remote != null) {
      // User ini sudah punya progres di server: pasang di HP
      await restore(remote, userId);
      ready = true;
      await reloadAll();
      return;
    }

    if (owner != null && owner != userId) {
      // Progres di HP milik user lain: user ini mulai dari awal
      await resetLocal(userId);
    } else {
      // Progres yang sudah ada di HP (dari sebelum fitur ini ada, atau
      // milik user ini sendiri) dipakai dan diunggah.
      await prefs.setInt(ownerKey, userId);
    }

    // Belum ada di server: muat dulu (supaya nilai awal tertulis di HP),
    // lalu unggah sebagai progres pertama user ini.
    ready = true;
    await reloadAll();
    await pushNow();
  }

  // Kirim perubahan terakhir sebelum token dihapus.
  Future<void> onLogout() async {
    await flush();
    ready = false;
  }

  // ---------- Mengirim ke server ----------

  // Dipanggil setiap PlayerProgress / DuckPet menyimpan data.
  void schedulePush() {
    if (!ready || !AuthSession.instance.isLoggedIn) return;
    pending?.cancel();
    pending = Timer(pushDelay, pushNow);
  }

  // Kirim sekarang kalau masih ada yang tertunda.
  Future<void> flush() async {
    if (pending == null) return;
    pending!.cancel();
    pending = null;
    await pushNow();
  }

  Future<bool> pushNow() async {
    pending?.cancel();
    pending = null;
    if (!ready || !AuthSession.instance.isLoggedIn) return false;
    try {
      await api.save(await snapshot());
      return true;
    } catch (_) {
      // Gagal (misalnya offline). Data tetap aman di HP dan akan terkirim
      // bersama perubahan berikutnya.
      return false;
    }
  }

  // ---------- Membaca & memasang data di HP ----------

  Future<Map<String, dynamic>> snapshot() async {
    final prefs = await SharedPreferences.getInstance();
    final data = <String, dynamic>{};
    for (final entry in keys.entries) {
      final value = prefs.get(entry.key);
      if (value != null) data[entry.key] = value;
    }
    return data;
  }

  Future<void> restore(Map<String, dynamic> data, int userId) async {
    final prefs = await SharedPreferences.getInstance();
    for (final entry in keys.entries) {
      await prefs.remove(entry.key);
      final value = data[entry.key];
      if (value == null) continue;

      // JSON tidak membedakan 80 dan 80.0, jadi tipe disesuaikan lagi
      switch (entry.value) {
        case StoreType.intValue:
          await prefs.setInt(entry.key, (value as num).toInt());
        case StoreType.doubleValue:
          await prefs.setDouble(entry.key, (value as num).toDouble());
        case StoreType.boolValue:
          await prefs.setBool(entry.key, value as bool);
        case StoreType.stringValue:
          await prefs.setString(entry.key, value.toString());
        case StoreType.stringList:
          await prefs.setStringList(
            entry.key,
            (value as List).map((e) => e.toString()).toList(),
          );
      }
    }
    await prefs.setInt(ownerKey, userId);
  }

  // Hapus progres di HP, lalu tandai sebagai milik user ini.
  Future<void> resetLocal(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in keys.keys) {
      await prefs.remove(key);
    }
    await prefs.setInt(ownerKey, userId);
  }

  // Muat ulang PlayerProgress dan DuckPet dari HP.
  Future<void> reloadAll() async {
    await PlayerProgress.instance.reload();
    await DuckPet.instance.reload();
  }

  @visibleForTesting
  void resetForTest(ProgressApi fakeApi) {
    api = fakeApi;
    ready = false;
    pending?.cancel();
    pending = null;
  }
}
