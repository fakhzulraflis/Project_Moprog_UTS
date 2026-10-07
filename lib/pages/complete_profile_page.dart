import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/avatar_catalog.dart';
import '../services/profile_service.dart';

// Syarat melengkapi profil: ikuti minimal 1 user dan sukai minimal 1 postingan.
class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  List<SuggestedUser> _users = [];
  List<CommunityPost> _posts = [];
  bool _loading = true;
  String? _error;
  bool _changed = false;

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
      final users = await ProfileService.getSuggestions();
      final posts = await ProfileService.getPosts();
      if (!mounted) return;
      setState(() {
        _users = users;
        _posts = posts;
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

  void _showError(Object e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
    );
  }

  Future<void> _toggleFollow(int index) async {
    final user = _users[index];
    try {
      final following = await ProfileService.toggleFollow(user.id);
      if (!mounted) return;
      _changed = true;
      setState(() {
        _users[index] = SuggestedUser(
          id: user.id,
          fullname: user.fullname,
          username: user.username,
          learningLanguage: user.learningLanguage,
          isFollowing: following,
        );
      });
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _toggleLike(int index) async {
    final post = _posts[index];
    try {
      final liked = await ProfileService.toggleLike(post.id);
      if (!mounted) return;
      _changed = true;
      setState(() {
        _posts[index] = CommunityPost(
          id: post.id,
          body: post.body,
          authorName: post.authorName,
          authorUsername: post.authorUsername,
          learningLanguage: post.learningLanguage,
          likeCount: post.likeCount + (liked ? 1 : -1),
          liked: liked,
        );
      });
    } catch (e) {
      _showError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final followed = _users.any((u) => u.isFollowing);
    final liked = _posts.any((p) => p.liked);

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
          title: Text(
            'Complete your profile',
            style: GoogleFonts.baloo2(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _buildError()
            : ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _stepHeader('1. Follow at least one learner', followed),
                  const SizedBox(height: 12),
                  if (_users.isEmpty) _emptyText('No other learners yet.'),
                  for (int i = 0; i < _users.length; i++) _userTile(i),
                  const SizedBox(height: 24),
                  _stepHeader('2. Like at least one post', liked),
                  const SizedBox(height: 12),
                  if (_posts.isEmpty) _emptyText('No posts yet.'),
                  for (int i = 0; i < _posts.length; i++) _postTile(i),
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
            ElevatedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _emptyText(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: GoogleFonts.baloo2(color: Colors.white54, fontSize: 15),
    ),
  );

  Widget _stepHeader(String title, bool done) {
    return Row(
      children: [
        Icon(
          done ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
          color: done ? const Color(0xFF58CC02) : Colors.white38,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.baloo2(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  BoxDecoration get _cardDecoration => BoxDecoration(
    color: const Color(0xFF20272B),
    borderRadius: BorderRadius.circular(16),
  );

  Widget _userTile(int index) {
    final user = _users[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0A8),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              AvatarCatalog.forLanguage(user.learningLanguage).asset,
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
            ),
          ),
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
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '@${user.username}',
                  style: GoogleFonts.baloo2(color: Colors.white54),
                ),
              ],
            ),
          ),
          _pillButton(
            label: user.isFollowing ? 'FOLLOWING' : 'FOLLOW',
            active: user.isFollowing,
            onTap: () => _toggleFollow(index),
          ),
        ],
      ),
    );
  }

  Widget _postTile(int index) {
    final post = _posts[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${post.authorName} · @${post.authorUsername}',
            style: GoogleFonts.baloo2(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            post.body,
            style: GoogleFonts.baloo2(color: Colors.white, fontSize: 17),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                onTap: () => _toggleLike(index),
                child: Icon(
                  post.liked ? Icons.favorite : Icons.favorite_border,
                  color: post.liked ? const Color(0xFFFF4B4B) : Colors.white54,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${post.likeCount}',
                style: GoogleFonts.baloo2(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pillButton({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.transparent : const Color(0xFF55B6E8),
          border: Border.all(
            color: active ? Colors.white24 : const Color(0xFF55B6E8),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: GoogleFonts.baloo2(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
