import 'package:flutter/foundation.dart';

import '../../models/reel_model.dart';
import '../reels_repository.dart';
import 'reels_state.dart';

class ReelsController extends ChangeNotifier {
  ReelsController(this._repository)
      : _state = ReelsState(reels: const [], loading: true) {
    load();
  }

  final ReelsRepository _repository;
  ReelsState _state;

  ReelsState get state => _state;

  Future<void> load() async {
    try {
      _state = ReelsState(reels: const [], loading: true);
      notifyListeners();
      final response = await _repository.reels();
      _state = ReelsState(
        reels: response
            .map((item) => ReelModel.fromMap(item as Map<String, dynamic>))
            .toList(),
        loading: false,
      );
    } catch (_) {
      _state = ReelsState(reels: _fallbackReels(), loading: false);
    }
    notifyListeners();
  }

  List<ReelModel> _fallbackReels() {
    return [
      ReelModel(
        id: '1',
        username: 'olivia_martin',
        caption: 'Sunset vibes ✨ #beachlife',
        videoUrl: '',
        likes: 1200000,
        comments: 56300,
      ),
    ];
  }
}
