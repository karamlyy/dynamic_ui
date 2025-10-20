import '../models/dynamic_models.dart';
import '../services/api_service.dart';

class DynamicRepository {
  final ApiService api;

  DynamicRepository({required this.api});

  Future<List<DynamicSection>> fetchSectionsForUser(int userId) async {
    final body = await api.getJson('/users/$userId');
    final sectionsJson = (body['sections'] as List<dynamic>? ?? []);
    return sectionsJson
        .map((s) => DynamicSection.fromJson(Map<String, dynamic>.from(s)))
        .toList();
  }

  Future<List<Map<String, dynamic>>> fetchLookup(String entity) async {
    final body = await api.getJson('/lookups/$entity');
    return (body['items'] as List<dynamic>? ?? []).map((e) => Map<String, dynamic>.from(e)).toList();
  }
}