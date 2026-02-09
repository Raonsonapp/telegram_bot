import '../core/http_client.dart';

import 'home_service.dart';

class HomeRepository {
  HomeRepository({HttpClient? client})
      : _service = HomeService(client ?? HttpClient());

  final HomeService _service;

  Future<List<dynamic>> feed() => _service.fetchFeed();
}
