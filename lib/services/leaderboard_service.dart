import '../models/leaderboard_user.dart';
import '../models/league.dart';

/// Data source contract for the leaderboard feature.
///
/// The UI (LeaderboardPage) only ever talks to this abstract class, never
/// to a concrete implementation. Swap `LeaderboardService.instance` below
/// to point at a real API/Firestore/SQL implementation later and nothing
/// in lib/tabs/leaderboard_page.dart needs to change.
abstract class LeaderboardService {
  /// Currently backed by [_DummyLeaderboardService]. Once a real backend
  /// exists, replace this with e.g. `ApiLeaderboardService()` or
  /// `FirestoreLeaderboardService()`.
  static LeaderboardService instance = _DummyLeaderboardService();

  /// Returns the league the current user is in.
  Future<League> getCurrentLeague();

  /// Returns this week's leaderboard, sorted by rank ascending (1 = top).
  Future<List<LeaderboardUser>> getWeeklyLeaderboard();
}

/// Placeholder implementation using in-memory fake data.
///
/// Mimics network latency with a short delay and returns data already
/// shaped exactly like [LeaderboardUser.fromJson] would, so replacing this
/// class with a real HTTP/Firestore call later is a drop-in swap.
class _DummyLeaderboardService implements LeaderboardService {
  static const _currentUserId = 'u7';

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
    {'id': 'u11', 'rank': 11, 'name': 'Joko', 'xp': 140},
    {'id': 'u12', 'rank': 12, 'name': 'Kirana', 'xp': 120},
    {'id': 'u13', 'rank': 13, 'name': 'Lestari', 'xp': 95},
    {'id': 'u14', 'rank': 14, 'name': 'Made', 'xp': 60},
    {'id': 'u15', 'rank': 15, 'name': 'Nadia', 'xp': 30},
  ];

  @override
  Future<League> getCurrentLeague() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return League.silver;
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
