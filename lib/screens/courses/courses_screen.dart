import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_manager.dart';
import '../../models/course.dart';
import '../../repositories/course_repository.dart';
import '../../widgets/course_card.dart';
import '../course_detail/course_detail_screen.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen>
    with TickerProviderStateMixin {
  late CourseRepository _repo;
  late TabController _tabController;

  List<Course> _featuredCourses = [];
  List<Course> _allCourses = [];
  bool _isLoadingFeatured = true;
  bool _isLoadingAll = true;
  bool _hasMoreCourses = true;
  int _currentPage = 0;

  String _searchQuery = '';
  String _selectedLevel = 'all';
  String _sortBy = 'created_at';
  bool _sortAscending = false;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _suggestionOverlay;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _featuredScrollController = ScrollController();

  final List<Map<String, String>> _levels = [
    {'key': 'all', 'label': 'All Levels'},
    {'key': 'beginner', 'label': 'Beginner'},
    {'key': 'intermediate', 'label': 'Intermediate'},
    {'key': 'advanced', 'label': 'Advanced'},
  ];

  @override
  void reassemble() {
    super.reassemble();
    _hideSuggestions();
  }

  @override
  void deactivate() {
    _hideSuggestions();
    super.deactivate();
  }

  @override
  void initState() {
    super.initState();
    _repo = CourseRepository(Supabase.instance.client);
    _tabController = TabController(length: 2, vsync: this);
    _loadFeaturedCourses();
    _loadAllCourses(reset: true);
    _scrollController.addListener(_onScroll);
    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus) {
        _showSuggestions();
      } else {
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) {
            _hideSuggestions();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    _featuredScrollController.dispose();
    _hideSuggestions();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingAll && _hasMoreCourses) {
        _loadAllCourses();
      }
    }
  }

  Future<void> _loadFeaturedCourses() async {
    setState(() => _isLoadingFeatured = true);
    try {
      final courses = await _repo.getFeaturedCourses();
      if (mounted) {
        setState(() {
          _featuredCourses = courses;
          _isLoadingFeatured = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingFeatured = false);
      }
    }
  }

  Future<void> _loadAllCourses({bool reset = false}) async {
    if (reset) {
      setState(() {
        _allCourses = [];
        _currentPage = 0;
        _hasMoreCourses = true;
        _isLoadingAll = true;
      });
    } else {
      setState(() => _isLoadingAll = true);
    }

    try {
      final courses = await _repo.getCourses(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        level: _selectedLevel == 'all' ? null : _selectedLevel,
        sortBy: _sortBy,
        ascending: _sortAscending,
        page: _currentPage,
      );
      if (mounted) {
        setState(() {
          if (reset) {
            _allCourses = courses;
          } else {
            _allCourses.addAll(courses);
          }
          _hasMoreCourses = courses.length >= 12;
          _currentPage++;
          _isLoadingAll = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingAll = false);
      }
    }
  }



  void _onLevelFilter(String level) {
    setState(() => _selectedLevel = level);
    _loadAllCourses(reset: true);
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
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _loadFeaturedCourses();
            await _loadAllCourses(reset: true);
          },
          color: AppColors.accentOrange,
          backgroundColor: AppColors.bgCard,
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildSearchBar(),
              const SizedBox(height: 20),
              if (_searchQuery.isNotEmpty) ...[
                _buildSearchSection(),
              ] else ...[
                _buildAdCard(),
                const SizedBox(height: 24),
                _buildFeaturedSection(),
                const SizedBox(height: 28),
                _buildAllCoursesSection(),
                const SizedBox(height: 100), // Extra spacing for floating bottom nav
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final user = Supabase.instance.client.auth.currentUser;
    final name = user?.userMetadata?['full_name'] as String?;
    final displayName = (name != null && name.isNotEmpty) ? name : (user?.email?.split('@').first ?? 'Learner');
    
    // Format date: e.g. "Today 25 Nov."
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateString = "Today ${now.day} ${months[now.month - 1]}.";

    return Row(
      children: [
        // Greeting texts
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $displayName',
                style: AppTextStyles.headlineLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                dateString,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.border, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
          onChanged: (val) {
            _onSearch(val);
          },
          decoration: InputDecoration(
            hintText: 'Search courses, skills, categories...',
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 16, right: 10),
              child: Icon(Icons.search_rounded, color: AppColors.textMuted, size: 22),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear_rounded, color: AppColors.textMuted, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        _onSearch('');
                      },
                    )
                  : Icon(Icons.mic_none_rounded, color: AppColors.textMuted, size: 20),
            ),
            suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildAdCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: ThemeManager.instance.isDark ? Colors.white24 : Colors.black12,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'SPONSORED',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Angle Mode Drills',
                          style: AppTextStyles.headlineLarge.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Master stable hovering & flight control in real simulation environments.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Navigating to sponsor site...'),
                                backgroundColor: AppColors.textPrimary,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.textPrimary,
                            foregroundColor: AppColors.bgPrimary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          child: const Text(
                            'Learn More',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Simple monochrome ad graphic
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: ThemeManager.instance.isDark ? Colors.white12 : Colors.black12,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.campaign_outlined,
                        size: 36,
                        color: AppColors.textPrimary,
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



  Widget _buildFeaturedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Featured Courses',
              style: AppTextStyles.headlineLarge.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (_featuredScrollController.hasClients) {
                      _featuredScrollController.animateTo(
                        _featuredScrollController.offset - 200,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 3), // Optical alignment
                      child: Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary, size: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    if (_featuredScrollController.hasClients) {
                      _featuredScrollController.animateTo(
                        _featuredScrollController.offset + 200,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textPrimary, size: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        _isLoadingFeatured
            ? SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (_, __) => SizedBox(
                    width: 180,
                    child: const CourseCardShimmer(),
                  ),
                ),
              )
            : _featuredCourses.isEmpty
                ? Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Center(
                      child: Text(
                        'No featured courses available',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                  )
                : SizedBox(
                    height: 220,
                    child: ListView.separated(
                      controller: _featuredScrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: _featuredCourses.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        return SizedBox(
                          width: 195,
                          child: CourseCard(
                            course: _featuredCourses[index],
                            compact: true,
                            onTap: () => _openCourse(_featuredCourses[index]),
                          ),
                        );
                      },
                    ),
                  ),
      ],
    );
  }

  Widget _buildAllCoursesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Explore All Courses',
              style: AppTextStyles.headlineLarge.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            _buildSortButton(),
          ],
        ),
        const SizedBox(height: 14),
        _buildLevelFilter(),
        const SizedBox(height: 16),
        _allCourses.isEmpty && _isLoadingAll
             ? ListView.separated(
                 shrinkWrap: true,
                 primary: false,
                 physics: const NeverScrollableScrollPhysics(),
                 itemCount: 4,
                 separatorBuilder: (_, __) => const SizedBox(height: 14),
                 itemBuilder: (_, __) => const SizedBox(
                   height: 140,
                   child: CourseCardShimmer(),
                 ),
               )
            : _allCourses.isEmpty
                ? Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Center(
                      child: Text(
                        'No courses found for this level',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    primary: false,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _allCourses.length + (_isLoadingAll ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      if (index == _allCourses.length) {
                        return SizedBox(
                          height: 80,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.accentOrange,
                            ),
                          ),
                        );
                      }
                      return SizedBox(
                        height: 140,
                        child: CourseCard(
                          course: _allCourses[index],
                          noImage: true,
                          onTap: () => _openCourse(_allCourses[index]),
                        ),
                      );
                    },
                  ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
              onPressed: () {
                _searchController.clear();
                _onSearch('');
              },
            ),
            const SizedBox(width: 8),
            Text(
              'Search Results',
              style: AppTextStyles.headlineLarge.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _isLoadingAll
            ? ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (_, __) => const SizedBox(
                  height: 140,
                  child: CourseCardShimmer(),
                ),
              )
            : _allCourses.isEmpty
                ? _buildEmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No courses found',
                    subtitle: 'Try another search keyword',
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _allCourses.length + (_isLoadingAll ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      if (index == _allCourses.length) {
                        return SizedBox(
                          height: 80,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.accentOrange,
                            ),
                          ),
                        );
                      }
                      return SizedBox(
                        height: 140,
                        child: CourseCard(
                          course: _allCourses[index],
                          noImage: true,
                          onTap: () => _openCourse(_allCourses[index]),
                        ),
                      );
                    },
                  ),
      ],
    );
  }

  void _onSearch(String value) {
    setState(() => _searchQuery = value);
    _loadAllCourses(reset: true);
    _suggestionOverlay?.markNeedsBuild();
  }

  void _showSuggestions() {
    if (_suggestionOverlay != null) return;

    final overlay = Overlay.of(context);
    _suggestionOverlay = OverlayEntry(
      builder: (context) {
        return Positioned(
          width: MediaQuery.of(context).size.width - 48,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: const Offset(0, 58), // Height of pill search bar + gap
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _getSuggestions().map((suggestion) {
                      return InkWell(
                        onTap: () {
                          _searchController.text = suggestion;
                          _onSearch(suggestion);
                          _searchFocusNode.unfocus();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Icon(Icons.search_rounded, color: AppColors.textMuted, size: 16),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  suggestion,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(_suggestionOverlay!);
  }

  void _hideSuggestions() {
    _suggestionOverlay?.remove();
    _suggestionOverlay = null;
  }

  List<String> _getSuggestions() {
    final query = _searchController.text.trim().toLowerCase();
    final staticSuggestions = [
      'Drone Build Basics',
      'Betaflight Configurator',
      'Arduino Microcontroller',
      'ESC Soldering Techniques',
      'Flight Controller Guide'
    ];

    if (query.isEmpty) {
      return staticSuggestions;
    }

    final matches = _allCourses
        .where((c) => c.title.toLowerCase().contains(query))
        .map((c) => c.title)
        .take(4)
        .toList();

    if (matches.isEmpty) {
      return staticSuggestions
          .where((s) => s.toLowerCase().contains(query))
          .take(4)
          .toList();
    }
    return matches;
  }



  Widget _buildLevelFilter() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _levels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final level = _levels[index];
          final isSelected = _selectedLevel == level['key'];
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: GestureDetector(
              onTap: () => _onLevelFilter(level['key']!),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.accentGradient : null,
                  color: isSelected ? null : AppColors.bgCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : AppColors.border,
                  ),
                ),
                child: Text(
                  level['label']!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isSelected
                        ? (ThemeManager.instance.themeType == ThemeType.monochrome
                            ? AppColors.bgPrimary
                            : Colors.white)
                        : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSortButton() {
    final sortOptions = [
      {'key': 'created_at', 'label': 'Newest', 'ascending': false},
      {'key': 'title', 'label': 'A-Z', 'ascending': true},
      {'key': 'duration_minutes', 'label': 'Duration', 'ascending': true},
    ];

    return PopupMenuButton<Map<String, dynamic>>(
      icon: Icon(Icons.sort_rounded, color: AppColors.textPrimary, size: 20),
      tooltip: 'Sort courses',
      color: AppColors.bgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (option) {
        setState(() {
          _sortBy = option['key'] as String;
          _sortAscending = option['ascending'] as bool;
        });
        _loadAllCourses(reset: true);
      },
      itemBuilder: (context) {
        return sortOptions.map((opt) {
          final isSelected = opt['key'] == _sortBy && opt['ascending'] == _sortAscending;
          return PopupMenuItem<Map<String, dynamic>>(
            value: opt,
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: isSelected ? AppColors.accentOrange : AppColors.textMuted,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  opt['label'] as String,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.bgCard,
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(icon, color: AppColors.textMuted, size: 36),
            ),
            const SizedBox(height: 16),
            Text(title, style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            Text(subtitle, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

