import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/leaderboard_user.dart';
import '../models/league.dart';
import '../pages/league_journey_page.dart';
import '../services/avatar_catalog.dart';
import '../services/leaderboard_service.dart';
import '../services/profile_service.dart';
import '../widgets/avatar_thumb.dart';
import '../widgets/press_button.dart';
import '../widgets/user_card_dialog.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  late Future<League> _leagueFuture;
  late Future<List<LeaderboardUser>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final service = LeaderboardService.instance;

    _leagueFuture = service.getCurrentLeague();
    _usersFuture = service.getLeaderboard();
  }

  Future<void> _refresh() async {
    setState(_loadData);

    try {
      await Future.wait([_leagueFuture, _usersFuture]);
    } catch (_) {
      // Kesalahan ditampilkan oleh FutureBuilder di bawah
    }
  }

  // Membuka kartu pemain yang disentuh. Kalau ada yang berubah (misalnya
  // pemain itu diblokir), leaderboard dimuat ulang.
  Future<void> _openPlayer(LeaderboardUser user) async {
    if (user.isMe) return;

    final messenger = ScaffoldMessenger.of(context);

    try {
      final friend = await ProfileService.getUser(user.userId);
      if (!mounted) return;

      final changed = await showUserCardDialog(context, friend);
      if (changed && mounted) _refresh();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF272F33),
      body: SafeArea(
        child: FutureBuilder<League>(
          future: _leagueFuture,
          builder: (context, leagueSnapshot) {
            return FutureBuilder<List<LeaderboardUser>>(
              future: _usersFuture,
              builder: (context, usersSnapshot) {
                final isLoading =
                    leagueSnapshot.connectionState != ConnectionState.done ||
                    usersSnapshot.connectionState != ConnectionState.done;

                final hasData = leagueSnapshot.hasData && usersSnapshot.hasData;

                if (isLoading && !hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF1CB0F6)),
                  );
                }

                if (leagueSnapshot.hasError || usersSnapshot.hasError) {
                  return _ErrorState(onRetry: () => setState(_loadData));
                }

                final league = leagueSnapshot.data!;
                final users = usersSnapshot.data!;

                LeaderboardUser? currentUser;

                for (final user in users) {
                  if (user.isMe) {
                    currentUser = user;
                    break;
                  }
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  color: const Color(0xFF1CB0F6),
                  backgroundColor: const Color(0xFF20272B),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Header(
                        league: league,
                        currentRank: currentUser?.rank ?? 0,
                        totalUsers: users.length,
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: _LeaderboardList(
                          league: league,
                          users: users,
                          onTap: _openPlayer,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              color: Colors.white.withValues(alpha: 0.5),
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'Gagal memuat leaderboard',
              style: GoogleFonts.baloo2(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            PressButton.primary(label: 'COBA LAGI', width: 160, onTap: onRetry),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final League league;
  final int currentRank;
  final int totalUsers;

  const _Header({
    required this.league,
    required this.currentRank,
    required this.totalUsers,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LeagueJourneyPage(
                    currentLeague: league,
                    currentRank: currentRank,
                    totalUsers: totalUsers,
                  ),
                ),
              );
            },
            child: Image.asset(league.iconAsset, height: 56),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  league.name,
                  style: GoogleFonts.baloo2(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  currentRank > 0
                      ? 'Peringkatmu #$currentRank dari $totalUsers pemain'
                      : '$totalUsers pemain',
                  style: GoogleFonts.baloo2(
                    color: const Color(0xFF55B6E8),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  league.nextLeague == null
                      ? 'Kamu di liga tertinggi, pertahankan posisimu!'
                      : 'Top ${league.promotionZoneSize} naik ke '
                            '${league.nextLeague!.name}',
                  style: GoogleFonts.baloo2(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardList extends StatelessWidget {
  final League league;
  final List<LeaderboardUser> users;
  final void Function(LeaderboardUser user) onTap;

  const _LeaderboardList({
    required this.league,
    required this.users,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final totalUsers = users.length;

    final demotionStartRank = totalUsers - league.demotionZoneSize + 1;

    if (users.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 60),
            child: Text(
              'Belum ada pemain.',
              textAlign: TextAlign.center,
              style: GoogleFonts.baloo2(color: Colors.white54, fontSize: 17),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: users.length,
      separatorBuilder: (context, index) {
        final rankAfter = users[index].rank;

        final showPromotionDivider =
            rankAfter == league.promotionZoneSize &&
            totalUsers > league.promotionZoneSize;

        final showDemotionDivider =
            league.demotionZoneSize > 0 &&
            rankAfter == demotionStartRank - 1 &&
            league.demotionZoneSize < totalUsers;

        if (showPromotionDivider) {
          return const _ZoneDivider(
            label: 'Zona Promosi',
            color: Color(0xFF58CC02),
            icon: Icons.arrow_upward_rounded,
          );
        }

        if (showDemotionDivider) {
          return const _ZoneDivider(
            label: 'Zona Degradasi',
            color: Color(0xFFFF4B4B),
            icon: Icons.arrow_downward_rounded,
          );
        }

        return const SizedBox.shrink();
      },
      itemBuilder: (context, index) {
        final user = users[index];

        return _LeaderboardTile(user: user, onTap: () => onTap(user));
      },
    );
  }
}

class _ZoneDivider extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _ZoneDivider({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Divider(color: color.withValues(alpha: 0.4), thickness: 1),
          ),
          const SizedBox(width: 8),
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.baloo2(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Divider(color: color.withValues(alpha: 0.4), thickness: 1),
          ),
        ],
      ),
    );
  }
}

// Baris leaderboard dengan tata letak yang sama seperti daftar teman:
// foto persegi, nama lengkap, dan @username. Peringkat di kiri dan XP di kanan.
class _LeaderboardTile extends StatelessWidget {
  final LeaderboardUser user;
  final VoidCallback onTap;

  const _LeaderboardTile({required this.user, required this.onTap});

  Color _rankColor() {
    switch (user.rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return const Color(0xFF8A969C);
    }
  }

  @override
  Widget build(BuildContext context) {
    final highlight = user.isMe;
    final character = AvatarCatalog.resolve(
      character: user.avatarCharacter,
      language: user.learningLanguage,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: user.isMe ? null : onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
        decoration: BoxDecoration(
          color: highlight ? const Color(0xFF2A3A44) : const Color(0xFF20272B),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: highlight
                ? const Color(0xFF55B6E8)
                : const Color(0xFF38474C),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Text(
                '${user.rank}',
                textAlign: TextAlign.center,
                style: GoogleFonts.baloo2(
                  color: _rankColor(),
                  fontSize: user.rank <= 3 ? 20 : 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 6),
            AvatarThumb(character: character, size: 54),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.baloo2(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      height: 1.15,
                    ),
                  ),
                  Text(
                    highlight
                        ? '@${user.username} · kamu'
                        : '@${user.username}',
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
            const SizedBox(width: 8),
            Image.asset('assets/icons/xp.png', height: 18),
            const SizedBox(width: 4),
            Text(
              '${user.xp}',
              style: GoogleFonts.baloo2(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
