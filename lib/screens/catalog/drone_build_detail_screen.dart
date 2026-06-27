import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_manager.dart';
import '../../core/language/language_manager.dart';
import '../../models/drone_build.dart';

class DroneBuildDetailScreen extends StatefulWidget {
  final DroneBuild build;

  const DroneBuildDetailScreen({super.key, required this.build});

  @override
  State<DroneBuildDetailScreen> createState() => _DroneBuildDetailScreenState();
}

class _DroneBuildDetailScreenState extends State<DroneBuildDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buildItem = widget.build;
    return ListenableBuilder(
      listenable: Listenable.merge([LanguageManager.instance, ThemeManager.instance]),
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.bgPrimary,
          body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 280,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.bgPrimary,
              elevation: 0,
              leading: Container(
                margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    buildItem.thumbnailUrl.isNotEmpty
                        ? Image.network(
                            buildItem.thumbnailUrl,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: const Color(0xFF1F2B47),
                            child: Icon(Icons.flight_takeoff_rounded,
                                color: AppColors.accentOrange, size: 64),
                          ),
                    // Gradient overlay for readability
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black54,
                            Colors.transparent,
                            Color(0x99000000),
                            Color(0xFF070913),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.0, 0.4, 0.8, 1.0],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accentOrange,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              buildItem.formattedDifficulty,
                              style: AppTextStyles.labelLarge.copyWith(
                                color: ThemeManager.instance.themeType == ThemeType.monochrome
                                    ? AppColors.accentOrangeText
                                    : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            buildItem.name,
                            style: AppTextStyles.headlineLarge.copyWith(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: Column(
          children: [
            // Stats Row card
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(Icons.payments_rounded, LanguageManager.instance.translate('est_cost'), buildItem.formattedCost),
                    _buildDivider(),
                    _buildStatItem(Icons.timer_rounded, LanguageManager.instance.translate('flight_time'),
                        buildItem.flightTime.isNotEmpty ? buildItem.flightTime : 'N/A'),
                    _buildDivider(),
                    _buildStatItem(Icons.rocket_launch_rounded, LanguageManager.instance.translate('category'),
                        buildItem.useCase.isNotEmpty ? buildItem.useCase : 'FPV'),
                  ],
                ),
              ),
            ),
            // Segmented TabBar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                labelColor: ThemeManager.instance.themeType == ThemeType.monochrome
                    ? (ThemeManager.instance.isDark ? Colors.black : Colors.white)
                    : Colors.white,
                unselectedLabelColor: AppColors.textMuted,
                dividerColor: Colors.transparent,
                padding: const EdgeInsets.all(4),
                tabs: [
                  Tab(text: LanguageManager.instance.translate('tab_overview')),
                  Tab(text: LanguageManager.instance.translate('tab_steps')),
                  Tab(text: LanguageManager.instance.translate('tab_wires')),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Tab Contents
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildStepsTab(),
                  _buildWiresTab(),
                ],
              ),
            ),
          ],
        ),
      ),
        );
      },
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppColors.accentOrange, size: 20),
        const SizedBox(height: 6),
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 10)),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.titleMedium.copyWith(fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 36,
      color: AppColors.border,
    );
  }

  Widget _buildOverviewTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      children: [
        Text(LanguageManager.instance.translate('about_build'), style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text(
          widget.build.description.isNotEmpty
              ? widget.build.description
              : (LanguageManager.instance.isVietnamese
                  ? 'Không có mô tả cho cấu hình drone này.'
                  : 'No description provided for this drone assembly template.'),
          style: AppTextStyles.bodyMedium.copyWith(height: 1.5, color: AppColors.textSecondary),
        ),
        if (widget.build.productIds.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(LanguageManager.instance.translate('components_list'), style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.build.productIds.map((id) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shopping_bag_outlined, color: AppColors.accentGold, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      id,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildStepsTab() {
    final steps = widget.build.steps;
    if (steps.isEmpty) {
      return _buildEmptyTabState(
        Icons.rule_rounded,
        LanguageManager.instance.isVietnamese ? 'Không có bước lắp ráp' : 'No Assembly Steps',
        LanguageManager.instance.isVietnamese
            ? 'Hướng dẫn này chưa cập nhật các bước lắp ráp.'
            : 'This guide does not specify assembly steps yet.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        final step = steps[index];
        final isVi = LanguageManager.instance.isVietnamese;
        final title = isVi
            ? (step['title_vi']?.toString() ?? step['title']?.toString() ?? 'Bước ${index + 1}')
            : (step['title']?.toString() ?? 'Step ${index + 1}');
        final desc = isVi
            ? (step['description_vi']?.toString() ?? step['description']?.toString() ?? '')
            : (step['description']?.toString() ?? '');
        final imgUrl = step['image_url']?.toString();

        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline line and circle
              Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: AppColors.accentGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                  if (index != steps.length - 1)
                    Container(
                      width: 2,
                      height: imgUrl != null ? 180 : 80,
                      color: AppColors.border,
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // Step Content card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        desc,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.4),
                      ),
                      if (imgUrl != null && imgUrl.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            imgUrl,
                            fit: BoxFit.cover,
                            height: 120,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => const SizedBox(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWiresTab() {
    final wires = widget.build.wires;
    if (wires.isEmpty) {
      return _buildEmptyTabState(
        Icons.cable_rounded,
        LanguageManager.instance.isVietnamese ? 'Không có sơ đồ dây' : 'No Wiring Guide',
        LanguageManager.instance.isVietnamese
            ? 'Hướng dẫn này chưa cập nhật sơ đồ đi dây.'
            : 'This guide does not specify custom wiring steps.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      itemCount: wires.length,
      itemBuilder: (context, index) {
        final wire = wires[index];
        final isVi = LanguageManager.instance.isVietnamese;
        final title = isVi
            ? (wire['title_vi']?.toString() ?? wire['title']?.toString() ?? 'Sơ đồ đi dây ${index + 1}')
            : (wire['title']?.toString() ?? 'Wiring Diagram ${index + 1}');
        final desc = isVi
            ? (wire['description_vi']?.toString() ?? wire['description']?.toString() ?? '')
            : (wire['description']?.toString() ?? '');
        final imgUrl = wire['image_url']?.toString();

        return Card(
          color: AppColors.bgCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.border),
          ),
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.cable_rounded, color: AppColors.accentOrange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  desc,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.4),
                ),
                if (imgUrl != null && imgUrl.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imgUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyTabState(IconData icon, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.textMuted, size: 48),
          const SizedBox(height: 16),
          Text(title, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
