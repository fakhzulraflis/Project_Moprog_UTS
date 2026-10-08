class LeaderboardUser {
  final String id;
  final int rank;
  final String name; // nama lengkap
  final String username;
  final int xp;
  final bool isMe;
  final String? avatarCharacter;
  final String learningLanguage;

  const LeaderboardUser({
    required this.id,
    required this.rank,
    required this.name,
    required this.xp,
    this.username = '',
    this.isMe = false,
    this.avatarCharacter,
    this.learningLanguage = 'English',
  });

  // [currentUserId] dipakai sebagai cadangan kalau server tidak mengirim is_me.
  factory LeaderboardUser.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    final id = json['id'].toString();

    return LeaderboardUser(
      id: id,
      rank: (json['rank'] as num).toInt(),
      name: (json['name'] ?? json['username'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      isMe:
          json['is_me'] == true ||
          (currentUserId != null && currentUserId == id),
      avatarCharacter: json['avatar_character'] as String?,
      learningLanguage: (json['learning_language'] ?? 'English').toString(),
    );
  }

  int get userId => int.tryParse(id) ?? 0;

  LeaderboardUser copyWith({int? rank, int? xp, bool? isMe}) {
    return LeaderboardUser(
      id: id,
      rank: rank ?? this.rank,
      name: name,
      username: username,
      xp: xp ?? this.xp,
      isMe: isMe ?? this.isMe,
      avatarCharacter: avatarCharacter,
      learningLanguage: learningLanguage,
    );
  }
}
