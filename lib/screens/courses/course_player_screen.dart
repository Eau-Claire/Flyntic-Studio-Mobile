import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../core/theme/app_theme.dart';
import '../../models/course.dart';
import '../../models/course_module.dart';
import '../../repositories/course_repository.dart';
import '../../core/language/language_manager.dart';
import '../../core/theme/theme_manager.dart';

class CoursePlayerScreen extends StatefulWidget {
  final Course course;

  const CoursePlayerScreen({super.key, required this.course});

  @override
  State<CoursePlayerScreen> createState() => _CoursePlayerScreenState();
}

class _CoursePlayerScreenState extends State<CoursePlayerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late CourseRepository _courseRepo;
  
  List<CourseModule> _modules = [];
  bool _isLoading = true;
  int _currentModuleIndex = 0;
  
  YoutubePlayerController? _ytController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _courseRepo = CourseRepository(Supabase.instance.client);
    _loadModules();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ytController?.close();
    super.dispose();
  }

  Future<void> _loadModules() async {
    setState(() => _isLoading = true);
    try {
      final list = await _courseRepo.getCourseModules(widget.course.id);
      setState(() {
        _modules = list;
        _isLoading = false;
        _currentModuleIndex = 0;
      });
      if (_modules.isNotEmpty) {
        _initPlayerForModule(_modules[0]);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String? _convertUrlToId(String url) {
    if (url.isEmpty) return null;
    final regExp = RegExp(
      r'^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 2) {
      final id = match.group(2);
      if (id != null && id.length == 11) {
        return id;
      }
    }
    return null;
  }

  void _initPlayerForModule(CourseModule module) {
    final videoUrl = module.videoUrl ?? '';
    final videoId = _convertUrlToId(videoUrl);
    
    if (videoId != null) {
      if (_ytController == null) {
        _ytController = YoutubePlayerController.fromVideoId(
          videoId: videoId,
          autoPlay: true,
          params: const YoutubePlayerParams(
            showControls: true,
            showFullscreenButton: true,
          ),
        );
      } else {
        _ytController!.loadVideoById(videoId: videoId);
      }
      setState(() {});
    } else {
      _ytController?.pauseVideo();
    }
  }

  void _selectModule(int index) {
    if (index < 0 || index >= _modules.length) return;
    setState(() {
      _currentModuleIndex = index;
    });
    _initPlayerForModule(_modules[index]);
    _tabController.animateTo(0); // Switch to content tab
  }

  @override
  Widget build(BuildContext context) {
    final activeModule = _modules.isNotEmpty ? _modules[_currentModuleIndex] : null;

    return ListenableBuilder(
      listenable: Listenable.merge([LanguageManager.instance, ThemeManager.instance]),
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.bgPrimary,
          appBar: AppBar(
            backgroundColor: AppColors.bgSecondary,
            elevation: 0,
            title: Text(
              widget.course.title,
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _modules.isEmpty
                  ? _buildEmptyState()
                  : Column(
                      children: [
                        // Video Player Area
                        _buildPlayerSection(activeModule),
                        
                        // Segmented Tabs
                        Container(
                          color: AppColors.bgSecondary,
                          child: TabBar(
                            controller: _tabController,
                            indicatorColor: AppColors.accentOrange,
                            indicatorSize: TabBarIndicatorSize.tab,
                            labelStyle: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                            labelColor: AppColors.textPrimary,
                            unselectedLabelColor: AppColors.textMuted,
                            dividerColor: AppColors.border,
                            tabs: [
                              Tab(text: LanguageManager.instance.translate('lesson_content')),
                              Tab(text: LanguageManager.instance.translate('syllabus')),
                            ],
                          ),
                        ),
                        
                        // Tab Contents
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildContentTab(activeModule),
                              _buildSyllabusTab(),
                            ],
                          ),
                        ),
                      ],
                    ),
        );
      },
    );
  }

  Widget _buildPlayerSection(CourseModule? module) {
    if (module == null) return const SizedBox();
    
    final videoId = _convertUrlToId(module.videoUrl ?? '');
    
    if (videoId != null && _ytController != null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: YoutubePlayer(
          controller: _ytController!,
        ),
      );
    }

    // Fallback if no video
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: AppColors.bgCard,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.video_library_rounded, color: AppColors.accentGold, size: 48),
              const SizedBox(height: 12),
              Text(
                LanguageManager.instance.translate('no_video'),
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentTab(CourseModule? module) {
    if (module == null) return const SizedBox();
    
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          module.displayTitle,
          style: AppTextStyles.headlineLarge.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                '${LanguageManager.instance.translate('lesson_number')} ${module.order}',
                style: AppTextStyles.labelLarge.copyWith(color: AppColors.accentOrange, fontSize: 11),
              ),
            ),
            if (module.lessonType != null) ...[
              const SizedBox(width: 8),
              Text(
                module.lessonType!.toUpperCase(),
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 11),
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),
        Divider(color: AppColors.border),
        const SizedBox(height: 16),
        MarkdownBody(
          data: module.displayContent,
          styleSheet: MarkdownStyleSheet(
            p: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.6),
            h1: AppTextStyles.titleMedium.copyWith(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold, height: 2),
            h2: AppTextStyles.titleMedium.copyWith(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold, height: 1.8),
            h3: AppTextStyles.titleMedium.copyWith(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold, height: 1.6),
            listBullet: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            code: const TextStyle(backgroundColor: Colors.transparent, fontFamily: 'monospace', color: Colors.amber),
            codeblockPadding: const EdgeInsets.all(12),
            codeblockDecoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSyllabusTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _modules.length,
      itemBuilder: (context, index) {
        final module = _modules[index];
        final isActive = index == _currentModuleIndex;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.bgCard : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isActive ? AppColors.accentOrange : AppColors.border),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isActive ? AppColors.accentOrange.withValues(alpha: 0.1) : AppColors.bgCard,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isActive ? Icons.play_arrow_rounded : Icons.lock_open_rounded,
                color: isActive ? AppColors.accentOrange : AppColors.textMuted,
                size: 18,
              ),
            ),
            title: Text(
              module.displayTitle,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? Colors.white : AppColors.textPrimary,
              ),
            ),
            trailing: Text(
              '${module.order}',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
            ),
            onTap: () => _selectModule(index),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library_rounded, color: AppColors.textMuted, size: 64),
          const SizedBox(height: 16),
          Text(
            LanguageManager.instance.translate('no_lessons_yet'),
            style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            LanguageManager.instance.translate('preparing_material'),
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
