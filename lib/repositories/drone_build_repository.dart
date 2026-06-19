import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/drone_build.dart';

class DroneBuildRepository {
  final SupabaseClient _client;

  DroneBuildRepository(this._client);

  Future<List<DroneBuild>> getDroneBuilds({
    String? search,
    String? difficulty,
    int page = 0,
    int pageSize = 12,
  }) async {
    var query = _client.from('drone_builds').select();

    if (search != null && search.isNotEmpty) {
      query = query.or('name.ilike.%$search%,description.ilike.%$search%');
    }

    if (difficulty != null && difficulty != 'all') {
      query = query.eq('difficulty', difficulty);
    }

    // Ordering and Pagination
    final from = page * pageSize;
    final to = from + pageSize - 1;
    
    final response = await query
        .order('created_at', ascending: false)
        .range(from, to);

    return (response as List<dynamic>)
        .map((json) => DroneBuild.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<DroneBuild> getDroneBuildBySlug(String slug) async {
    final response = await _client
        .from('drone_builds')
        .select()
        .eq('slug', slug)
        .single();
    return DroneBuild.fromJson(response);
  }
}
