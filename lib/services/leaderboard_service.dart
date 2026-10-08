import '../models/leaderboard_user.dart';
import '../models/league.dart';
import 'api_service.dart';
import 'auth_session.dart';

abstract class LeaderboardService {
  static LeaderboardService instance = _ApiLeaderboardService();

  Future<League> getCurrentLeague();

  // Semua pemain, dari XP tertinggi ke terendah.
  Future<List<LeaderboardUser>> getLeaderboard();
}

class _ApiLeaderboardService implements LeaderboardService {
  static const League _currentLeague = League.bronze;

  @override
  Future<League> getCurrentLeague() async {
    return _currentLeague;
  }

  @override
  Future<List<LeaderboardUser>> getLeaderboard() async {
    await AuthSession.instance.load();

    final data = await ApiService.getLeaderboard();
    final me = AuthSession.instance.userId?.toString();

    final users = data
        .map((json) => LeaderboardUser.fromJson(json, currentUserId: me))
        .toList();

    // Server sudah mengurutkan; ini hanya memastikan urutannya benar.
    users.sort((a, b) => a.rank.compareTo(b.rank));

    return users;
  }
}
