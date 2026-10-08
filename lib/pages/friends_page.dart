import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/profile_service.dart';
import '../widgets/friend_tile.dart';
import '../widgets/press_button.dart';
import '../widgets/user_card_dialog.dart';
import 'add_friends_page.dart';

// Daftar user yang kita ikuti (Following) dan yang mengikuti kita (Followers).
class FriendsPage extends StatefulWidget {
  final UserProfile profile;
  final int initialTab; // 0 = Following, 1 = Followers

  const FriendsPage({super.key, required this.profile, this.initialTab = 0});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(
    length: 2,
    vsync: this,
    initialIndex: widget.initialTab,
  );

  List<FriendUser> _following = [];
  List<FriendUser> _followers = [];
  bool _loading = true;
  String? _error;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = _following.isEmpty && _followers.isEmpty;
      _error = null;
    });
    try {
      final results = await Future.wait([
        ProfileService.getFollowing(),
        ProfileService.getFollowers(),
      ]);
      if (!mounted) return;
      setState(() {
        _following = results[0];
        _followers = results[1];
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

  Future<void> _view(FriendUser user) async {
    final changed = await showUserCardDialog(context, user);
    if (changed) {
      _changed = true;
      _load();
    }
  }

  Future<void> _addFriends() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddFriendsPage(profile: widget.profile),
      ),
    );
    if (changed == true) {
      _changed = true;
      _load();
    }
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
        appBar: AppBar(
          backgroundColor: const Color(0xFF272F33),
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            'Friends',
            style: GoogleFonts.baloo2(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          bottom: TabBar(
            controller: _tabs,
            indicatorColor: const Color(0xFF55B6E8),
            indicatorWeight: 3,
            dividerColor: const Color(0xFF38474C),
            labelColor: const Color(0xFF55B6E8),
            unselectedLabelColor: Colors.white38,
            labelStyle: GoogleFonts.baloo2(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              letterSpacing: 0.6,
            ),
            tabs: [
              Tab(text: 'FOLLOWING (${_following.length})'),
              Tab(text: 'FOLLOWERS (${_followers.length})'),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _buildError()
            : TabBarView(
                controller: _tabs,
                children: [
                  _buildList(_following, followingTab: true),
                  _buildList(_followers, followingTab: false),
                ],
              ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.baloo2(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 12),
            PressButton.primary(label: 'RETRY', width: 140, onTap: _load),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<FriendUser> users, {required bool followingTab}) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        children: [
          if (users.isEmpty) _buildEmpty(followingTab),
          for (final user in users)
            FriendTile(user: user, onAction: () => _view(user)),
        ],
      ),
    );
  }

  Widget _buildEmpty(bool followingTab) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF38474C), width: 2),
      ),
      child: Column(
        children: [
          Image.asset('assets/app/qua.gif', height: 110),
          const SizedBox(height: 14),
          Text(
            followingTab
                ? 'Learning is more fun and effective when you connect with others.'
                : 'No followers yet. Add friends and they may follow you back!',
            textAlign: TextAlign.center,
            style: GoogleFonts.baloo2(
              color: Colors.white,
              fontSize: 18,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 18),
          PressButton.outline(
            label: 'ADD FRIENDS',
            icon: Icons.person_add_alt_1_rounded,
            textColor: const Color(0xFF55B6E8),
            onTap: _addFriends,
          ),
        ],
      ),
    );
  }
}
