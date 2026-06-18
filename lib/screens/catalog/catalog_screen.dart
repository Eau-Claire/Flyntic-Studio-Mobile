import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_manager.dart';
import '../../models/category.dart';
import '../../models/course.dart';
import '../../repositories/course_repository.dart';
import '../course_detail/course_detail_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late CourseRepository _courseRepo;
  late CategoryRepository _catRepo;

  List<Category> _categories = [];
  List<Course> _courses = [];
  String? _selectedCategoryId;
  String? _selectedCategoryName;

  bool _isLoadingCategories = true;
  bool _isLoadingCourses = false;

  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _courseRepo = CourseRepository(Supabase.instance.client);
    _catRepo = CategoryRepository(Supabase.instance.client);
    _loadCategories();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      if (!_isLoadingCourses && _hasMore) {
        _loadCourses();
      }
    }
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoadingCategories = true);
    try {
      final cats = await _catRepo.getCategories();
      if (mounted) {
        setState(() {
          _categories = cats;
          _isLoadingCategories = false;
        });
        if (cats.isNotEmpty) {
          _selectCategory(cats.first);
        } else {
          _loadCourses(reset: true);
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingCategories = false);
    }
  }

  void _selectCategory(Category cat) {
    setState(() {
      _selectedCategoryId = cat.id;
      _selectedCategoryName = cat.name;
    });
    _loadCourses(reset: true);
  }

  void _clearCategoryFilter() {
    setState(() {
      _selectedCategoryId = null;
      _selectedCategoryName = null;
    });
    _loadCourses(reset: true);
  }

  Future<void> _loadCourses({bool reset = false}) async {
    if (reset) {
      setState(() {
        _courses = [];
        _currentPage = 0;
        _hasMore = true;
      });
    }
    setState(() => _isLoadingCourses = true);
    try {
      final courses = await _courseRepo.getCourses(
        categoryId: _selectedCategoryId,
        categoryName: _selectedCategoryName,
        page: _currentPage,
      );
      if (mounted) {
        setState(() {
          if (reset) {
            _courses = courses;
          } else {
            _courses.addAll(courses);
          }
          _hasMore = courses.length >= 12;
          _currentPage++;
          _isLoadingCourses = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingCourses = false);
    }
  }

  void _openCourse(Course course) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CourseDetailScreen(course: course),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        title: Row(
          children: [
            _FlynticLogo(),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Catalog',
                style: AppTextStyles.bodySmall.copyWith(
                  color: ThemeManager.instance.themeType == ThemeType.monochrome
                      ? AppColors.bgPrimary
                      : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildCategoryTabs(),
          Expanded(child: _buildCoursesPanel()),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 56,
      color: AppColors.bgPrimary,
      child: _isLoadingCategories
          ? Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppColors.accentOrange,
                  strokeWidth: 2,
                ),
              ),
            )
          : ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: _categories.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildFilterChip(
                    null,
                    'All',
                    Icons.grid_view_rounded,
                    _selectedCategoryId == null,
                    () => _clearCategoryFilter(),
                  );
                }
                final cat = _categories[index - 1];
                return _buildFilterChip(
                  cat,
                  cat.name,
                  _getCategoryIcon(cat.name),
                  _selectedCategoryId == cat.id,
                  () => _selectCategory(cat),
                );
              },
            ),
    );
  }

  Widget _buildFilterChip(
    Category? cat,
    String name,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isSelected ? AppColors.accentGradient : null,
          color: isSelected ? null : AppColors.bgCard,
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? (ThemeManager.instance.themeType == ThemeType.monochrome
                      ? AppColors.bgPrimary
                      : Colors.white)
                  : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              name,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected
                    ? (ThemeManager.instance.themeType == ThemeType.monochrome
                        ? AppColors.bgPrimary
                        : Colors.white)
                    : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (cat?.courseCount != null && !isSelected) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.bgSecondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${cat!.courseCount}',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 9,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCoursesPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPanelHeader(),
        Expanded(child: _buildCoursesList()),
      ],
    );
  }

  Widget _buildPanelHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedCategoryName ?? 'All Courses',
            style: AppTextStyles.headlineMedium,
          ),
          const SizedBox(height: 2),
          Text(
            _courses.isEmpty && !_isLoadingCourses
                ? 'No courses found'
                : '${_courses.length}${_hasMore ? '+' : ''} courses available',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesList() {
    if (_courses.isEmpty && _isLoadingCourses) {
      return ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, __) => _HorizontalCourseShimmer(),
      );
    }

    if (_courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              color: AppColors.textMuted,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text('No courses in this category', style: AppTextStyles.bodyMedium),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadCourses(reset: true),
      color: AppColors.accentOrange,
      backgroundColor: AppColors.bgCard,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
        itemCount: _courses.length + (_hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index >= _courses.length) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: CircularProgressIndicator(
                  color: AppColors.accentOrange,
                  strokeWidth: 2,
                ),
              ),
            );
          }
          return _HorizontalCourseCard(
            course: _courses[index],
            onTap: () => _openCourse(_courses[index]),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String name) {
    final map = {
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
      'development': Icons.code_rounded,
      'design': Icons.design_services_rounded,
      'business': Icons.business_center_rounded,
      'drone': Icons.flight_takeoff_rounded,
      'pilot': Icons.flight_rounded,
      'navigation': Icons.explore_rounded,
      'sensor': Icons.sensors_rounded,
      'battery': Icons.battery_charging_full_rounded,
      'motor': Icons.settings_rounded,
      'radio': Icons.cell_tower_rounded,
      'data': Icons.bar_chart_rounded,
      'ai': Icons.smart_toy_rounded,
      'machine': Icons.memory_rounded,
      'web': Icons.web_rounded,
      'mobile': Icons.phone_android_rounded,
    };

    final lower = name.toLowerCase();
    for (final entry in map.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return Icons.flight_takeoff_rounded;
  }
}

