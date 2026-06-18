import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_manager.dart';
import '../../models/course.dart';

class CourseCard extends StatefulWidget {
  final Course course;
  final VoidCallback? onTap;
  final bool compact;

  const CourseCard({
    super.key,
    required this.course,
    this.onTap,
    this.compact = false,
  });

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap?.call();
        },
        onTapCancel: () => _controller.reverse(),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: AppColors.cardGradient,
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildThumbnail(),
                _buildContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: widget.course.thumbnail != null && widget.course.thumbnail!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: widget.course.thumbnail!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _buildShimmer(),
                    errorWidget: (context, url, error) => _buildPlaceholderImage(),
                  )
                : _buildPlaceholderImage(),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: _buildLevelBadge(),
          ),
          if (widget.course.isFeatured == true)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '★ Featured',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: ThemeManager.instance.themeType == ThemeType.monochrome
                        ? AppColors.bgPrimary
                        : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 10,
            right: 10,
            child: _buildPriceBadge(),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelBadge() {
    final level = widget.course.level ?? 'all';
    final colors = {
      'beginner': const Color(0xFF10B981),
      'intermediate': const Color(0xFFF59E0B),
      'advanced': const Color(0xFFEF4444),
      'all': const Color(0xFF3B82F6),
    };
    final color = colors[level.toLowerCase()] ?? const Color(0xFF3B82F6);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        widget.course.formattedLevel,
        style: AppTextStyles.bodySmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildPriceBadge() {
    final isFree = widget.course.isFree == true ||
        widget.course.price == 0 ||
        widget.course.price == null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isFree
            ? AppColors.success.withValues(alpha: 0.9)
            : AppColors.bgPrimary.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isFree ? AppColors.success : AppColors.border,
          width: 1,
        ),
      ),
      child: Text(
        widget.course.formattedPrice,
        style: AppTextStyles.bodySmall.copyWith(
          color: isFree ? Colors.white : AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.course.category != null) ...[
            Text(
              widget.course.category!,
              style: AppTextStyles.accent.copyWith(fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
          ],
          Text(
            widget.course.title,
            style: AppTextStyles.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (!widget.compact && widget.course.description != null) ...[
            const SizedBox(height: 6),
            Text(
              widget.course.description!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (widget.course.instructorName != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: AppColors.accentOrange.withValues(alpha: 0.2),
                  backgroundImage: widget.course.instructorAvatar != null
                      ? CachedNetworkImageProvider(widget.course.instructorAvatar!)
                      : null,
                  child: widget.course.instructorAvatar == null
                      ? Text(
                          widget.course.instructorName![0].toUpperCase(),
                          style: TextStyle(fontSize: 10, color: AppColors.accentOrange),
                        )
                      : null,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.course.instructorName!,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              if (widget.course.rating != null) ...[
                Icon(Icons.star_rounded, color: AppColors.accentGold, size: 14),
                const SizedBox(width: 3),
                Text(
                  widget.course.formattedRating,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.course.ratingCount != null) ...[
                  const SizedBox(width: 2),
                  Text(
                    '(${widget.course.ratingCount})',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
                const SizedBox(width: 8),
              ],
              if (!widget.compact && widget.course.studentCount != null) ...[
                Icon(Icons.people_outline_rounded, color: AppColors.textMuted, size: 13),
                const SizedBox(width: 3),
                Text(
                  widget.course.formattedStudents,
                  style: AppTextStyles.bodySmall,
                ),
              ],
              const Spacer(),
              if (widget.course.lessonCount != null)
                Flexible(
                  child: Text(
                    '${widget.course.lessonCount} lessons',
                    style: AppTextStyles.bodySmall,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A2236), Color(0xFF0D1526)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.play_circle_outline_rounded,
              color: AppColors.accentOrange.withValues(alpha: 0.5),
              size: 40,
            ),
            const SizedBox(height: 6),
            Text('Course', style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1A2236),
      highlightColor: const Color(0xFF253352),
      child: Container(
        color: const Color(0xFF1A2236),
      ),
    );
  }
}

class CourseCardShimmer extends StatelessWidget {
  const CourseCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1A2236),
      highlightColor: const Color(0xFF253352),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A2236),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1E2A42),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 10, width: 80, color: AppColors.bgCardHover),
                  const SizedBox(height: 8),
                  Container(height: 14, color: AppColors.bgCardHover),
                  const SizedBox(height: 4),
                  Container(height: 14, width: 160, color: AppColors.bgCardHover),
                  const SizedBox(height: 12),
                  Container(height: 10, width: 120, color: AppColors.bgCardHover),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
