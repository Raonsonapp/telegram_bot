import 'package:flutter/foundation.dart';

import '../../core/error_handler.dart';
import '../../models/post_model.dart';
import '../home_repository.dart';
import 'feed_state.dart';

class FeedController extends ChangeNotifier {
  FeedController(this._repository)
      : _state = FeedState(posts: const [], loading: true) {
    load();
  }

  final HomeRepository _repository;
  FeedState _state;

  FeedState get state => _state;

  Future<void> load() async {
    try {
      _state = _state.copyWith(loading: true, error: null);
      notifyListeners();
      final response = await _repository.feed();
      final posts = response
          .map((item) => PostModel.fromMap(item as Map<String, dynamic>))
          .toList();
      _state = _state.copyWith(posts: posts, loading: false);
    } catch (error) {
      _state = _state.copyWith(
        loading: false,
        error: ErrorHandler.message(error),
        posts: _fallbackPosts(),
      );
    }
    notifyListeners();
  }

  List<PostModel> _fallbackPosts() {
    return [
      PostModel(
        id: '1',
        username: 'raonson.travel',
        caption: 'Шоми ором дар кӯҳҳо. Ҳар рӯзро бо илҳом оғоз мекунем ✨',
        imageUrl:
            'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee',
        likes: 14829,
      ),
      PostModel(
        id: '2',
        username: 'raonson.studio',
        caption: 'Эҷодиёти дастаи Raonson — ранги нав барои ҳар лоиҳа.',
        imageUrl:
            'https://images.unsplash.com/photo-1524504388940-b1c1722653e1',
        likes: 9203,
      ),
    ];
  }
}
