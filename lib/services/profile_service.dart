import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_service.dart';
import 'auth_session.dart';

// Data profil user yang sedang login (dari tabel users di backend).
class UserProfile {
  final int id;
  final String fullname;
  final String username;
  final String email;
  final String learningLanguage;
  final String? avatarCharacter;
  final DateTime? joinedAt;
  final int followingCount;
  final int followersCount;
  final bool hasFollowed;
  final bool hasLiked;

  const UserProfile({
    required this.id,
    required this.fullname,
    required this.username,
    required this.email,
    required this.learningLanguage,
    required this.avatarCharacter,
    required this.joinedAt,
    required this.followingCount,
    required this.followersCount,
    required this.hasFollowed,
    required this.hasLiked,
  });

  int get stepsDone => (hasFollowed ? 1 : 0) + (hasLiked ? 1 : 0);
  int get stepsLeft => 2 - stepsDone;
  bool get isComplete => stepsLeft == 0;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final steps = (json['profile_steps'] as List?) ?? [];
    bool done(String key) =>
        steps.any((s) => s['key'] == key && s['done'] == true);

    return UserProfile(
      id: (json['id'] as num).toInt(),
      fullname: (json['fullname'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      learningLanguage: (json['learning_language'] ?? 'English').toString(),
      avatarCharacter: json['avatar_character'] as String?,
      joinedAt: DateTime.tryParse((json['joined_at'] ?? '').toString())
          ?.toLocal(),
      followingCount: (json['following_count'] as num?)?.toInt() ?? 0,
      followersCount: (json['followers_count'] as num?)?.toInt() ?? 0,
      hasFollowed: done('follow'),
      hasLiked: done('like'),
    );
  }
}

// User lain (publik): hasil pencarian, daftar following/followers, dan popup profil.
class FriendUser {
  final int id;
  final String fullname;
  final String username;
  final String learningLanguage;
  final String? avatarCharacter;
  final DateTime? joinedAt;
  final int followingCount;
  final int followersCount;
  final int likeCount;
  final bool isFollowing;
  final bool liked;

  const FriendUser({
    required this.id,
    required this.fullname,
    required this.username,
    required this.learningLanguage,
    this.avatarCharacter,
    this.joinedAt,
    this.followingCount = 0,
    this.followersCount = 0,
    this.likeCount = 0,
    this.isFollowing = false,
    this.liked = false,
  });

  FriendUser copyWith({
    int? followersCount,
    int? likeCount,
    bool? isFollowing,
    bool? liked,
  }) => FriendUser(
    id: id,
    fullname: fullname,
    username: username,
    learningLanguage: learningLanguage,
    avatarCharacter: avatarCharacter,
    joinedAt: joinedAt,
    followingCount: followingCount,
    followersCount: followersCount ?? this.followersCount,
    likeCount: likeCount ?? this.likeCount,
    isFollowing: isFollowing ?? this.isFollowing,
    liked: liked ?? this.liked,
  );

  factory FriendUser.fromJson(Map<String, dynamic> json) => FriendUser(
    id: (json['id'] as num).toInt(),
    fullname: (json['fullname'] ?? '').toString(),
    username: (json['username'] ?? '').toString(),
    learningLanguage: (json['learning_language'] ?? 'English').toString(),
    avatarCharacter: json['avatar_character'] as String?,
    joinedAt: DateTime.tryParse((json['joined_at'] ?? '').toString())
        ?.toLocal(),
    followingCount: (json['following_count'] as num?)?.toInt() ?? 0,
    followersCount: (json['followers_count'] as num?)?.toInt() ?? 0,
    likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
    isFollowing: json['is_following'] == true,
    liked: json['liked'] == true,
  );
}

class CommunityPost {
  final int id;
  final String body;
  final String authorName;
  final String authorUsername;
  final String learningLanguage;
  final int likeCount;
  final bool liked;

  const CommunityPost({
    required this.id,
    required this.body,
    required this.authorName,
    required this.authorUsername,
    required this.learningLanguage,
    required this.likeCount,
    required this.liked,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) => CommunityPost(
    id: (json['id'] as num).toInt(),
    body: (json['body'] ?? '').toString(),
    authorName: (json['author_name'] ?? '').toString(),
    authorUsername: (json['author_username'] ?? '').toString(),
    learningLanguage: (json['learning_language'] ?? 'English').toString(),
    likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
    liked: json['liked'] == true,
  );
}

class ProfileService {
  ProfileService._();

