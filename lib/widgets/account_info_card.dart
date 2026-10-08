import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/avatar_catalog.dart';
import '../services/language_asset_service.dart';
import 'animated_avatar.dart';

// Kartu "Account Information" milik satu user. Dipakai di halaman share
// (untuk diunduh) dan di popup profil user lain.
class AccountInfoCard extends StatelessWidget {
  final String fullname;
  final String username;
  final String memberSince;
  final String language;
  final AvatarCharacter character;

  // false = gambar karakter diam (dipakai saat kartu diekspor jadi PNG)
  final bool animated;

  // Info tambahan di bawah (misalnya jumlah like). Boleh kosong.
  final Widget? footer;

  const AccountInfoCard({
    super.key,
    required this.fullname,
    required this.username,
    required this.memberSince,
    required this.language,
    required this.character,
    this.animated = true,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF20272B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF38474C), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset('assets/app/logo.png', height: 22),
              const SizedBox(width: 8),
              Text(
                'Account Information',
                style: GoogleFonts.pixelifySans(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullname,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.baloo2(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      '@$username',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.baloo2(
                        color: Colors.white54,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _label('Member Since'),
                    _value(memberSince),
                    const SizedBox(height: 10),
                    _label('Learning Language'),
                    Row(
                      children: [
                        Image.asset(
                          LanguageAssetService.flagFor(language),
                          width: 20,
                          height: 20,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 6),
                        Flexible(child: _value(language)),
                      ],
                    ),
                    if (footer != null) ...[
                      const SizedBox(height: 12),
                      footer!,
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AnimatedAvatar(
                key: ValueKey('${character.key}-$animated'),
                character: character,
                height: 170,
                animate: animated,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: GoogleFonts.pixelifySans(color: Colors.white54, fontSize: 12),
  );

  Widget _value(String text) => Text(
    text,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: GoogleFonts.baloo2(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  );
}
