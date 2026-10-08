import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';

// Menyimpan gambar PNG ke galeri HP. Di Windows gambar disimpan ke folder
// Pictures karena paket galeri hanya untuk HP.
class GallerySaver {
  GallerySaver._();

  // Mengembalikan pesan sukses untuk ditampilkan ke user.
  // Melempar Exception dengan pesan yang ramah kalau gagal.
  static Future<String> savePng(Uint8List bytes, String name) async {
    if (kIsWeb) {
      throw Exception('Menyimpan ke galeri belum didukung di web.');
    }

    try {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
        case TargetPlatform.iOS:
        case TargetPlatform.macOS:
          if (!await Gal.hasAccess(toAlbum: true)) {
            if (!await Gal.requestAccess(toAlbum: true)) {
              throw Exception(
                'Izin galeri ditolak. Aktifkan di pengaturan HP.',
              );
            }
          }
          await Gal.putImageBytes(bytes, album: 'Quack-O', name: name);
          return 'Tersimpan di galeri (album Quack-O).';
        case TargetPlatform.windows:
          final home = Platform.environment['USERPROFILE'];
          if (home == null) throw Exception('Folder Pictures tidak ditemukan.');
          final dir = Directory(
            '$home${Platform.pathSeparator}Pictures'
            '${Platform.pathSeparator}Quack-O',
          );
          await dir.create(recursive: true);
          final file = File('${dir.path}${Platform.pathSeparator}$name.png');
          await file.writeAsBytes(bytes);
          return 'Tersimpan di ${file.path}';
        default:
          throw Exception('Menyimpan gambar belum didukung di perangkat ini.');
      }
    } on GalException catch (e) {
      throw Exception('Gagal menyimpan: ${e.type.message}');
    }
  }
}
