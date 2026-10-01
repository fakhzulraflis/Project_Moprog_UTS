import '../models/leaderboard_user.dart';
import '../models/league.dart';

abstract class LeaderboardService {
  static LeaderboardService instance = _DummyLeaderboardService();
  Future<League> getCurrentLeague();
  Future<List<LeaderboardUser>> getWeeklyLeaderboard();
}

class _DummyLeaderboardService implements LeaderboardService {
  static const _currentUserId = 'u7';
  static const _currentLeague = League.bronze;

  static final List<Map<String, dynamic>> _rawUsers = [
    {'id': 'u1', 'rank': 1, 'name': 'Aditya', 'xp': 420},
    {'id': 'u2', 'rank': 2, 'name': 'Bunga', 'xp': 388},
    {'id': 'u3', 'rank': 3, 'name': 'Citra', 'xp': 356},
    {'id': 'u4', 'rank': 4, 'name': 'Dimas', 'xp': 310},
    {'id': 'u5', 'rank': 5, 'name': 'Eka', 'xp': 295},
    {'id': 'u6', 'rank': 6, 'name': 'Fajar', 'xp': 270},
    {'id': 'u7', 'rank': 7, 'name': 'Kamu', 'xp': 240},
    {'id': 'u8', 'rank': 8, 'name': 'Gita', 'xp': 210},
    {'id': 'u9', 'rank': 9, 'name': 'Hadi', 'xp': 190},
    {'id': 'u10', 'rank': 10, 'name': 'Indah', 'xp': 175},
    {'id': 'u11', 'rank': 11, 'name': 'Joko', 'xp': 160},
    {'id': 'u12', 'rank': 12, 'name': 'Kirana', 'xp': 150},
    {'id': 'u13', 'rank': 13, 'name': 'Lestari', 'xp': 140},
    {'id': 'u14', 'rank': 14, 'name': 'Made', 'xp': 130},
    {'id': 'u15', 'rank': 15, 'name': 'Nadia', 'xp': 120},
    {'id': 'u16', 'rank': 16, 'name': 'Oscar', 'xp': 110},
    {'id': 'u17', 'rank': 17, 'name': 'Putri', 'xp': 100},
    {'id': 'u18', 'rank': 18, 'name': 'Qori', 'xp': 92},
    {'id': 'u19', 'rank': 19, 'name': 'Rizky', 'xp': 85},
    {'id': 'u20', 'rank': 20, 'name': 'Sari', 'xp': 78},
    {'id': 'u21', 'rank': 21, 'name': 'Tono', 'xp': 70},
    {'id': 'u22', 'rank': 22, 'name': 'Umar', 'xp': 62},
    {'id': 'u23', 'rank': 23, 'name': 'Vina', 'xp': 55},
    {'id': 'u24', 'rank': 24, 'name': 'Wawan', 'xp': 48},
    {'id': 'u25', 'rank': 25, 'name': 'Xena', 'xp': 40},
    {'id': 'u26', 'rank': 26, 'name': 'Yudi', 'xp': 33},
    {'id': 'u27', 'rank': 27, 'name': 'Zahra', 'xp': 26},
    {'id': 'u28', 'rank': 28, 'name': 'Andi', 'xp': 20},
    {'id': 'u29', 'rank': 29, 'name': 'Bagas', 'xp': 14},
    {'id': 'u30', 'rank': 30, 'name': 'Cindy', 'xp': 8},
  ];

  @override
  Future<League> getCurrentLeague() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _currentLeague;
  }

  @override
  Future<List<LeaderboardUser>> getWeeklyLeaderboard() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _rawUsers
        .map((json) => LeaderboardUser.fromJson(
              json,
              currentUserId: _currentUserId,
            ))
        .toList()
      ..sort((a, b) => a.rank.compareTo(b.rank));
  }
}
