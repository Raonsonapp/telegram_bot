import 'package:flutter/foundation.dart';

import '../../models/story_model.dart';

class StoryController extends ChangeNotifier {
  StoryController() {
    stories = [
      StoryModel(id: '1', username: 'You', imageUrl: '', isLive: true),
      StoryModel(id: '2', username: 'Ardamehr', imageUrl: ''),
      StoryModel(id: '3', username: 'Mehrat', imageUrl: ''),
      StoryModel(id: '4', username: 'Qulbiddin', imageUrl: ''),
      StoryModel(id: '5', username: 'Mariam', imageUrl: ''),
    ];
  }

  List<StoryModel> stories = [];
}
