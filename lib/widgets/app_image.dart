import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Menampilkan aset PNG/JPG maupun SVG, dipilih otomatis dari ekstensinya.
class AppImage extends StatelessWidget {
  final String asset;
  final double? width;
  final double? height;
  final BoxFit fit;

  /// Hanya dipakai untuk aset non-SVG
  final ImageErrorWidgetBuilder? errorBuilder;

  const AppImage(
    this.asset, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (asset.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(asset, width: width, height: height, fit: fit);
    }

    return Image.asset(
      asset,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: errorBuilder,
    );
  }
}
