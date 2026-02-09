import '../core/http_client.dart';

import 'reels_service.dart';

class ReelsRepository {
  ReelsRepository({HttpClient? client})
      : _service = ReelsService(client ?? HttpClient());

  final ReelsService _service;

  Future<List<dynamic>> reels() => _service.fetchReels();
}