class _HorizontalCourseCard extends StatefulWidget {
  final Course course;
  final VoidCallback? onTap;

  const _HorizontalCourseCard({required this.course, this.onTap});

  @override
  State<_HorizontalCourseCard> createState() => _HorizontalCourseCardState();
}

class _HorizontalCourseCardState extends State<_HorizontalCourseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(duration: const Duration(milliseconds: 100), vsync: this);
    _scale = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap?.call();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: widget.course.thumbnail != null
                      ? Image.network(
                          widget.course.thumbnail!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(),
                        )
                      : _placeholder(),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (widget.course.category != null)
                        Text(
                          widget.course.category!,
                          style: AppTextStyles.accent.copyWith(fontSize: 10),
                        ),
                      Text(
                        widget.course.title,
                        style: AppTextStyles.titleMedium.copyWith(fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          if (widget.course.rating != null) ...[
                            Icon(Icons.star_rounded, color: AppColors.accentGold, size: 11),
                            const SizedBox(width: 2),
                            Text(widget.course.formattedRating,
                                style: AppTextStyles.bodySmall.copyWith(fontSize: 10)),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.course.formattedPrice,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: widget.course.isFree == true ||
                                      widget.course.price == 0
                                  ? AppColors.success
                                  : AppColors.accentOrange,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.chevron_right_rounded,
                              color: AppColors.textMuted, size: 16),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFF1A2236),
      child: Center(
        child: Icon(Icons.play_circle_outline_rounded,
            color: AppColors.accentOrange, size: 28),
      ),
    );
  }
}

class _HorizontalCourseShimmer extends StatelessWidget {
  const _HorizontalCourseShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
    );
  }
}

class _FlynticLogo extends StatelessWidget {
  const _FlynticLogo();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeManager.instance,
      builder: (context, _) {
        final manager = ThemeManager.instance;
        String assetPath;
        bool showTextWidget;

        if (manager.themeType == ThemeType.classic) {
          assetPath = 'assets/logo-studio.png';
          showTextWidget = false;
        } else {
          if (manager.isDark) {
            assetPath = 'assets/logo-white.png';
            showTextWidget = false;
          } else {
            assetPath = 'assets/logo-black.png';
            showTextWidget = true;
          }
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              assetPath,
              height: 32,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.flight_takeoff_rounded,
                  color: ThemeManager.instance.themeType == ThemeType.monochrome
                      ? AppColors.bgPrimary
                      : Colors.white,
                  size: 16,
                ),
              ),
            ),
            if (showTextWidget) ...[
              const SizedBox(width: 8),
              Text(
                'flyntic studio',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
