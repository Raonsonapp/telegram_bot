import '../core/http_client.dart';

import 'profile_service.dart';

class ProfileRepository {
  ProfileRepository({HttpClient? client})
      : _service = ProfileService(client ?? HttpClient());

  final ProfileService _service;

  Future<Map<String, dynamic>> profile() => _service.profile();
}
