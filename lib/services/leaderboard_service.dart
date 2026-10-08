import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_service.dart';
import 'auth_session.dart';
import '../models/leaderboard_user.dart';
import '../models/league.dart';

abstract class LeaderboardService {
  static LeaderboardService instance = ApiLeaderboardService();
  Future<League> getCurrentLeague();
  Future<List<LeaderboardUser>> getWeeklyLeaderboard();
}

// ambil leaderboard dari GET /api/leaderboard.
class ApiLeaderboardService implements LeaderboardService {
  @override
  Future<League> getCurrentLeague() async {
    final myXp = await _fetchMyXp();
    return _leagueForXp(myXp);
  }

  @override
  Future<List<LeaderboardUser>> getWeeklyLeaderboard() async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/leaderboard'),
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal memuat leaderboard (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body);
    final List<dynamic> rows = decoded['data'] as List<dynamic>;
    final myId = AuthSession.instance.userId?.toString();

    return rows
        .map(
          (row) => LeaderboardUser.fromJson(
            row as Map<String, dynamic>,
            currentUserId: myId,
          ),
        )
        .toList();
  }

  Future<int> _fetchMyXp() async {
    final myId = AuthSession.instance.userId?.toString();
    if (myId == null) return 0;

    final users = await getWeeklyLeaderboard();
    final me = users.where((u) => u.id == myId).toList();
    return me.isEmpty ? 0 : me.first.xp;
  }

  static League _leagueForXp(int xp) {
    if (xp >= 4000) return League.amethyst;
    if (xp >= 2000) return League.emerald;
    if (xp >= 1000) return League.ruby;
    if (xp >= 500) return League.sapphire;
    if (xp >= 250) return League.gold;
    if (xp >= 100) return League.silver;
    return League.bronze;
  }
}

class DummyLeaderboardService implements LeaderboardService {
  static const _currentUserId = 'u7';
  static const _currentLeague = League.bronze;

  static final List<Map<String, dynamic>> _rawUsers = [
    {'id': 'u1', 'rank': 1, 'name': 'Aditya', 'xp': 420},
    {'id': 'u2', 'rank': 2, 'name': 'Bunga', 'xp': 388},
    {'id': 'u3', 'rank': 3, 'name': 'Citra', 'xp': 356},
    {'id': 'u7', 'rank': 7, 'name': 'Saya', 'xp': 240},
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
        .map(
          (json) =>
              LeaderboardUser.fromJson(json, currentUserId: _currentUserId),
        )
        .toList()
      ..sort((a, b) => a.rank.compareTo(b.rank));
  }
}
