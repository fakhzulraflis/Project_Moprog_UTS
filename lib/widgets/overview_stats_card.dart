import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Kartu "Overview" di profil: ringkasan XP, streak, gem, hati, lesson yang
// sudah selesai, dan peringkat di leaderboard.
class OverviewStatsCard extends StatelessWidget {
  final int xp;
  final int streak;
  final int bestStreak;
  final int gems;
  final int hearts;
  final int lessons;

  // 0 = peringkat belum diketahui
  final int rank;
  final int totalPlayers;

  const OverviewStatsCard({
    super.key,
    required this.xp,
    required this.streak,
    required this.bestStreak,
    required this.gems,
    required this.hearts,
    required this.lessons,
    required this.rank,
    required this.totalPlayers,
  });

  @override
  Widget build(BuildContext context) {
    final tiles = <_StatTile>[
      _StatTile(
        icon: 'assets/icons/streak.png',
        value: '$streak',
        label: 'Day streak',
        hint: 'Best $bestStreak',
      ),
      _StatTile(icon: 'assets/icons/xp.png', value: '$xp', label: 'Total XP'),
      _StatTile(icon: 'assets/icons/gems.png', value: '$gems', label: 'Gems'),
      _StatTile(
        icon: 'assets/icons/hearts.png',
        value: '$hearts',
        label: 'Hearts',
      ),
      _StatTile(
        icon: 'assets/icons/dumbell.png',
        value: '$lessons',
        label: 'Lessons',
      ),
      _StatTile(
        icon: 'assets/icons/bronze.png',
        value: rank > 0 ? '#$rank' : '-',
        label: 'Leaderboard',
        hint: totalPlayers > 0 ? 'of $totalPlayers' : null,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF20272B),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: GoogleFonts.baloo2(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          for (int row = 0; row < tiles.length; row += 2) ...[
            if (row > 0) const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: tiles[row]),
                const SizedBox(width: 10),
                Expanded(child: tiles[row + 1]),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final String? hint;

  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF38474C), width: 2),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            height: 34,
            child: Image.asset(icon, fit: BoxFit.contain),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.baloo2(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.05,
                        ),
                      ),
                    ),
                    if (hint != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        hint!,
                        maxLines: 1,
                        style: GoogleFonts.baloo2(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.pixelifySans(
                    color: Colors.white54,
                    fontSize: 12,
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
