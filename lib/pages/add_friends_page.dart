import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/profile_service.dart';
import '../widgets/press_button.dart';
import 'search_users_page.dart';
import 'share_profile_page.dart';

// Cara menemukan teman: cari lewat username, atau bagikan kartu profil sendiri.
class AddFriendsPage extends StatefulWidget {
  final UserProfile profile;

  const AddFriendsPage({super.key, required this.profile});

  @override
  State<AddFriendsPage> createState() => _AddFriendsPageState();
}

class _AddFriendsPageState extends State<AddFriendsPage> {
  bool _changed = false;

  Future<void> _openSearch() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const SearchUsersPage()),
    );
    if (changed == true) _changed = true;
  }

  void _openShare() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShareProfilePage(
          profile: widget.profile,
          title: 'Share follow link',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pop(context, _changed);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF272F33),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context, _changed),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white70,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 0, 20),
                  child: Text(
                    'Find your friends',
                    style: GoogleFonts.baloo2(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Column(
                    children: [
                      _option(
                        icon: Icons.search_rounded,
                        color: const Color(0xFF55B6E8),
                        label: 'Search by username',
                        onTap: _openSearch,
                      ),
                      const SizedBox(height: 14),
                      _option(
                        icon: Icons.ios_share_rounded,
                        color: const Color(0xFFFFD84A),
                        label: 'Share follow link',
                        onTap: _openShare,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _option({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return PressButton.outline(
      height: 72,
      radius: 18,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Icon(icon, color: color, size: 34),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.baloo2(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.white38),
        ],
      ),
    );
  }
}
