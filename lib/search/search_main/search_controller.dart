import 'package:flutter/foundation.dart';

import '../search_repository.dart';
import 'search_state.dart';

class SearchController extends ChangeNotifier {
  SearchController(this._repository)
      : _state = SearchState(items: const [], loading: false);

  final SearchRepository _repository;
  SearchState _state;

  SearchState get state => _state;

  Future<void> search(String query) async {
    _state = SearchState(items: _state.items, loading: true);
    notifyListeners();
    try {
      final response = await _repository.search(query);
      _state = SearchState(
        items: response.map((item) => item.toString()).toList(),
        loading: false,
      );
    } catch (_) {
      _state = SearchState(
        items: _fallbackItems(),
        loading: false,
      );
    }
    notifyListeners();
  }

  List<String> _fallbackItems() {
    return [
      'Travel',
      'Food',
      'Style',
      'Music',
      'Animals',
    ];
  }
}
