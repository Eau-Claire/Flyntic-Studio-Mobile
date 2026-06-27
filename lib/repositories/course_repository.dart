import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course.dart';
import '../models/category.dart';
import '../models/course_module.dart';

class CourseRepository {
  final SupabaseClient _client;
  static const _pageSize = 12;

  CourseRepository(this._client);

  Future<List<CourseModule>> getCourseModules(String courseId) async {
    try {
      final response = await _client
          .from('course_modules')
          .select('*')
          .eq('course_id', courseId)
          .order('order', ascending: true);
      return (response as List).map((e) => CourseModule.fromMap(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Course>> getCourses({
    String? categoryId,
    String? categoryName,
    String? search,
    String? level,
    String? sortBy,
    bool ascending = false,
    int page = 0,
  }) async {
    try {
      var query = _client.from(_detectCoursesTable()).select('*');

      if (categoryName != null && categoryName.isNotEmpty) {
        query = query.eq('category', categoryName);
      } else if (categoryId != null && categoryId.isNotEmpty) {
        query = query.eq('category_id', categoryId);
      }

      if (search != null && search.isNotEmpty) {
        query = query.or('title.ilike.%$search%,title_vi.ilike.%$search%');
      }

      if (level != null && level.isNotEmpty && level != 'all') {
        query = query.eq('difficulty', level.toLowerCase());
      }

      final response = await query
          .order(sortBy ?? 'created_at', ascending: ascending)
          .range(page * _pageSize, (page + 1) * _pageSize - 1);

      return (response as List).map((e) => Course.fromMap(e)).toList();
    } catch (e) {
      return _getFallbackCourses(categoryId: categoryId, search: search);
    }
  }

  Future<List<Course>> getFeaturedCourses() async {
    try {
      final tableName = _detectCoursesTable();
      try {
        final response = await _client
            .from(tableName)
            .select('*')
            .eq('is_featured', true)
            .order('created_at', ascending: false)
            .limit(6);
        if ((response as List).isNotEmpty) {
          return response.map((e) => Course.fromMap(e)).toList();
        }
      } catch (_) {}

      final response = await _client
          .from(tableName)
          .select('*')
          .order('created_at', ascending: false)
          .limit(6);
      return (response as List).map((e) => Course.fromMap(e)).toList();
    } catch (e) {
      return _getFallbackCourses();
    }
  }

  Future<List<Course>> getPopularCourses() async {
    try {
      final tableName = _detectCoursesTable();
      final response = await _client
          .from(tableName)
          .select('*')
          .order('student_count', ascending: false)
          .limit(6);
      return (response as List).map((e) => Course.fromMap(e)).toList();
    } catch (e) {
      return _getFallbackCourses();
    }
  }

  Future<Course?> getCourseById(String id) async {
    try {
      final response = await _client
          .from(_detectCoursesTable())
          .select('*')
          .eq('id', id)
          .single();
      return Course.fromMap(response);
    } catch (e) {
      return null;
    }
  }

  String _detectCoursesTable() {
    return 'courses';
  }

  List<Course> _getFallbackCourses({String? categoryId, String? search}) {
    return [];
  }
}

class CategoryRepository {
  final SupabaseClient _client;

  CategoryRepository(this._client);

  Future<List<Category>> getCategories() async {
    try {
      final response = await _client
          .from('categories')
          .select('*')
          .order('name');
      return (response as List).map((e) => Category.fromMap(e)).toList();
    } catch (e) {
      try {
        final response = await _client
            .from('course_categories')
            .select('*')
            .order('name');
        return (response as List).map((e) => Category.fromMap(e)).toList();
      } catch (e2) {
        return [];
      }
    }
  }
}
