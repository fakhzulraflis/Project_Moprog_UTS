import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/league.dart';

class LeagueJourneyPage extends StatelessWidget {
  final League currentLeague;
  final int currentRank;
  final int totalUsers;

  const LeagueJourneyPage({
    super.key,
    required this.currentLeague,
    required this.currentRank,
    required this.totalUsers,
  });

  String _shortLeagueName(League league) {
    return league.name.replaceAll(' League', '');
  }

  String _seasonRemaining() {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final daysUntilNextMonday = now.weekday == DateTime.monday
        ? 7
        : DateTime.monday - now.weekday + 7;
    final nextMonday = startOfToday.add(
      Duration(days: daysUntilNextMonday),
    );
    final remaining = nextMonday.difference(now);

    final days = remaining.inDays;
    final hours = remaining.inHours.remainder(24);
    final minutes = remaining.inMinutes.remainder(60);

    if (days > 0) {
      return '$days hari $hours jam';
    }

    if (hours > 0) {
      return '$hours jam $minutes menit';
    }

    return '$minutes menit';
  }

  String _promotionText() {
    final nextLeague = currentLeague.nextLeague;

    if (nextLeague == null) {
      return 'Kamu sudah berada di liga tertinggi.';
    }

    return 'Top ${currentLeague.promotionZoneSize} naik ke '
        '${nextLeague.name}';
  }

  String? _demotionText() {
    if (currentLeague.demotionZoneSize == 0 ||
        currentLeague.previousLeague == null) {
      return null;
    }

    return '${currentLeague.demotionZoneSize} posisi terbawah turun ke '
        '${currentLeague.previousLeague!.name}';
  }

  @override
  Widget build(BuildContext context) {
    final demotionText = _demotionText();

    return Scaffold(
      backgroundColor: const Color(0xFF272F33),
      appBar: AppBar(
        backgroundColor: const Color(0xFF272F33),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
          ),
        ),
        title: Text(
          'Liga Kamu',
          style: GoogleFonts.baloo2(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          _CurrentLeagueCard(
            league: currentLeague,
            currentRank: currentRank,
            totalUsers: totalUsers,
          ),
          const SizedBox(height: 20),
          Text(
            'Perjalanan Liga',
            style: GoogleFonts.baloo2(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF20272B),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
            child: Column(
              children: [
                for (
                  var index = 0;
                  index < League.all.length;
                  index++
                ) ...[
                  _LeagueJourneyTile(
                    league: League.all[index],
                    currentLeague: currentLeague,
                    shortName: _shortLeagueName(
                      League.all[index],
                    ),
                  ),
                  if (index != League.all.length - 1)
                    Divider(
                      height: 1,
                      indent: 68,
                      color: Colors.white.withValues(
                        alpha: 0.06,
                      ),
                    ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          _InfoCard(
            icon: Icons.arrow_upward_rounded,
            color: const Color(0xFF58CC02),
            text: _promotionText(),
          ),
          if (demotionText != null) ...[
            const SizedBox(height: 10),
            _InfoCard(
              icon: Icons.arrow_downward_rounded,
              color: const Color(0xFFFF4B4B),
              text: demotionText,
            ),
          ],
          const SizedBox(height: 10),
          _InfoCard(
            icon: Icons.schedule_rounded,
            color: const Color(0xFF1CB0F6),
            text: 'Sisa musim: ${_seasonRemaining()}',
          ),
        ],
      ),
    );
  }
}

class _CurrentLeagueCard extends StatelessWidget {
  final League league;
  final int currentRank;
  final int totalUsers;

  const _CurrentLeagueCard({
    required this.league,
    required this.currentRank,
    required this.totalUsers,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF20272B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: league.color.withValues(alpha: 0.45),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 76,
            height: 76,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: league.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              league.iconAsset,
            ),
          ),
          const SizedBox(width: 16),
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
                const SizedBox(height: 4),
                Text(
                  currentRank > 0
                      ? 'Posisi kamu: #$currentRank dari '
                          '$totalUsers pemain'
                      : 'Posisi kamu belum tersedia',
                  style: GoogleFonts.nunito(
                    color: Colors.white.withValues(
                      alpha: 0.7,
                    ),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
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

class _LeagueJourneyTile extends StatelessWidget {
  final League league;
  final League currentLeague;
  final String shortName;

  const _LeagueJourneyTile({
    required this.league,
    required this.currentLeague,
    required this.shortName,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = league.tier < currentLeague.tier;
    final isCurrent = league.tier == currentLeague.tier;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      color: isCurrent
          ? league.color.withValues(alpha: 0.08)
          : Colors.transparent,
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: isCompleted
                ? const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF58CC02),
                    size: 22,
                  )
                : isCurrent
                    ? Icon(
                        Icons.arrow_forward_rounded,
                        color: league.color,
                        size: 24,
                      )
                    : Icon(
                        Icons.radio_button_unchecked_rounded,
                        color: Colors.white.withValues(
                          alpha: 0.22,
                        ),
                        size: 20,
                      ),
          ),
          const SizedBox(width: 8),
          Image.asset(
            league.iconAsset,
            height: 34,
            width: 34,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              shortName,
              style: GoogleFonts.nunito(
                color: isCurrent
                    ? Colors.white
                    : Colors.white.withValues(
                        alpha: isCompleted ? 0.75 : 0.5,
                      ),
                fontSize: 15,
                fontWeight: isCurrent
                    ? FontWeight.w900
                    : FontWeight.w700,
              ),
            ),
          ),
          if (isCurrent)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: league.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Saat ini',
                style: GoogleFonts.nunito(
                  color: league.color,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _InfoCard({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF20272B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.nunito(
                color: Colors.white.withValues(
                  alpha: 0.82,
                ),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
