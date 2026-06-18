class Category {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final String? image;
  final String? color;
  final int? courseCount;
  final String? slug;
  final String? parentId;

  const Category({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.image,
    this.color,
    this.courseCount,
    this.slug,
    this.parentId,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? map['title'] ?? 'Unknown',
      description: map['description'],
      icon: map['icon'],
      image: map['image'] ?? map['image_url'] ?? map['thumbnail'],
      color: map['color'],
      courseCount: map['course_count'] is int
          ? map['course_count']
          : int.tryParse(map['course_count']?.toString() ?? ''),
      slug: map['slug'],
      parentId: map['parent_id']?.toString(),
    );
  }
}
