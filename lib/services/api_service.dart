import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  final Map<String, String> defaultHeaders;

  ApiService({required this.baseUrl, Map<String, String>? defaultHeaders})
      : defaultHeaders = defaultHeaders ?? const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        };

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$normalized').replace(
      queryParameters: query?.map((k, v) => MapEntry(k, v?.toString() ?? '')),
    );
  }

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
  }) async {
    final uri = _uri(path, query);
    final res = await http.get(uri, headers: {...defaultHeaders, ...?headers});

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('GET ${uri.toString()} failed: ${res.statusCode} ${res.body}');
    }

    if (res.body.isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(res.body);
    if (decoded is Map<String, dynamic>) return decoded;
    throw Exception('Unexpected JSON shape from ${uri.toString()}');
  }
}


