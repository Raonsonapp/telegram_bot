import 'package:flutter/foundation.dart';

import '../../models/user_model.dart';
import '../profile_repository.dart';
import 'profile_state.dart';

class ProfileController extends ChangeNotifier {
  ProfileController(this._repository)
      : _state = ProfileState(user: UserModel.empty()) {
    load();
  }

  final ProfileRepository _repository;
  ProfileState _state;

  ProfileState get state => _state;

  Future<void> load() async {
    try {
      final response = await _repository.profile();
      _state = ProfileState(user: UserModel.fromMap(response));
    } catch (_) {
      _state = ProfileState(user: _fallbackUser());
    }
    notifyListeners();
  }

  UserModel _fallbackUser() {
    return UserModel(
      id: '1',
      name: 'Olivia Martin',
      username: 'olivia_martin',
      bio: 'Sunny vibes & good times ✨🌴',
      avatarUrl:
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1',
      followers: 10400,
      following: 325,
      posts: 258,
    );
  }
}
