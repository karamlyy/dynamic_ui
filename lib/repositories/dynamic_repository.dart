import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dynamic_models.dart';

class DynamicRepository {
  final String baseUrl;

  DynamicRepository({required this.baseUrl});

  Future<List<DynamicSection>> fetchSectionsForUser(int userId) async {
    final uri = Uri.parse('$baseUrl/users/$userId');
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch sections: ${res.statusCode}');
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final sectionsJson = (body['sections'] as List<dynamic>? ?? []);
    return sectionsJson
        .map((s) => DynamicSection.fromJson(Map<String, dynamic>.from(s)))
        .toList();
  }

  Future<List<Map<String, dynamic>>> fetchLookup(String entity) async {
    final uri = Uri.parse('$baseUrl/lookups/$entity');
    final res = await http.get(uri);
    if (res.statusCode != 200) return [];
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return (body['items'] as List<dynamic>? ?? []).map((e) => Map<String, dynamic>.from(e)).toList();
  }
}