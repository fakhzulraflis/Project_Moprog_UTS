import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'inventory_service.dart';
import 'profile_service.dart';
import 'progress_sync.dart';

// Menyimpan siapa yang sedang login, beserta token dari backend.
// Token dikirim ke API yang butuh login (misalnya inventory), supaya
// backend tahu data milik user yang mana.
class AuthSession {
  AuthSession._();

  static final AuthSession instance = AuthSession._();

  String? token;
  int? userId;
  String? username;

  bool get isLoggedIn => token != null;

  // Dipanggil setelah login berhasil, dengan isi respons dari /api/login.
  Future<void> saveLogin(Map<String, dynamic> response) async {
    final user = response['user'] as Map<String, dynamic>? ?? {};
    token = response['token'] as String?;
    userId = (user['id'] as num?)?.toInt();
    username = user['username'] as String?;

    final p = await SharedPreferences.getInstance();
    if (token == null) {
      await p.remove('auth_token');
    } else {
      await p.setString('auth_token', token!);
    }
    if (userId != null) await p.setInt('auth_user_id', userId!);
    if (username != null) await p.setString('auth_username', username!);

    // Inventory user sebelumnya dibuang, lalu dimuat ulang untuk user ini.
    // Tidak ditunggu supaya masuk ke aplikasi tidak jadi lambat.
    InventoryService.instance.reload();

    // Progres halaman Misi milik user ini diambil dari database. Ditunggu
    // supaya halaman Misi langsung menampilkan data yang benar.
    await ProgressSync.instance.onLogin();
  }

  // Muat sesi yang tersimpan di HP (kalau ada).
  Future<void> load() async {
    if (token != null) return;
    final p = await SharedPreferences.getInstance();
    token = p.getString('auth_token');
    userId = p.getInt('auth_user_id');
    username = p.getString('auth_username');
  }

  // Keluar: cabut token di server (kalau bisa), lalu hapus sesi di HP.
  Future<void> signOut() async {
    // Kirim progres terakhir selagi token masih ada
    await ProgressSync.instance.onLogout();
    await ProfileService.signOutOnServer();
    token = null;
    userId = null;
    username = null;

    final p = await SharedPreferences.getInstance();
    await p.remove('auth_token');
    await p.remove('auth_user_id');
    await p.remove('auth_username');

    final inventory = InventoryService.instance;
    inventory.items = [];
    inventory.active = [];
    inventory.isLoaded = false;
  }

  @visibleForTesting
  void setForTest({String? token, int? userId}) {
    this.token = token;
    this.userId = userId;
  }
}
