/// lib/services/user_service.dart
/// =====================================================
/// USER SERVICE – FINAL v5
/// Handles:
/// - Get user profile
/// - Edit profile
/// - Follow / Unfollow
/// - Followers / Following
/// =====================================================

import '../core/api.dart';
import '../core/http_service.dart';
import '../models/user.dart';

class UserService {
  // =====================================================
  // GET USER PROFILE
  // =====================================================

  static Future<User> getProfile(String username) async {
    final res = await HttpService.get(
      '${Api.userProfile}/$username',
      auth: true,
    );

    return User.fromJson(res);
  }

  // =====================================================
  // EDIT PROFILE
  // =====================================================

  static Future<User> editProfile({
    required String username,
    String? bio,
    String? avatarUrl,
  }) async {
    final res = await HttpService.put(
      Api.editProfile,
      body: {
        'username': username,
        if (bio != null) 'bio': bio,
        if (avatarUrl != null) 'avatar': avatarUrl,
      },
      auth: true,
    );

    return User.fromJson(res);
  }

  // =====================================================
  // FOLLOW USER
  // =====================================================

  static Future<void> follow(String username) async {
    await HttpService.post(
      '${Api.follow}/$username',
      body: {},
      auth: true,
    );
  }

  // =====================================================
  // UNFOLLOW USER
  // =====================================================

  static Future<void> unfollow(String username) async {
    await HttpService.post(
      '${Api.unfollow}/$username',
      body: {},
      auth: true,
    );
  }

  // =====================================================
  // GET FOLLOWERS
  // =====================================================

  static Future<List<User>> getFollowers(String username) async {
    final res = await HttpService.get(
      '${Api.followers}/$username',
      auth: true,
    );

    return (res as List)
        .map((e) => User.fromJson(e))
        .toList();
  }

  // =====================================================
  // GET FOLLOWING
  // =====================================================

  static Future<List<User>> getFollowing(String username) async {
    final res = await HttpService.get(
      '${Api.following}/$username',
      auth: true,
    );

    return (res as List)
        .map((e) => User.fromJson(e))
        .toList();
  }
}
