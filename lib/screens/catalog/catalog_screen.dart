import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_manager.dart';
import '../../models/drone_build.dart';
import '../../repositories/drone_build_repository.dart';
import 'drone_build_detail_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late DroneBuildRepository _repo;

  final List<Map<String, dynamic>> _difficultyLevels = [
    {'key': 'all', 'label': 'All Levels', 'icon': Icons.grid_view_rounded},
    {'key': 'beginner', 'label': 'Beginner', 'icon': Icons.handyman_rounded},
    {'key': 'intermediate', 'label': 'Intermediate', 'icon': Icons.build_rounded},
    {'key': 'advanced', 'label': 'Advanced', 'icon': Icons.construction_rounded},
  ];

  List<DroneBuild> _builds = [];
  String _selectedDifficulty = 'all';

  bool _isLoading = true;

  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _repo = DroneBuildRepository(Supabase.instance.client);
    _loadBuilds(reset: true);
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
      if (!_isLoading && _hasMore) {
        _loadBuilds();
      }
    }
  }

  Future<void> _loadBuilds({bool reset = false}) async {
    if (reset) {
      setState(() {
        _builds = [];
        _currentPage = 0;
        _hasMore = true;
        _isLoading = true;
      });
    } else {
      setState(() => _isLoading = true);
    }

    try {
      final builds = await _repo.getDroneBuilds(
        difficulty: _selectedDifficulty == 'all' ? null : _selectedDifficulty,
        page: _currentPage,
      );
      if (mounted) {
        setState(() {
          if (reset) {
            _builds = builds;
          } else {
            _builds.addAll(builds);
          }
          _hasMore = builds.length >= 12;
          _currentPage++;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _selectDifficulty(String level) {
    setState(() {
      _selectedDifficulty = level;
    });
    _loadBuilds(reset: true);
  }

  void _openBuildDetail(DroneBuild build) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DroneBuildDetailScreen(build: build),
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
                'Builds Catalog',
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
          _buildFilterTabs(),
          Expanded(child: _buildCatalogPanel()),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 56,
      color: AppColors.bgPrimary,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: _difficultyLevels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final level = _difficultyLevels[index];
          final isSelected = _selectedDifficulty == level['key'];
          return GestureDetector(
            onTap: () => _selectDifficulty(level['key']),
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
                    level['icon'],
                    size: 16,
                    color: isSelected
                        ? (ThemeManager.instance.themeType == ThemeType.monochrome
                            ? AppColors.bgPrimary
                            : Colors.white)
                        : AppColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    level['label'],
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isSelected
                          ? (ThemeManager.instance.themeType == ThemeType.monochrome
                              ? AppColors.bgPrimary
                              : Colors.white)
                          : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCatalogPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPanelHeader(),
        Expanded(child: _buildBuildsList()),
      ],
    );
  }

  Widget _buildPanelHeader() {
    final activeLabel = _difficultyLevels.firstWhere(
      (l) => l['key'] == _selectedDifficulty,
      orElse: () => _difficultyLevels.first,
    )['label'];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            activeLabel,
            style: AppTextStyles.headlineMedium,
          ),
          const SizedBox(height: 2),
          Text(
            _builds.isEmpty && !_isLoading
                ? 'No builds found'
                : '${_builds.length}${_hasMore ? '+' : ''} drone models available',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildBuildsList() {
    if (_builds.isEmpty && _isLoading) {
      return ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, __) => const _HorizontalBuildShimmer(),
      );
    }

    if (_builds.isEmpty) {
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
            Text('No drone builds found in this category', style: AppTextStyles.bodyMedium),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadBuilds(reset: true),
      color: AppColors.accentOrange,
      backgroundColor: AppColors.bgCard,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
        itemCount: _builds.length + (_hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index >= _builds.length) {
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
          return _HorizontalDroneBuildCard(
            build: _builds[index],
            onTap: () => _openBuildDetail(_builds[index]),
          );
        },
      ),
    );
  }
}

class _HorizontalDroneBuildCard extends StatefulWidget {
  final DroneBuild build;
  final VoidCallback? onTap;

  const _HorizontalDroneBuildCard({required this.build, this.onTap});

  @override
  State<_HorizontalDroneBuildCard> createState() => _HorizontalDroneBuildCardState();
}

class _HorizontalDroneBuildCardState extends State<_HorizontalDroneBuildCard>
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
          height: 110,
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
                  width: 110,
                  height: 110,
                  child: widget.build.thumbnailUrl.isNotEmpty
                      ? Image.network(
                          widget.build.thumbnailUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(),
                        )
                      : _placeholder(),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accentOrange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              widget.build.formattedDifficulty,
                              style: AppTextStyles.accent.copyWith(
                                fontSize: 9,
                                color: AppColors.accentOrange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (widget.build.flightTime.isNotEmpty)
                            Row(
                              children: [
                                Icon(Icons.timer_rounded, color: AppColors.textMuted, size: 10),
                                const SizedBox(width: 2),
                                Text(
                                  widget.build.flightTime,
                                  style: AppTextStyles.bodySmall.copyWith(fontSize: 9),
                                ),
                              ],
                            ),
                        ],
                      ),
                      Text(
                        widget.build.name,
                        style: AppTextStyles.titleMedium.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Icon(Icons.flight_takeoff_rounded, color: AppColors.textMuted, size: 12),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.build.useCase.isNotEmpty ? widget.build.useCase : 'Custom Drone Build',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 10,
                                color: AppColors.textMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            widget.build.formattedCost,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.accentGold,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
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
        child: Icon(Icons.flight_takeoff_rounded,
            color: AppColors.accentOrange, size: 28),
      ),
    );
  }
}

class _HorizontalBuildShimmer extends StatelessWidget {
  const _HorizontalBuildShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
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
    final isDark = ThemeManager.instance.isDark;

    return Image.asset(
      'assets/logo-removebg-preview.png',
      height: 40,
      fit: BoxFit.contain,
      color: isDark ? Colors.white : null,
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
    );
  }
}
