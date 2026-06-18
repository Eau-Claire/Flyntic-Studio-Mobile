import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_manager.dart';
import '../../models/category.dart';

class CategoryCard extends StatefulWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
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
      animation: _scale,
      builder: (context, child) => Transform.scale(scale: _scale.value, child: child),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap?.call();
        },
        onTapCancel: () => _controller.reverse(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: widget.isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF2A1810), Color(0xFF1A1510)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : AppColors.cardGradient,
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.accentOrange
                  : AppColors.border,
              width: widget.isSelected ? 1.5 : 1,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppColors.accentOrange.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIcon(),
                const SizedBox(height: 10),
                Text(
                  widget.category.name,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: widget.isSelected ? AppColors.accentOrange : AppColors.textPrimary,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.category.courseCount != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${widget.category.courseCount} courses',
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final icons = {
      'fpv': Icons.flight_rounded,
      'racing': Icons.speed_rounded,
      'aerial': Icons.camera_outdoor_rounded,
      'photography': Icons.camera_alt_rounded,
      'cinemat': Icons.videocam_rounded,
      'assembly': Icons.build_circle_outlined,
      'build': Icons.construction_rounded,
      'repair': Icons.handyman_rounded,
      'regulation': Icons.gavel_rounded,
      'safety': Icons.shield_rounded,
      'mapping': Icons.map_rounded,
      'survey': Icons.terrain_rounded,
      'agri': Icons.grass_rounded,
      'programming': Icons.code_rounded,
      'design': Icons.design_services_rounded,
      'business': Icons.business_center_rounded,
      'drone': Icons.flight_takeoff_rounded,
      'pilot': Icons.flight_rounded,
      'navigation': Icons.explore_rounded,
      'sensor': Icons.sensors_rounded,
      'battery': Icons.battery_charging_full_rounded,
      'motor': Icons.settings_rounded,
      'radio': Icons.cell_tower_rounded,
      'finance': Icons.account_balance_rounded,
    };

    final nameKey = widget.category.name.toLowerCase();
    IconData? icon;
    for (final entry in icons.entries) {
      if (nameKey.contains(entry.key)) {
        icon = entry.value;
        break;
      }
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: widget.isSelected
            ? AppColors.accentGradient
            : const LinearGradient(
                colors: [Color(0xFF1E2A42), Color(0xFF152035)],
              ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(
          icon ?? Icons.flight_takeoff_rounded,
          color: widget.isSelected
              ? (ThemeManager.instance.themeType == ThemeType.monochrome
                  ? AppColors.bgPrimary
                  : Colors.white)
              : AppColors.accentOrange,
          size: 22,
        ),
      ),
    );
  }
}

class CategoryCardShimmer extends StatelessWidget {
  const CategoryCardShimmer({super.key});

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
      ),
    );
  }
}
