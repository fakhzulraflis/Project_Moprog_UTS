import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/leaderboard_user.dart';
import '../models/league.dart';
import '../services/leaderboard_service.dart';

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
    _usersFuture = service.getWeeklyLeaderboard();
  }

  Future<void> _refresh() async {
    setState(_loadData);
    await Future.wait([_leagueFuture, _usersFuture]);
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
                final isLoading = leagueSnapshot.connectionState !=
                        ConnectionState.done ||
                    usersSnapshot.connectionState != ConnectionState.done;

                if (isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF1CB0F6)),
                  );
                }

                if (leagueSnapshot.hasError || usersSnapshot.hasError) {
                  return _ErrorState(onRetry: () => setState(_loadData));
                }

                final league = leagueSnapshot.data!;
                final users = usersSnapshot.data!;

                return RefreshIndicator(
                  onRefresh: _refresh,
                  color: const Color(0xFF1CB0F6),
                  backgroundColor: const Color(0xFF20272B),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Header(league: league),
                      const SizedBox(height: 8),
                      Expanded(
                        child: _LeaderboardList(league: league, users: users),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, color: Colors.white.withValues(alpha: 0.5), size: 40),
          const SizedBox(height: 12),
          Text(
            'Gagal memuat leaderboard',
            style: GoogleFonts.nunito(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Coba lagi',
              style: GoogleFonts.nunito(
                color: const Color(0xFF1CB0F6),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final League league;

  const _Header({required this.league});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Image.asset(league.iconAsset, height: 56),
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
                  'Top ${league.promotionZoneSize} naik ke league berikutnya',
                  style: GoogleFonts.nunito(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
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

  const _LeaderboardList({required this.league, required this.users});

  @override
  Widget build(BuildContext context) {
    final totalUsers = users.length;
    final demotionStartRank = totalUsers - league.demotionZoneSize + 1;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: users.length,
      separatorBuilder: (context, index) {
        final rankAfter = users[index].rank;
        final showPromotionDivider = rankAfter == league.promotionZoneSize &&
            totalUsers > league.promotionZoneSize;
        final showDemotionDivider = rankAfter == demotionStartRank - 1 &&
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
        return const SizedBox(height: 6);
      },
      itemBuilder: (context, index) => _LeaderboardTile(user: users[index]),
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
          Expanded(child: Divider(color: color.withValues(alpha: 0.4), thickness: 1)),
          const SizedBox(width: 8),
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.nunito(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: color.withValues(alpha: 0.4), thickness: 1)),
        ],
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final LeaderboardUser user;

  const _LeaderboardTile({required this.user});

  Color _rankColor() {
    switch (user.rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return const Color(0xFF4B565C);
    }
  }

  Color _avatarColor() {
    final colors = [
      const Color(0xFF1CB0F6),
      const Color(0xFFCE82FF),
      const Color(0xFFFF9600),
      const Color(0xFF58CC02),
      const Color(0xFFFF4B4B),
    ];
    return colors[user.name.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final highlight = user.isMe;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFF33414A) : const Color(0xFF20272B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight
              ? const Color(0xFF1CB0F6)
              : Colors.white.withValues(alpha: 0.06),
          width: highlight ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '${user.rank}',
              textAlign: TextAlign.center,
              style: GoogleFonts.baloo2(
                color: _rankColor(),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 18,
            backgroundColor: _avatarColor(),
            backgroundImage:
                user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
            child: user.avatarUrl == null
                ? Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: GoogleFonts.baloo2(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              user.name,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontSize: 15,
                fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
          Image.asset('assets/icons/xp.png', height: 16),
          const SizedBox(width: 4),
          Text(
            '${user.xp} XP',
            style: GoogleFonts.nunito(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
