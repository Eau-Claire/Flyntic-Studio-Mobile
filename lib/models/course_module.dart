class CourseModule {
  final String id;
  final String courseId;
  final String title;
  final String? videoUrl;
  final String? content;
  final int order;
  final String? titleVi;
  final String? contentVi;
  final String? lessonType;
  final List<dynamic>? quiz;

  const CourseModule({
    required this.id,
    required this.courseId,
    required this.title,
    this.videoUrl,
    this.content,
    required this.order,
    this.titleVi,
    this.contentVi,
    this.lessonType,
    this.quiz,
  });

  factory CourseModule.fromMap(Map<String, dynamic> map) {
    return CourseModule(
      id: map['id']?.toString() ?? '',
      courseId: map['course_id']?.toString() ?? '',
      title: map['title'] ?? map['title_vi'] ?? 'Untitled Lesson',
      videoUrl: map['video_url']?.toString(),
      content: map['content'] ?? map['content_vi'] ?? '',
      order: map['order'] is int ? map['order'] : int.tryParse(map['order']?.toString() ?? '0') ?? 0,
      titleVi: map['title_vi'],
      contentVi: map['content_vi'],
      lessonType: map['lesson_type'],
      quiz: map['quiz'] is List ? map['quiz'] : null,
    );
  }

  String get displayTitle => title;
  String get displayContent => content ?? '';
}
