import '../models/user.dart';

class FollowService {
  static void toggleFollow(UserModel user) {
    if (user.isFollowing) {
      user.isFollowing = false;
      user.followers--;
    } else {
      user.isFollowing = true;
      user.followers++;
    }
  }
}
