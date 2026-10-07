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

class SuggestedUser {
  final int id;
  final String fullname;
  final String username;
  final String learningLanguage;
  final bool isFollowing;

  const SuggestedUser({
    required this.id,
    required this.fullname,
    required this.username,
    required this.learningLanguage,
    required this.isFollowing,
  });

  factory SuggestedUser.fromJson(Map<String, dynamic> json) => SuggestedUser(
    id: (json['id'] as num).toInt(),
    fullname: (json['fullname'] ?? '').toString(),
    username: (json['username'] ?? '').toString(),
    learningLanguage: (json['learning_language'] ?? 'English').toString(),
    isFollowing: json['is_following'] == true,
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

  static Future<Map<String, dynamic>> _post(String path) async {
    await AuthSession.instance.load();
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}$path'),
      headers: _headers,
    );
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
    await AuthSession.instance.load();
    final response = await http.put(
      Uri.parse('${ApiService.baseUrl}/profile/avatar'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode({'avatar_character': key}),
    );
    _decode(response);
  }

  static Future<List<SuggestedUser>> getSuggestions() async {
    final body = await _get('/profile/suggestions');
    return ((body['data'] as List?) ?? [])
        .map((e) => SuggestedUser.fromJson(e as Map<String, dynamic>))
        .toList();
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
