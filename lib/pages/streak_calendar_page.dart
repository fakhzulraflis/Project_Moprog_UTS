import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/player_progress.dart';

/// Full monthly calendar view of the user's study streak.
///
/// Complements the compact streak card on the Quests tab
/// (`buildStreakCard()` in quests_page.dart) by showing exactly which
/// days were studied, not just the running total. Reads real data from
/// [PlayerProgress.studiedDays] — nothing here is dummy/mock.
class StreakCalendarPage extends StatefulWidget {
  const StreakCalendarPage({super.key});

  @override
  State<StreakCalendarPage> createState() => _StreakCalendarPageState();
}

class _StreakCalendarPageState extends State<StreakCalendarPage> {
  final progress = PlayerProgress.instance;
  late DateTime _visibleMonth;

  static const monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];
  static const dayLabels = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];

  @override
  void initState() {
    super.initState();
    progress.load();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
  }

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF272F33),
      appBar: AppBar(
        backgroundColor: const Color(0xFF272F33),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Streak Calendar',
          style: GoogleFonts.baloo2(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: progress,
          builder: (context, _) {
            if (!progress.isLoaded) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF9600)),
              );
            }
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildSummary(),
                const SizedBox(height: 24),
                _buildMonthHeader(),
                const SizedBox(height: 12),
                _buildWeekdayLabels(),
                const SizedBox(height: 6),
                _buildCalendarGrid(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return Row(
      children: [
        Image.asset('assets/icons/streak.png', height: 44),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${progress.streak} day streak',
              style: GoogleFonts.baloo2(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Best: ${progress.bestStreak} · Target: ${progress.streakGoal} hari',
              style: GoogleFonts.nunito(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMonthHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => _changeMonth(-1),
          icon: const Icon(Icons.chevron_left_rounded, color: Colors.white),
        ),
        Text(
          '${monthNames[_visibleMonth.month - 1]} ${_visibleMonth.year}',
          style: GoogleFonts.baloo2(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          onPressed: () => _changeMonth(1),
          icon: const Icon(Icons.chevron_right_rounded, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildWeekdayLabels() {
    return Row(
      children: dayLabels
          .map((d) => Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: GoogleFonts.nunito(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final firstOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final daysInMonth =
        DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    // Monday = 1 ... Sunday = 7 in DateTime.weekday; grid starts on Monday.
    final leadingBlanks = firstOfMonth.weekday - 1;
    final today = DateTime.now();

    final cells = <Widget>[];
    for (var i = 0; i < leadingBlanks; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_visibleMonth.year, _visibleMonth.month, day);
      final key = PlayerProgress.dayKey(date);
      final studied = progress.studiedDays.contains(key);
      final isToday = PlayerProgress.dayKey(today) == key;
      final isFuture = date.isAfter(today);

      cells.add(_DayCell(day: day, studied: studied, isToday: isToday, isFuture: isFuture));
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      children: cells,
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final bool studied;
  final bool isToday;
  final bool isFuture;

  const _DayCell({
    required this.day,
    required this.studied,
    required this.isToday,
    required this.isFuture,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: studied
            ? const Color(0xFFFF9600).withValues(alpha: 0.18)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: isToday
            ? Border.all(color: const Color(0xFFFF9600), width: 2)
            : null,
      ),
      alignment: Alignment.center,
      child: studied
          ? Image.asset('assets/icons/streak.png', height: 16)
          : Text(
              '$day',
              style: GoogleFonts.nunito(
                color: Colors.white.withValues(alpha: isFuture ? 0.2 : 0.4),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}
