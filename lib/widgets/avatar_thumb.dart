import 'package:flutter/material.dart';

import '../services/avatar_catalog.dart';
import '../services/avatar_metrics.dart';

// Foto karakter berbentuk kotak (sudut membulat) untuk daftar teman dan
// leaderboard. Gambar dipotong dari atas dan diatur supaya kepala dan wajah
// karakter selalu terlihat: bagian yang tampil dihitung dari posisi mata
// (atau pipi) yang sudah dideteksi di avatar_metrics.dart.
class AvatarThumb extends StatelessWidget {
  final AvatarCharacter character;
  final double size;

  const AvatarThumb({super.key, required this.character, this.size = 56});

  // Bagian atas gambar yang ditampilkan, sebagai pecahan tinggi gambar:
  // sampai sedikit di bawah wajah, tetapi tidak sampai melebihi lebar gambar
  // (supaya tidak ada sisi yang terpotong).
  static double visibleFraction(AvatarMetrics? metrics) {
    final aspect = metrics?.aspect ?? 0.7;

    final faceY =
        metrics?.eye?.center.dy ??
        (metrics != null && metrics.blush.isNotEmpty
            ? metrics.blush.first.center.dy
            : 0.33);

    final wanted = (faceY + 0.18).clamp(0.40, 0.62);

    return aspect > wanted ? aspect.clamp(0.0, 0.85) : wanted;
  }

  @override
  Widget build(BuildContext context) {
    final metrics = avatarMetrics[character.key];
    final aspect = metrics?.aspect ?? 0.7;

    final top = size * 0.04;
    final height = (size - top) / visibleFraction(metrics);
    final width = height * aspect;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0A8),
        borderRadius: BorderRadius.circular(size * 0.22),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            left: (size - width) / 2,
            top: top,
            width: width,
            height: height,
            child: Image.asset(
              character.asset,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.none,
            ),
          ),
        ],
      ),
    );
  }
}
