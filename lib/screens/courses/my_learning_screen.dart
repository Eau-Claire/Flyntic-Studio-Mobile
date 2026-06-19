import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../../models/course.dart';
import '../../repositories/course_repository.dart';
import '../course_detail/course_detail_screen.dart';

class MyLearningScreen extends StatefulWidget {
  const MyLearningScreen({super.key});

  @override
  State<MyLearningScreen> createState() => _MyLearningScreenState();
}

class _MyLearningScreenState extends State<MyLearningScreen> {
  late CourseRepository _repo;
  List<Course> _inProgressCourses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repo = CourseRepository(Supabase.instance.client);
    _loadInProgressCourses();
  }

  Future<void> _loadInProgressCourses() async {
    setState(() => _isLoading = true);
    try {
      final courses = await _repo.getCourses(page: 0);
      if (mounted) {
        setState(() {
          // We take up to 2 courses to show as "In Progress"
          _inProgressCourses = courses.take(2).toList();
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
    if (course.title.toLowerCase().contains('betaflight') || course.title.toLowerCase().contains('pid')) {
      return [
        'Module 1: Introduction to FPV & Safety',
        'Module 2: Receiver Protocols & Motor Mapping',
        'Module 3: PID Loop Tuning Principles',
        'Module 4: Blackbox Log Analysis',
        'Module 5: Rates, Filters & Advanced Tweaks',
      ];
    } else if (course.title.toLowerCase().contains('build') || course.title.toLowerCase().contains('assemble')) {
      return [
        'Module 1: Parts Selection & Compatibility Check',
        'Module 2: Solder Techniques & Wiring Schematic',
        'Module 3: Frame Assembly & Hardware Mounts',
        'Module 4: ESC Calibration & Initial Power-up',
        'Module 5: Pre-Flight Checklist & Maiden Flight',
      ];
    } else {
      return [
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
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'My Learning',
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
  }

  Widget _buildLoader() {
    return Center(
      child: CircularProgressIndicator(
        color: AppColors.accentOrange,
      ),
    );
  }

  Widget _buildEmptyState() {
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
              'No courses in progress',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enroll in a course from the Explore tab to start learning.',
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
                              ? course.duration!
                              : '${course.lessonCount ?? 12} lessons',
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
                        'Course Progress',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$progressPct Completed',
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
                    'Modules',
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
                  // Show all course sections button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CourseDetailScreen(course: course),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        backgroundColor: AppColors.border.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Show all course sections',
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
