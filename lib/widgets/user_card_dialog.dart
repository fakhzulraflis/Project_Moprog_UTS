import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/avatar_catalog.dart';
import '../services/date_format.dart';
import '../services/profile_service.dart';
import 'account_info_card.dart';
import 'press_button.dart';

// Popup kartu Account Information milik user lain, dengan tombol
// follow/unfollow, like, block, dan report.
// Mengembalikan true kalau ada yang berubah (supaya daftar bisa dimuat ulang).
Future<bool> showUserCardDialog(BuildContext context, FriendUser user) async {
  final changed = await showDialog<bool>(
    context: context,
    builder: (_) => _UserCardDialog(user: user),
  );
  return changed ?? false;
}

class _UserCardDialog extends StatefulWidget {
  final FriendUser user;

  const _UserCardDialog({required this.user});

  @override
  State<_UserCardDialog> createState() => _UserCardDialogState();
}

class _UserCardDialogState extends State<_UserCardDialog> {
  late FriendUser _user = widget.user;
  bool _busy = false;
  bool _changed = false;

  static const _reasons = {
    'inappropriate_name': 'Inappropriate name or photo',
    'spam': 'Spam',
    'harassment': 'Harassment or bullying',
    'other': 'Something else',
  };

  void _toast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // Menjalankan aksi ke server sambil mengunci tombol.
  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      if (mounted) _toast(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggleFollow() => _run(() async {
    final following = await ProfileService.toggleFollow(_user.id);
    if (!mounted) return;
    setState(() {
      _changed = true;
      _user = _user.copyWith(
        isFollowing: following,
        followersCount: _user.followersCount + (following ? 1 : -1),
      );
    });
  });

  Future<void> _toggleLike() => _run(() async {
    final updated = await ProfileService.toggleUserLike(_user.id);
    if (!mounted) return;
    setState(() {
      _changed = true;
      _user = _user.copyWith(
        liked: updated.liked,
        likeCount: updated.likeCount,
      );
    });
  });

  Future<void> _block() async {
    final ok = await _confirm(
      title: 'Block @${_user.username}?',
      message:
          'You will not see each other anymore and any follow between you '
          'will be removed. You can unblock from Settings.',
      confirmLabel: 'BLOCK',
    );
    if (ok != true) return;
    await _run(() async {
      await ProfileService.toggleBlock(_user.id);
      if (!mounted) return;
      final name = _user.username;
      Navigator.pop(context, true);
      _toast('Blocked @$name');
    });
  }

  Future<void> _report() async {
    final reason = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF20272B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Report @${_user.username}',
                style: GoogleFonts.baloo2(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Why are you reporting this player?',
                style: GoogleFonts.baloo2(color: Colors.white54, fontSize: 15),
              ),
              const SizedBox(height: 14),
              for (final entry in _reasons.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: PressButton.outline(
                    label: entry.value,
                    height: 48,
                    fontSize: 16,
                    onTap: () => Navigator.pop(sheetContext, entry.key),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (reason == null) return;
    await _run(() async {
      await ProfileService.reportUser(_user.id, reason);
      if (mounted) _toast('Report sent. Thank you!');
    });
  }

  Future<bool?> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF20272B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          title,
          style: GoogleFonts.baloo2(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.baloo2(color: Colors.white70, fontSize: 16),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          Row(
            children: [
              Expanded(
                child: PressButton.outline(
                  label: 'CANCEL',
                  height: 44,
                  fontSize: 15,
                  onTap: () => Navigator.pop(dialogContext, false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PressButton.danger(
                  label: confirmLabel,
                  height: 44,
                  fontSize: 15,
                  onTap: () => Navigator.pop(dialogContext, true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(icon, height: 16),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.baloo2(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final u = _user;
    final character = AvatarCatalog.resolve(
      character: u.avatarCharacter,
      language: u.learningLanguage,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pop(context, _changed);
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AccountInfoCard(
                fullname: u.fullname,
                username: u.username,
                memberSince: monthYear(u.joinedAt),
                language: u.learningLanguage,
                character: character,
                footer: Wrap(
                  spacing: 14,
                  runSpacing: 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.favorite_rounded,
                          color: Color(0xFFFF6F91),
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${u.likeCount}',
                          style: GoogleFonts.baloo2(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${u.followersCount} followers',
                      style: GoogleFonts.baloo2(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                    _stat('assets/icons/xp.png', '${u.xp} XP'),
                    _stat('assets/icons/streak.png', '${u.streak} day streak'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: u.isFollowing
                        ? PressButton.outline(
                            label: 'UNFOLLOW',
                            fontSize: 16,
                            onTap: _busy ? null : _toggleFollow,
                          )
                        : PressButton.primary(
                            label: 'FOLLOW',
                            icon: Icons.person_add_alt_1_rounded,
                            fontSize: 16,
                            onTap: _busy ? null : _toggleFollow,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: u.liked
                        ? PressButton(
                            label: 'LIKED',
                            icon: Icons.favorite_rounded,
                            color: const Color(0xFFFF6F91),
                            shadowColor: const Color(0xFFD9507A),
                            fontSize: 16,
                            padding: EdgeInsets.zero,
                            onTap: _busy ? null : _toggleLike,
                          )
                        : PressButton.outline(
                            label: 'LIKE',
                            icon: Icons.favorite_border_rounded,
                            fontSize: 16,
                            padding: EdgeInsets.zero,
                            onTap: _busy ? null : _toggleLike,
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: _busy ? null : _block,
                      icon: const Icon(Icons.block_rounded, size: 18),
                      label: Text(
                        'Block player',
                        style: GoogleFonts.baloo2(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFFF6B6B),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: _busy ? null : _report,
                      icon: const Icon(Icons.flag_rounded, size: 18),
                      label: Text(
                        'Report',
                        style: GoogleFonts.baloo2(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFFF6B6B),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
