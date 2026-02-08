import '../core/api.dart';
import '../core/http_service.dart';

class SearchService {
  static Future<Map<String, dynamic>> search(String query) async {
    return await HttpService.get(
      '${Api.searchEndpoint}?q=$query',
    );
  }
}
