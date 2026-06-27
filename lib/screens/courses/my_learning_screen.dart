import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../models/course.dart';
import '../../repositories/course_repository.dart';
import 'course_player_screen.dart';
import '../../core/language/language_manager.dart';

class MyLearningScreen extends StatefulWidget {
  const MyLearningScreen({super.key});

  @override
  State<MyLearningScreen> createState() => _MyLearningScreenState();
}

class _MyLearningScreenState extends State<MyLearningScreen> {
  List<Course> _inProgressCourses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInProgressCourses();
  }

  Future<void> _loadInProgressCourses() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        if (mounted) {
          setState(() {
            _inProgressCourses = [];
            _isLoading = false;
          });
        }
        return;
      }

      final enrolledIds = List<String>.from(user.userMetadata?['enrolled_courses'] ?? []);
      if (enrolledIds.isEmpty) {
        if (mounted) {
          setState(() {
            _inProgressCourses = [];
            _isLoading = false;
          });
        }
        return;
      }

      final repo = CourseRepository(Supabase.instance.client);
      final courseFutures = enrolledIds.map((id) => repo.getCourseById(id));
      final results = await Future.wait(courseFutures);
      final enrolledCourses = results.whereType<Course>().toList();

      if (mounted) {
        setState(() {
          _inProgressCourses = enrolledCourses;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Generate realistic modules based on course
  List<String> _getCourseModules(Course course) {
    final isVi = LanguageManager.instance.isVietnamese;
    if (course.title.toLowerCase().contains('betaflight') || course.title.toLowerCase().contains('pid')) {
      return isVi
          ? [
              'Chương 1: Giới thiệu về FPV & An toàn',
              'Chương 2: Giao thức bộ thu & Sơ đồ motor',
              'Chương 3: Nguyên lý tinh chỉnh PID Loop',
              'Chương 4: Phân tích log Blackbox',
              'Chương 5: Rates, Filters & Tinh chỉnh nâng cao',
            ]
          : [
              'Module 1: Introduction to FPV & Safety',
              'Module 2: Receiver Protocols & Motor Mapping',
              'Module 3: PID Loop Tuning Principles',
              'Module 4: Blackbox Log Analysis',
              'Module 5: Rates, Filters & Advanced Tweaks',
            ];
    } else if (course.title.toLowerCase().contains('build') || course.title.toLowerCase().contains('assemble') || course.title.toLowerCase().contains('lắp ráp')) {
      return isVi
          ? [
              'Chương 1: Chọn linh kiện & Kiểm tra tương thích',
              'Chương 2: Kỹ thuật hàn & Sơ đồ đi dây',
              'Chương 3: Lắp ráp khung & Gắn linh kiện',
              'Chương 4: Cân chỉnh ESC & Khởi động lần đầu',
              'Chương 5: Checklist trước khi bay & Chuyến bay đầu tiên',
            ]
          : [
              'Module 1: Parts Selection & Compatibility Check',
              'Module 2: Solder Techniques & Wiring Schematic',
              'Module 3: Frame Assembly & Hardware Mounts',
              'Module 4: ESC Calibration & Initial Power-up',
              'Module 5: Pre-Flight Checklist & Maiden Flight',
            ];
    } else {
      return isVi
          ? [
              'Chương 1: Chào mừng & Tổng quan khóa học',
              'Chương 2: Phần cứng cốt lõi & Yêu cầu phần mềm',
              'Chương 3: Hướng dẫn cài đặt từng bước',
              'Chương 4: Hiệu chuẩn, cấu hình & Kiểm thử',
              'Chương 5: Hội thảo nâng cao & Đánh giá dự án cuối khóa',
            ]
          : [
              'Module 1: Welcome & Course Overview',
              'Module 2: Core Hardware & Software Pre-requisites',
              'Module 3: Step-by-Step Installation Guides',
              'Module 4: Calibration, Configurations & Tests',
              'Module 5: Advanced Workshop & Final Project Review',
            ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LanguageManager.instance,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.bgPrimary,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              LanguageManager.instance.translate('nav_courses'),
              style: AppTextStyles.headlineLarge.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          body: _isLoading
              ? _buildLoader()
              : _inProgressCourses.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      color: AppColors.accentOrange,
                      backgroundColor: AppColors.bgCard,
                      onRefresh: _loadInProgressCourses,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _inProgressCourses.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 20),
                        itemBuilder: (context, index) {
                          return _buildProgressCard(_inProgressCourses[index], index);
                        },
                      ),
                    ),
        );
      },
    );
  }

  Widget _buildLoader() {
    return Center(
      child: CircularProgressIndicator(
        color: AppColors.accentOrange,
      ),
    );
  }

  Widget _buildEmptyState() {
    final isVi = LanguageManager.instance.isVietnamese;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 64,
              color: AppColors.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              LanguageManager.instance.translate('no_courses_progress'),
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isVi
                  ? 'Đăng ký một khóa học ở phần Khóa học để bắt đầu học.'
                  : 'Enroll in a course from the Explore tab to start learning.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(Course course, int index) {
    final modules = _getCourseModules(course);
    final progressVal = index == 0 ? 0.6 : 0.25;
    final progressPct = index == 0 ? '60%' : '25%';
    final completedCount = index == 0 ? 3 : 1;

    // Difficulty Chip color mapping
    final level = course.level ?? 'beginner';
    final levelColors = {
      'beginner': const Color(0xFF10B981),
      'intermediate': const Color(0xFFF59E0B),
      'advanced': const Color(0xFFEF4444),
    };
    final difficultyColor = levelColors[level.toLowerCase()] ?? AppColors.info;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Header Detail Panel
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author Info Row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.accentOrange.withValues(alpha: 0.15),
                        backgroundImage: course.instructorAvatar != null
                            ? CachedNetworkImageProvider(course.instructorAvatar!)
                            : null,
                        child: course.instructorAvatar == null
                            ? Text(
                                (course.instructorName ?? 'F')[0].toUpperCase(),
                                style: TextStyle(fontSize: 11, color: AppColors.accentOrange, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        course.instructorName ?? 'Flyntic Studio',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Course Title
                  Text(
                    course.title,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Info Tags Row
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (course.category != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accentOrange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.accentOrange.withValues(alpha: 0.2)),
                          ),
                          child: Text(
                            course.category!.toUpperCase(),
                            style: AppTextStyles.accent.copyWith(fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          course.duration != null && course.duration != '0 mins'
                              ? (LanguageManager.instance.isVietnamese
                                  ? course.duration!.replaceAll('mins', 'phút').replaceAll('hours', 'giờ').replaceAll('hour', 'giờ')
                                  : course.duration!)
                              : '${course.lessonCount ?? 12} ${LanguageManager.instance.translate('course_lessons')}',
                          style: AppTextStyles.bodySmall.copyWith(fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: difficultyColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: difficultyColor.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          course.formattedLevel,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: difficultyColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        LanguageManager.instance.isVietnamese ? 'Tiến độ học tập' : 'Course Progress',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        LanguageManager.instance.isVietnamese
                            ? 'Đã hoàn thành $progressPct'
                            : '$progressPct Completed',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.accentOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressVal,
                      minHeight: 6,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentOrange),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Divider(color: AppColors.border, height: 1),
            // Modules List Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LanguageManager.instance.isVietnamese ? 'Nội dung' : 'Modules',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Render first 3 modules
                  ...List.generate(3, (modIndex) {
                    final isModuleCompleted = modIndex < completedCount;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Icon(
                            isModuleCompleted
                                ? Icons.check_circle_rounded
                                : Icons.play_circle_outline_rounded,
                            size: 16,
                            color: isModuleCompleted ? AppColors.success : AppColors.textMuted,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              modules[modIndex],
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: isModuleCompleted ? AppColors.textPrimary : AppColors.textSecondary,
                                fontWeight: isModuleCompleted ? FontWeight.w600 : FontWeight.normal,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  // Continue Learning button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CoursePlayerScreen(course: course),
                          ),
                        ).then((_) {
                          _loadInProgressCourses();
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        backgroundColor: AppColors.accentOrange.withValues(alpha: 0.15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: AppColors.accentOrange.withValues(alpha: 0.3)),
                        ),
                      ),
                      child: Text(
                        LanguageManager.instance.isVietnamese ? 'Tiếp tục học' : 'Continue Learning',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
