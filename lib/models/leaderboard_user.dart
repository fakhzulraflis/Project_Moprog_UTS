/// Represents a single row in the weekly leaderboard.
///
/// Kept intentionally simple and decoupled from any backend so it can be
/// built either from local dummy data (now) or from an API/Firestore/SQL
/// response later without touching the UI layer.
class LeaderboardUser {
  final String id;
  final int rank;
  final String name;
  final int xp;
  final bool isMe;
  final String? avatarUrl; // null while we don't have real avatars yet

  const LeaderboardUser({
    required this.id,
    required this.rank,
    required this.name,
    required this.xp,
    this.isMe = false,
    this.avatarUrl,
  });

  /// Build from a JSON map, e.g. once a REST API or Firestore doc is wired
  /// up. `currentUserId` is passed in separately so the service/repository
  /// decides who "isMe" is, rather than trusting the payload blindly.
  factory LeaderboardUser.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    final id = json['id'] as String;
    return LeaderboardUser(
      id: id,
      rank: json['rank'] as int,
      name: json['name'] as String,
      xp: json['xp'] as int,
      isMe: currentUserId != null && currentUserId == id,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'rank': rank,
        'name': name,
        'xp': xp,
        'avatarUrl': avatarUrl,
      };

  LeaderboardUser copyWith({
    String? id,
    int? rank,
    String? name,
    int? xp,
    bool? isMe,
    String? avatarUrl,
  }) {
    return LeaderboardUser(
      id: id ?? this.id,
      rank: rank ?? this.rank,
      name: name ?? this.name,
      xp: xp ?? this.xp,
      isMe: isMe ?? this.isMe,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
