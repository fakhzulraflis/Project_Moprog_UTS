class LeaderboardUser {
  final String id;
  final int rank;
  final String name;
  final int xp;
  final bool isMe;
  final String? avatarUrl;

  const LeaderboardUser({
    required this.id,
    required this.rank,
    required this.name,
    required this.xp,
    this.isMe = false,
    this.avatarUrl,
  });

  factory LeaderboardUser.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    final id = json['id'].toString();
    return LeaderboardUser(
      id: id,
      rank: (json['rank'] as num).toInt(),
      name: json['name'] as String,
      xp: (json['xp'] as num).toInt(),
      isMe: currentUserId != null && currentUserId == id,
      avatarUrl: (json['avatarUrl'] ?? json['avatar_url']) as String?,
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
