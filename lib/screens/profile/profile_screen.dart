import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_manager.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? get _user => Supabase.instance.client.auth.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Profile',
          style: AppTextStyles.headlineMedium.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: -0.4,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: AppColors.textPrimary),
            onPressed: () => _showSettings(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 32),
          _buildMenuSection('Learning', [
            _MenuItemData(Icons.flight_rounded, 'My Courses', 'Enrolled drone courses', () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Opening My Courses...'), behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.accentOrange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                duration: const Duration(seconds: 1),
              ));
            }),
            _MenuItemData(Icons.construction_rounded, 'My Builds', 'Drone assembly projects', () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Opening My Builds...'), behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.accentOrange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                duration: const Duration(seconds: 1),
              ));
            }),
            _MenuItemData(Icons.analytics_outlined, 'Flight Log', 'Track your flight hours', () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Opening Flight Log...'), behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.accentOrange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                duration: const Duration(seconds: 1),
              ));
            }),
            _MenuItemData(Icons.workspace_premium_outlined, 'Certificates', 'Pilot licenses & badges', () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Opening Certificates...'), behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.accentOrange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                duration: const Duration(seconds: 1),
              ));
            }),
          ]),
          const SizedBox(height: 24),
          _buildMenuSection('Account', [
            _MenuItemData(Icons.person_outline_rounded, 'Edit Profile', 'Update your information', () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Edit Profile coming soon...'), behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.accentOrange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                duration: const Duration(seconds: 1),
              ));
            }),
            _MenuItemData(Icons.credit_card_outlined, 'Payment Methods', 'Manage cards & wallets', () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Payment Methods coming soon...'), behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.accentOrange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                duration: const Duration(seconds: 1),
              ));
            }),
            _MenuItemData(Icons.receipt_outlined, 'Purchase History', 'View transactions', () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Purchase History coming soon...'), behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.accentOrange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                duration: const Duration(seconds: 1),
              ));
            }),
            _MenuItemData(Icons.notifications_none_rounded, 'Notifications', 'Manage alerts', () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Notifications coming soon...'), behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.accentOrange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                duration: const Duration(seconds: 1),
              ));
            }),
          ]),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: () => _confirmSignOut(context),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.error.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                  const SizedBox(width: 12),
                  Text('Sign Out', style: AppTextStyles.titleMedium.copyWith(color: AppColors.error)),
                  const Spacer(),
                  Icon(Icons.chevron_right_rounded, color: AppColors.error, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 100), // Spacing for floating bottom bar
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final user = _user;
    final email = user?.email ?? '';
    final name = user?.userMetadata?['full_name'] as String?;

    return Column(
      children: [
        Row(
          children: [
            // Name + Location
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (name != null && name.isNotEmpty) ...[
                    Text(
                      name,
                      style: AppTextStyles.headlineLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ] else ...[
                    Text(
                      email,
                      style: AppTextStyles.headlineLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        // Actions Row
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildCircleOutlineBtn(Icons.ios_share_rounded, () {}),
            const SizedBox(width: 10),
            _buildCircleOutlineBtn(Icons.edit_outlined, () {}),
          ],
        ),
      ],
    );
  }

  Widget _buildCircleOutlineBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Icon(icon, color: AppColors.textPrimary, size: 16),
        ),
      ),
    );
  }

  Widget _buildMenuSection(String title, List<_MenuItemData> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.headlineLarge.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.border.withOpacity(0.5)),
          itemBuilder: (context, index) {
            return _buildMenuItem(items[index]);
          },
        ),
      ],
    );
  }

  Widget _buildMenuItem(_MenuItemData item) {
    return GestureDetector(
      onTap: item.onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            // Circular icon outline
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: Center(
                child: Icon(item.icon, color: AppColors.textPrimary, size: 18),
              ),
            ),
            const SizedBox(width: 14),
            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _SettingsSheet(),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sign Out', style: AppTextStyles.headlineMedium),
        content: Text(
          'Are you sure you want to sign out?',
          style: AppTextStyles.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTextStyles.bodyMedium),
          ),
          GestureDetector(
            onTap: () async {
              Navigator.pop(context);
              await Supabase.instance.client.auth.signOut();
              if (mounted) setState(() {});
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Sign Out',
                style: AppTextStyles.labelLarge.copyWith(
                  color: ThemeManager.instance.themeType == ThemeType.monochrome
                      ? AppColors.bgPrimary
                      : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class _MenuItemData {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  _MenuItemData(this.icon, this.label, this.subtitle, this.onTap);
}

class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeManager.instance,
      builder: (context, _) {
        final currentType = ThemeManager.instance.themeType;
        final currentMode = ThemeManager.instance.themeMode;

        String typeStr = currentType == ThemeType.monochrome ? 'Monochrome' : 'Flyntic Classic';
        String modeStr = 'Dark';
        if (currentMode == ThemeMode.system) modeStr = 'System';
        if (currentMode == ThemeMode.light) modeStr = 'Light';

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Settings', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 16),
              _SettingsTile(
                'Theme Palette',
                typeStr,
                Icons.palette_outlined,
                onTap: () {
                  final nextType = currentType == ThemeType.monochrome
                      ? ThemeType.classic
                      : ThemeType.monochrome;
                  ThemeManager.instance.setThemeType(nextType);
                },
              ),
              _SettingsTile(
                'Theme Mode',
                modeStr,
                Icons.dark_mode_outlined,
                onTap: () {
                  ThemeMode nextMode;
                  if (currentMode == ThemeMode.dark) {
                    nextMode = ThemeMode.light;
                  } else if (currentMode == ThemeMode.light) {
                    nextMode = ThemeMode.system;
                  } else {
                    nextMode = ThemeMode.dark;
                  }
                  ThemeManager.instance.setThemeMode(nextMode);
                },
              ),
              _SettingsTile('Language', 'English', Icons.language_rounded, onTap: () {}),
              _SettingsTile(
                'Downloads App',
                'flyntic.site',
                Icons.download_outlined,
                onTap: () async {
                  final url = Uri.parse('https://flyntic.site');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  const _SettingsTile(this.label, this.value, this.icon, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accentOrange, size: 18),
            const SizedBox(width: 12),
            Text(label, style: AppTextStyles.titleMedium.copyWith(fontSize: 14)),
            const Spacer(),
            Text(value, style: AppTextStyles.bodySmall),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 16),
          ],
        ),
      ),
    );
  }
}
