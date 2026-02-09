import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class NetworkChecker extends ChangeNotifier {
  NetworkChecker() {
    _subscription = _connectivity.onConnectivityChanged.listen(_update);
  }

  final Connectivity _connectivity = Connectivity();
  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  bool _online = true;
  bool get online => _online;

  Future<void> _update(List<ConnectivityResult> result) async {
    final isOnline = result.any((value) => value != ConnectivityResult.none);
    if (_online != isOnline) {
      _online = isOnline;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