  static Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Authorization': 'Bearer ${AuthSession.instance.token}',
  };

  static Future<Map<String, dynamic>> _get(String path) async {
    await AuthSession.instance.load();
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}$path'),
      headers: _headers,
    );
    return _decode(response);
  }

  static Future<Map<String, dynamic>> _post(
    String path, [
    Map<String, dynamic>? body,
  ]) => _send('POST', path, body);

  static Future<Map<String, dynamic>> _send(
    String method,
    String path, [
    Map<String, dynamic>? body,
  ]) async {
    await AuthSession.instance.load();
    final request = http.Request(
      method,
      Uri.parse('${ApiService.baseUrl}$path'),
    )..headers.addAll(_headers);
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }
    final response = await http.Response.fromStream(await request.send());
    return _decode(response);
  }

  static Map<String, dynamic> _decode(http.Response response) {
    Object? body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {}

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        body is Map<String, dynamic>) {
      return body;
    }

    if (response.statusCode == 401) {
      throw Exception('Sesi login berakhir. Silakan login lagi.');
    }
    final message = body is Map ? body['message'] : null;
    throw Exception(
      message?.toString() ?? 'Terjadi kesalahan (${response.statusCode}).',
    );
  }

  static Future<UserProfile> getProfile() async {
    final body = await _get('/profile');
    return UserProfile.fromJson(body['data'] as Map<String, dynamic>);
  }

  static Future<void> setAvatar(String key) async {
    await _send('PUT', '/profile/avatar', {'avatar_character': key});
  }

  static List<FriendUser> _users(Map<String, dynamic> body) =>
      ((body['data'] as List?) ?? [])
          .map((e) => FriendUser.fromJson(e as Map<String, dynamic>))
          .toList();

  // Tanpa [query]: saran user. Dengan [query]: user yang cocok.
  static Future<List<FriendUser>> searchUsers([String query = '']) async =>
      _users(await _get('/users/search?q=${Uri.encodeQueryComponent(query)}'));

  static Future<FriendUser> getUser(int id) async {
    final body = await _get('/users/$id');
    return FriendUser.fromJson(body['data'] as Map<String, dynamic>);
  }

  static Future<List<FriendUser>> getFollowing() async =>
      _users(await _get('/profile/following'));

  static Future<List<FriendUser>> getFollowers() async =>
      _users(await _get('/profile/followers'));

  static Future<List<FriendUser>> getBlocked() async =>
      _users(await _get('/profile/blocked'));

  // Mengembalikan data user yang sudah diperbarui (jumlah like dan status).
  static Future<FriendUser> toggleUserLike(int userId) async {
    final body = await _post('/users/$userId/like');
    return FriendUser.fromJson(body['data'] as Map<String, dynamic>);
  }

  // Mengembalikan true kalau sekarang diblokir.
  static Future<bool> toggleBlock(int userId) async {
    final body = await _post('/users/$userId/block');
    return body['blocked'] == true;
  }

  static Future<void> reportUser(int userId, String reason) async {
    await _post('/users/$userId/report', {'reason': reason});
  }

  static Future<void> setLanguage(String language) async {
    await _send('PATCH', '/profile/language', {'learning_language': language});
  }

  // Mencabut token di server. Kegagalan jaringan tidak menghalangi sign out.
  static Future<void> signOutOnServer() async {
    try {
      await _post('/logout');
    } catch (_) {}
  }

  static Future<List<CommunityPost>> getPosts() async {
    final body = await _get('/posts');
    return ((body['data'] as List?) ?? [])
        .map((e) => CommunityPost.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Mengembalikan true kalau sekarang mengikuti.
  static Future<bool> toggleFollow(int userId) async {
    final body = await _post('/users/$userId/follow');
    return body['is_following'] == true;
  }

  // Mengembalikan true kalau sekarang disukai.
  static Future<bool> toggleLike(int postId) async {
    final body = await _post('/posts/$postId/like');
    return body['liked'] == true;
  }
}
