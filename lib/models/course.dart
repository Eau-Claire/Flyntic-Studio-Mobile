import '../core/language/language_manager.dart';

class Course {
  final String id;
  final String _title;
  final String? titleVi;
  final String? _description;
  final String? descriptionVi;
  final String? thumbnail;
  final String? instructorName;
  final String? instructorAvatar;
  final double? price;
  final double? discountPrice;
  final double? rating;
  final int? ratingCount;
  final int? studentCount;
  final int? lessonCount;
  final String? duration;
  final String? level;
  final String? category;
  final String? categoryId;
  final bool? isFeatured;
  final bool? isFree;
  final String? status;
  final DateTime? createdAt;
  final List<String>? tags;
  final String? slug;
  final String? requiredTier;

  const Course({
    required this.id,
    required String title,
    this.titleVi,
    String? description,
    this.descriptionVi,
    this.thumbnail,
    this.instructorName,
    this.instructorAvatar,
    this.price,
    this.discountPrice,
    this.rating,
    this.ratingCount,
    this.studentCount,
    this.lessonCount,
    this.duration,
    this.level,
    this.category,
    this.categoryId,
    this.isFeatured,
    this.isFree,
    this.status,
    this.createdAt,
    this.tags,
    this.slug,
    this.requiredTier,
  }) : _title = title, _description = description;

  String get title {
    if (LanguageManager.instance.isVietnamese && titleVi != null && titleVi!.isNotEmpty) {
      return titleVi!;
    }
    return _title;
  }

  String? get description {
    if (LanguageManager.instance.isVietnamese && descriptionVi != null && descriptionVi!.isNotEmpty) {
      return descriptionVi!;
    }
    return _description;
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    final tier = map['required_tier']?.toString() ?? 'free';
    final isFreeValue = map['is_free'] ?? map['free'] ?? (tier == 'free');

    return Course(
      id: map['id']?.toString() ?? '',
      title: map['title'] ?? map['name'] ?? 'Unknown Course',
      titleVi: map['title_vi'],
      description: map['description'] ?? map['description_en'],
      descriptionVi: map['description_vi'],
      thumbnail: map['thumbnail'] ?? map['thumbnail_url'] ?? map['image_url'] ?? map['cover_image'],
      instructorName: map['instructor_name'] ?? map['instructor']?['name'] ?? map['tutor']?['name'] ?? map['teacher']?['name'],
      instructorAvatar: map['instructor_avatar'] ?? map['instructor']?['avatar'] ?? map['tutor']?['avatar'],
      price: _parseDouble(map['price']),
      discountPrice: _parseDouble(map['discount_price'] ?? map['sale_price']),
      rating: _parseDouble(map['rating'] ?? map['average_rating']),
      ratingCount: _parseInt(map['rating_count'] ?? map['review_count'] ?? map['ratings_count']),
      studentCount: _parseInt(map['student_count'] ?? map['enrolled_count'] ?? map['enrollment_count']),
      lessonCount: _parseInt(map['lesson_count'] ?? map['lessons_count']),
      duration: map['duration']?.toString() ?? (map['duration_minutes'] != null ? '${map['duration_minutes']} mins' : null),
      level: map['level'] ?? map['difficulty'],
      category: map['category'] ?? map['category_name'],
      categoryId: map['category_id']?.toString(),
      isFeatured: map['is_featured'] ?? map['featured'],
      isFree: isFreeValue,
      status: map['status'],
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
      tags: map['tags'] is List ? List<String>.from(map['tags']) : null,
      slug: map['slug'],
      requiredTier: tier,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }

  String get formattedPrice {
    if (isFree == true || price == 0) return LanguageManager.instance.translate('price_free');
    final displayPrice = discountPrice ?? price;
    if (displayPrice == null) {
      if (requiredTier != null && requiredTier != 'free') {
        if (requiredTier!.toLowerCase() == 'pro') return LanguageManager.instance.translate('price_premium');
        return '${requiredTier![0].toUpperCase()}${requiredTier!.substring(1)}';
      }
      return LanguageManager.instance.translate('price_free');
    }
    if (displayPrice == 0) return LanguageManager.instance.translate('price_free');
    return '\$${displayPrice.toStringAsFixed(0)}';
  }

  String get formattedRating => rating?.toStringAsFixed(1) ?? '0.0';
  String get formattedStudents => _formatCount(studentCount ?? 0);

  String get formattedLevel {
    final lvl = level?.toLowerCase() ?? 'all';
    if (lvl.contains('begin')) {
      return LanguageManager.instance.translate('level_beginner');
    } else if (lvl.contains('intermed')) {
      return LanguageManager.instance.translate('level_intermediate');
    } else if (lvl.contains('advanc')) {
      return LanguageManager.instance.translate('level_advanced');
    }
    return LanguageManager.instance.translate('level_all');
  }

  static String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}
