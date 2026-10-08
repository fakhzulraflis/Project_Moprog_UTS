import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/avatar_catalog.dart';
import '../services/date_format.dart';
import '../services/gallery_saver.dart';
import '../services/profile_service.dart';
import '../widgets/account_info_card.dart';
import '../widgets/press_button.dart';
import '../widgets/quack_app_bar.dart';

// Menampilkan kartu Account Information milik kita. Kartu ini hanya bisa
// diunduh sebagai gambar ke galeri untuk dibagikan.
class ShareProfilePage extends StatefulWidget {
  final UserProfile profile;
  final String title;

  const ShareProfilePage({
    super.key,
    required this.profile,
    this.title = 'Share profile',
  });

  @override
  State<ShareProfilePage> createState() => _ShareProfilePageState();
}

class _ShareProfilePageState extends State<ShareProfilePage> {
  final _cardKey = GlobalKey();
  bool _capturing = false; // true = kartu diam supaya hasil gambar rapi
  bool _saving = false;

  Future<void> _save() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _capturing = true;
    });

    String message;
    try {
      // tunggu kartu dibangun ulang tanpa animasi
      await WidgetsBinding.instance.endOfFrame;
      await WidgetsBinding.instance.endOfFrame;

      final boundary =
          _cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) throw Exception('Gagal membuat gambar.');

      message = await GallerySaver.savePng(
        data.buffer.asUint8List(),
        'quacko_${widget.profile.username}_${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e) {
      message = e.toString().replaceFirst('Exception: ', '');
    }

    if (!mounted) return;
    setState(() {
      _saving = false;
      _capturing = false;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;
    final character = AvatarCatalog.resolve(
      character: p.avatarCharacter,
      language: p.learningLanguage,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF272F33),
      appBar: quackAppBar(widget.title),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Save your card and share it with friends so they can find and follow you.',
                style: GoogleFonts.baloo2(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 20),
              // Bagian ini yang diekspor jadi gambar
              RepaintBoundary(
                key: _cardKey,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xFF272F33),
                  child: AccountInfoCard(
                    fullname: p.fullname,
                    username: p.username,
                    memberSince: monthYear(p.joinedAt),
                    language: p.learningLanguage,
                    character: character,
                    animated: !_capturing,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              PressButton.primary(
                label: _saving ? 'SAVING...' : 'SAVE TO GALLERY',
                icon: Icons.download_rounded,
                onTap: _saving ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
