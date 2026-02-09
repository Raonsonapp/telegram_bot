import 'package:flutter/foundation.dart';

import '../../models/post_model.dart';

class PostController extends ChangeNotifier {
  PostController(this.post);

  final PostModel post;

  void toggleLike() {
    post.liked = !post.liked;
    if (post.liked) {
      post.likes += 1;
    } else {
      post.likes = post.likes > 0 ? post.likes - 1 : 0;
    }
    notifyListeners();
  }

  void toggleSave() {
    post.saved = !post.saved;
    notifyListeners();
  }
}
