import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/profile_service.dart';
import '../widgets/friend_tile.dart';
import '../widgets/quack_app_bar.dart';

// Daftar user yang kita blokir, dengan tombol untuk membuka blokir.
class BlockedUsersPage extends StatefulWidget {
  const BlockedUsersPage({super.key});

  @override
  State<BlockedUsersPage> createState() => _BlockedUsersPageState();
}

class _BlockedUsersPageState extends State<BlockedUsersPage> {
  List<FriendUser> _users = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final users = await ProfileService.getBlocked();
      if (!mounted) return;
      setState(() {
        _users = users;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _unblock(FriendUser user) async {
    try {
      await ProfileService.toggleBlock(user.id);
      if (!mounted) return;
      setState(() => _users.removeWhere((u) => u.id == user.id));
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Unblocked @${user.username}')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF272F33),
      appBar: quackAppBar('Blocked players'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.baloo2(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (_users.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Text(
                      'You have not blocked anyone.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.baloo2(
                        color: Colors.white54,
                        fontSize: 17,
                      ),
                    ),
                  ),
                for (final user in _users)
                  FriendTile(
                    user: user,
                    actionLabel: 'UNBLOCK',
                    onAction: () => _unblock(user),
                  ),
              ],
            ),
    );
  }
}
