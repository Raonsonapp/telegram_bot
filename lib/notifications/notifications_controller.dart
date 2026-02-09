import 'package:flutter/foundation.dart';

import '../models/notification_model.dart';
import 'notifications_repository.dart';

class NotificationsController extends ChangeNotifier {
  NotificationsController(this._repository) {
    load();
  }

  final NotificationsRepository _repository;
  List<NotificationModel> items = [];

  Future<void> load() async {
    try {
      final response = await _repository.notifications();
      items = response
          .map((item) => NotificationModel.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      items = [
        NotificationModel(
          id: '1',
          title: 'New follower',
          description: 'mariam followed you',
        ),
      ];
    }
    notifyListeners();
  }
}
