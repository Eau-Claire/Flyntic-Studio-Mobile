import '../core/language/language_manager.dart';

class DroneBuild {
  final String id;
  final String slug;
  final String _name;
  final String? nameVi;
  final String _description;
  final String? descriptionVi;
  final String thumbnailUrl;
  final String difficulty;
  final double estimatedCost;
  final int estimatedCostVnd;
  final String flightTime;
  final String _useCase;
  final String? useCaseVi;
  final List<String> productIds;
  final List<dynamic> steps;
  final List<dynamic> wires;
  final String? modelUrl;
  final DateTime createdAt;

  DroneBuild({
    required this.id,
    required this.slug,
    required String name,
    this.nameVi,
    required String description,
    this.descriptionVi,
    required this.thumbnailUrl,
    required this.difficulty,
    required this.estimatedCost,
    required this.estimatedCostVnd,
    required this.flightTime,
    required String useCase,
    this.useCaseVi,
    required this.productIds,
    required this.steps,
    required this.wires,
    this.modelUrl,
    required this.createdAt,
  })  : _name = name,
        _description = description,
        _useCase = useCase;

  String get name {
    if (LanguageManager.instance.isVietnamese && nameVi != null && nameVi!.isNotEmpty) {
      return nameVi!;
    }
    return _name;
  }

  String get description {
    if (LanguageManager.instance.isVietnamese && descriptionVi != null && descriptionVi!.isNotEmpty) {
      return descriptionVi!;
    }
    return _description;
  }

  String get useCase {
    if (LanguageManager.instance.isVietnamese && useCaseVi != null && useCaseVi!.isNotEmpty) {
      return useCaseVi!;
    }
    return _useCase;
  }

  factory DroneBuild.fromJson(Map<String, dynamic> json) {
    return DroneBuild(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String? ?? '',
      nameVi: json['name_vi'] as String?,
      description: json['description'] as String? ?? '',
      descriptionVi: json['description_vi'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? 'beginner',
      estimatedCost: (json['estimated_cost'] as num?)?.toDouble() ?? 0.0,
      estimatedCostVnd: json['estimated_cost_vnd'] as int? ?? 0,
      flightTime: json['flight_time'] as String? ?? '',
      useCase: json['use_case'] as String? ?? '',
      useCaseVi: json['use_case_vi'] as String?,
      productIds: List<String>.from(json['product_ids'] ?? []),
      steps: List<dynamic>.from(json['steps'] ?? []),
      wires: List<dynamic>.from(json['wires'] ?? []),
      modelUrl: json['model_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  String get formattedDifficulty {
    final diff = difficulty.toLowerCase();
    if (diff.contains('begin')) {
      return LanguageManager.instance.translate('level_beginner');
    } else if (diff.contains('intermed')) {
      return LanguageManager.instance.translate('level_intermediate');
    } else if (diff.contains('advanc')) {
      return LanguageManager.instance.translate('level_advanced');
    }
    return LanguageManager.instance.translate('level_all');
  }

  String get formattedCost {
    if (estimatedCostVnd > 0) {
      if (estimatedCostVnd >= 1000000) {
        final double mil = estimatedCostVnd / 1000000;
        return '${mil.toStringAsFixed(mil % 1 == 0 ? 0 : 1)}M VND';
      }
      return '${estimatedCostVnd.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")} VND';
    }
    return '\$${estimatedCost.toStringAsFixed(2)}';
  }
}
