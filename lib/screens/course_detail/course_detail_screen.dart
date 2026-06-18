import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_manager.dart';
import '../../models/course.dart';
import '../../widgets/buttons.dart';

class CourseDetailScreen extends StatefulWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  bool _isEnrolled = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryTag(),
                  const SizedBox(height: 10),
                  _buildTitle(),
                  const SizedBox(height: 12),
                  _buildStats(),
                  if (widget.course.instructorName != null) ...[
                    const SizedBox(height: 16),
                    _buildInstructor(),
                  ],
                  const SizedBox(height: 20),
                  Divider(color: AppColors.border),
                  const SizedBox(height: 20),
                  if (widget.course.description != null) ...[
                    _buildSection('About This Course', widget.course.description!),
                    const SizedBox(height: 24),
                  ],
                  _buildCourseInfo(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: AppColors.bgPrimary,
      expandedHeight: 260,
      pinned: true,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.bgCard.withValues(alpha: 0.8),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary, size: 18),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: _buildHeroImage(),
      ),
    );
  }

  Widget _buildHeroImage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.course.thumbnail != null && widget.course.thumbnail!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: widget.course.thumbnail!,
                fit: BoxFit.cover,
              )
            : Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A2236), Color(0xFF0D1526)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(Icons.play_circle_outline_rounded,
                      color: AppColors.accentOrange, size: 64),
                ),
              ),
        // Gradient overlay at bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, AppColors.bgPrimary.withValues(alpha: 0.95)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        // Play button overlay
        Center(
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.accentGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentOrange.withValues(alpha: 0.4),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Icon(
              Icons.play_arrow_rounded,
              color: ThemeManager.instance.themeType == ThemeType.monochrome
                  ? AppColors.bgPrimary
                  : Colors.white,
              size: 32,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTag() {
    if (widget.course.category == null) return const SizedBox.shrink();
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.accentOrange.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.accentOrange.withValues(alpha: 0.3)),
          ),
          child: Text(
            widget.course.category!,
            style: AppTextStyles.accent.copyWith(fontSize: 12),
          ),
        ),
        const SizedBox(width: 8),
        _buildLevelChip(),
      ],
    );
  }

  Widget _buildLevelChip() {
    final level = widget.course.level;
    if (level == null) return const SizedBox.shrink();
    final colors = {
      'beginner': AppColors.success,
      'intermediate': AppColors.warning,
      'advanced': AppColors.error,
    };
    final color = colors[level.toLowerCase()] ?? AppColors.info;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        widget.course.formattedLevel,
        style: AppTextStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.course.title,
      style: AppTextStyles.displayMedium.copyWith(fontSize: 22, height: 1.3),
    );
  }

  Widget _buildStats() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        if (widget.course.rating != null)
          _buildStatItem(Icons.star_rounded, AppColors.accentGold,
              '${widget.course.formattedRating} Rating'),
        if (widget.course.studentCount != null)
          _buildStatItem(Icons.people_outline_rounded, AppColors.info,
              '${widget.course.formattedStudents} Students'),
        if (widget.course.lessonCount != null)
          _buildStatItem(Icons.play_circle_outline_rounded, AppColors.accentOrange,
              '${widget.course.lessonCount} Lessons'),
        if (widget.course.duration != null)
          _buildStatItem(Icons.access_time_rounded, AppColors.success,
              widget.course.duration!),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(text, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildInstructor() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.accentOrange.withValues(alpha: 0.2),
            backgroundImage: widget.course.instructorAvatar != null
                ? CachedNetworkImageProvider(widget.course.instructorAvatar!)
                : null,
            child: widget.course.instructorAvatar == null
                ? Text(
                    widget.course.instructorName![0].toUpperCase(),
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.accentOrange,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Instructor', style: AppTextStyles.bodySmall),
                Text(
                  widget.course.instructorName!,
                  style: AppTextStyles.titleMedium,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderLight),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('Profile', style: AppTextStyles.bodySmall),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.headlineMedium),
        const SizedBox(height: 10),
        Text(content, style: AppTextStyles.bodyLarge.copyWith(height: 1.6)),
      ],
    );
  }

  Widget _buildCourseInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Course Information', style: AppTextStyles.headlineMedium),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              if (widget.course.level != null)
                _buildInfoRow(Icons.signal_cellular_alt_rounded, 'Level',
                    widget.course.formattedLevel, true),
              if (widget.course.lessonCount != null)
                _buildInfoRow(Icons.play_circle_outline_rounded, 'Lessons',
                    '${widget.course.lessonCount} lessons', widget.course.level != null),
              if (widget.course.duration != null)
                _buildInfoRow(Icons.access_time_rounded, 'Duration',
                    widget.course.duration!, widget.course.lessonCount != null),
              if (widget.course.tags != null && widget.course.tags!.isNotEmpty)
                _buildInfoRow(Icons.label_outline_rounded, 'Topics',
                    widget.course.tags!.take(3).join(', '), widget.course.duration != null),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool hasDivider) {
    return Column(
      children: [
        if (hasDivider) Divider(height: 1, color: AppColors.border),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: AppColors.accentOrange, size: 18),
              const SizedBox(width: 12),
              Text(label, style: AppTextStyles.bodyMedium),
              const Spacer(),
              Text(value, style: AppTextStyles.titleMedium.copyWith(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Price', style: AppTextStyles.bodySmall),
              Text(
                widget.course.formattedPrice,
                style: AppTextStyles.displayMedium.copyWith(
                  color: widget.course.isFree == true || widget.course.price == 0
                      ? AppColors.success
                      : AppColors.accentOrange,
                  fontSize: 24,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GradientButton(
              label: _isEnrolled ? 'Go to Course' : 'Enroll Now',
              icon: _isEnrolled ? Icons.arrow_forward_rounded : Icons.school_rounded,
              isLoading: _isLoading,
              onPressed: _handleEnroll,
              height: 52,
            ),
          ),
        ],
      ),
    );
  }

  void _handleEnroll() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isEnrolled = !_isEnrolled;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  _isEnrolled ? 'Successfully enrolled!' : 'Unenrolled',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: _isEnrolled ? AppColors.success : AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    });
  }
}
