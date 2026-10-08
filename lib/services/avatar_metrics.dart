// DIBUAT OTOMATIS oleh tools/prepare_avatars.py. Jangan diedit manual;
// jalankan ulang skrip tersebut kalau aset di assets/avatar/ diganti.
import 'package:flutter/painting.dart';

// Ukuran dan posisi fitur wajah (fraksi 0..1 dari gambar yang sudah di-trim).
class AvatarMetrics {
  final double aspect; // lebar / tinggi
  final Rect? eye; // mata yang terbuka (untuk animasi kedip)
  final Color skin; // warna kulit di sekitar mata
  final List<Rect> blush; // pipi (untuk karakter tanpa mata terbuka)

  const AvatarMetrics({
    required this.aspect,
    this.eye,
    this.skin = const Color(0xFFFFC832),
    this.blush = const [],
  });
}

const Map<String, AvatarMetrics> avatarMetrics = {
  'binbin_cardigan': AvatarMetrics(
    aspect: 0.4894,
    eye: Rect.fromLTRB(0.5955, 0.3968, 0.7292, 0.4690),
    skin: Color(0xFFFCEFDB),
  ),
  'binbin_florist': AvatarMetrics(
    aspect: 0.6951,
    eye: Rect.fromLTRB(0.6104, 0.3958, 0.7030, 0.4678),
    skin: Color(0xFFFCEBD3),
  ),
  'binbin_winter': AvatarMetrics(
    aspect: 0.4752,
    eye: Rect.fromLTRB(0.6747, 0.3938, 0.8099, 0.4605),
    skin: Color(0xFFFCECD9),
  ),
  'engduck': AvatarMetrics(
    aspect: 0.6690,
    eye: Rect.fromLTRB(0.6831, 0.3416, 0.7852, 0.4217),
    skin: Color(0xFFFDC632),
  ),
  'japduck': AvatarMetrics(
    aspect: 0.5439,
    blush: [
      Rect.fromLTRB(0.2065, 0.3556, 0.3106, 0.4088),
      Rect.fromLTRB(0.6910, 0.3556, 0.7919, 0.4088),
    ],
  ),
  'korduck': AvatarMetrics(
    aspect: 0.6591,
    eye: Rect.fromLTRB(0.5722, 0.2652, 0.6794, 0.3342),
    skin: Color(0xFFFDCA28),
  ),
  'qua_chef': AvatarMetrics(
    aspect: 0.7892,
    eye: Rect.fromLTRB(0.6927, 0.3396, 0.7707, 0.4067),
    skin: Color(0xFFF8C31D),
  ),
  'qua_scholar': AvatarMetrics(
    aspect: 0.8537,
    eye: Rect.fromLTRB(0.6009, 0.2926, 0.6737, 0.3707),
    skin: Color(0xFFF6C414),
  ),
};
