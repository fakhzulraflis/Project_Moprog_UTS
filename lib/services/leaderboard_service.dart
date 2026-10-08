import '../models/leaderboard_user.dart';
import '../models/league.dart';
import 'api_service.dart';

abstract class LeaderboardService {
  static LeaderboardService instance =
      _ApiLeaderboardService();

  Future<League> getCurrentLeague();

  Future<List<LeaderboardUser>> getWeeklyLeaderboard();
}

class _ApiLeaderboardService
    implements LeaderboardService {
  static const League _currentLeague =
      League.bronze;

  @override
  Future<League> getCurrentLeague() async {
    return _currentLeague;
  }

  @override
  Future<List<LeaderboardUser>>
      getWeeklyLeaderboard() async {
    final data =
        await ApiService.getLeaderboard();

    return data
        .map(
          (json) => LeaderboardUser.fromJson(
            json,
          ),
        )
        .toList()
      ..sort(
        (a, b) => a.rank.compareTo(b.rank),
      );
  }
}
