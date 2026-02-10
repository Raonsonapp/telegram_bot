import 'dart:async';

/// =====================================================
/// PaginationHelper – FINAL
/// -----------------------------------------------------
/// Generic helper for paginated lists:
/// - cursor / page based
/// - loading state
/// - hasMore control
/// - pull-to-refresh support
/// - safe concurrent calls
/// =====================================================

typedef PageFetcher<T> = Future<PageResult<T>> Function({
  required int page,
  required int limit,
});

class PageResult<T> {
  final List<T> items;
  final bool hasMore;

  const PageResult({
    required this.items,
    required this.hasMore,
  });
}

class PaginationHelper<T> {
  // ================= CONFIG =================
  final int limit;
  final PageFetcher<T> fetcher;

  // ================= STATE =================
  int _page = 1;
  bool _hasMore = true;
  bool _loading = false;

  final List<T> _items = [];

  // ================= STREAM =================
  final StreamController<List<T>> _controller =
      StreamController<List<T>>.broadcast();

  // =====================================================
  // CONSTRUCTOR
  // =====================================================
  PaginationHelper({
    required this.fetcher,
    this.limit = 20,
  });

  // =====================================================
  // GETTERS
  // =====================================================
  List<T> get items => List.unmodifiable(_items);
  bool get isLoading => _loading;
  bool get hasMore => _hasMore;
  int get page => _page;

  Stream<List<T>> get stream => _controller.stream;

  // =====================================================
  // LOAD FIRST PAGE / REFRESH
  // =====================================================
  Future<void> refresh() async {
    if (_loading) return;

    _page = 1;
    _hasMore = true;
    _items.clear();

    await _loadInternal(reset: true);
  }

  // =====================================================
  // LOAD NEXT PAGE
  // =====================================================
  Future<void> loadMore() async {
    if (_loading || !_hasMore) return;
    await _loadInternal();
  }

  // =====================================================
  // INTERNAL LOADER
  // =====================================================
  Future<void> _loadInternal({bool reset = false}) async {
    _loading = true;

    try {
      final result = await fetcher(
        page: _page,
        limit: limit,
      );

      if (reset) {
        _items.clear();
      }

      _items.addAll(result.items);
      _hasMore = result.hasMore;

      if (_hasMore) {
        _page += 1;
      }

      _controller.add(List.unmodifiable(_items));
    } catch (e) {
      // keep previous state, just emit current items
      _controller.add(List.unmodifiable(_items));
    } finally {
      _loading = false;
    }
  }

  // =====================================================
  // MANUAL ADD / REMOVE (optimistic UI)
  // =====================================================
  void prepend(T item) {
    _items.insert(0, item);
    _controller.add(List.unmodifiable(_items));
  }

  void append(T item) {
    _items.add(item);
    _controller.add(List.unmodifiable(_items));
  }

  void removeWhere(bool Function(T) test) {
    _items.removeWhere(test);
    _controller.add(List.unmodifiable(_items));
  }

  void updateWhere(
    bool Function(T) test,
    T Function(T old) updater,
  ) {
    for (int i = 0; i < _items.length; i++) {
      if (test(_items[i])) {
        _items[i] = updater(_items[i]);
        break;
      }
    }
    _controller.add(List.unmodifiable(_items));
  }

  // =====================================================
  // CLEANUP
  // =====================================================
  void dispose() {
    _controller.close();
  }
}
