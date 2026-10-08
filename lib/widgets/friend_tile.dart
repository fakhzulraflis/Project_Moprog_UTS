import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/avatar_catalog.dart';
import '../services/profile_service.dart';
import 'avatar_thumb.dart';
import 'press_button.dart';

// Satu baris user: foto, nama, username, dan tombol aksi di kanan.
class FriendTile extends StatelessWidget {
  final FriendUser user;
  final String actionLabel;
  final VoidCallback onAction;

  const FriendTile({
    super.key,
    required this.user,
    required this.onAction,
    this.actionLabel = 'VIEW',
  });

  @override
  Widget build(BuildContext context) {
    final character = AvatarCatalog.resolve(
      character: user.avatarCharacter,
      language: user.learningLanguage,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF20272B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF38474C), width: 2),
      ),
      child: Row(
        children: [
          AvatarThumb(character: character, size: 58),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullname,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.baloo2(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.15,
                  ),
                ),
                Text(
                  '@${user.username}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.baloo2(
                    color: Colors.white54,
                    fontSize: 14,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 92,
            child: PressButton.outline(
              label: actionLabel,
              height: 40,
              depth: 4,
              fontSize: 14,
              radius: 12,
              padding: EdgeInsets.zero,
              textColor: const Color(0xFF55B6E8),
              onTap: onAction,
            ),
          ),
        ],
      ),
    );
  }
}
