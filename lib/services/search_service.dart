import '../core/api.dart';
import '../core/http_service.dart';

class SearchService {
  static Future<List<dynamic>> search(String query) async {
    if (query.isEmpty) return [];
    return await HttpService.get(
      '${Api.searchEndpoint}?q=$query',
    );
  }
}
