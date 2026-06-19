class DroneBuild {
  final String id;
  final String slug;
  final String name;
  final String description;
  final String thumbnailUrl;
  final String difficulty;
  final double estimatedCost;
  final int estimatedCostVnd;
  final String flightTime;
  final String useCase;
  final List<String> productIds;
  final List<dynamic> steps;
  final List<dynamic> wires;
  final String? modelUrl;
  final DateTime createdAt;

  DroneBuild({
    required this.id,
    required this.slug,
    required this.name,
    required this.description,
    required this.thumbnailUrl,
    required this.difficulty,
    required this.estimatedCost,
    required this.estimatedCostVnd,
    required this.flightTime,
    required this.useCase,
    required this.productIds,
    required this.steps,
    required this.wires,
    this.modelUrl,
    required this.createdAt,
  });

  factory DroneBuild.fromJson(Map<String, dynamic> json) {
    return DroneBuild(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? 'beginner',
      estimatedCost: (json['estimated_cost'] as num?)?.toDouble() ?? 0.0,
      estimatedCostVnd: json['estimated_cost_vnd'] as int? ?? 0,
      flightTime: json['flight_time'] as String? ?? '',
      useCase: json['use_case'] as String? ?? '',
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
    if (difficulty.isEmpty) return 'Beginner';
    return difficulty[0].toUpperCase() + difficulty.substring(1);
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
