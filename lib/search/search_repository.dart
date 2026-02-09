import '../core/http_client.dart';

import 'search_service.dart';

class SearchRepository {
  SearchRepository({HttpClient? client})
      : _service = SearchService(client ?? HttpClient());

  final SearchService _service;

  Future<List<dynamic>> search(String query) => _service.search(query);
}
