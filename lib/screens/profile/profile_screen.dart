import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_manager.dart';
import '../../widgets/buttons.dart';

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
          const SizedBox(height: 24),
          _buildPastelStatsCards(),
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
          if (_user != null)
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
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: GradientButton(
                label: 'Sign In',
                icon: Icons.login_rounded,
                onPressed: () => _showAuthSheet(context),
              ),
            ),
          const SizedBox(height: 100), // Spacing for floating bottom bar
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final user = _user;
    final email = user?.email ?? 'sandra.glam@example.com';
    final name = user != null ? (user.userMetadata?['full_name'] ?? 'Sandra Glam') : 'Sandra Glam';

    return Column(
      children: [
        Row(
          children: [
            // Round Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 2),
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Name + Location
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    user != null ? email : 'Denmark, Copenhagen',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        // Courses / Builds + Actions Row
        Row(
          children: [
            Row(
              children: [
                Text(
                  'Courses ',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '8',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Row(
              children: [
                Text(
                  'Builds ',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '3',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const Spacer(),
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

  Widget _buildPastelStatsCards() {
    return Row(
      children: [
        _buildStatCard(
          title: 'Flight Hours',
          value: '47.2 hrs',
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          title: 'Builds Done',
          value: '3 drones',
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          title: 'Certificates',
          value: '5 earned',
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
          ],
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

  void _showAuthSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _AuthSheet(),
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
              _SettingsTile('Downloads', 'Wi-Fi Only', Icons.download_outlined, onTap: () {}),
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

class _AuthSheet extends StatefulWidget {
  const _AuthSheet();

  @override
  State<_AuthSheet> createState() => _AuthSheetState();
}

class _AuthSheetState extends State<_AuthSheet> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePass = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 40,
      ),
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
          ShaderMask(
            shaderCallback: (bounds) => AppColors.accentGradient.createShader(bounds),
            child: Text(
              _isLogin ? 'Welcome Back' : 'Create Account',
              style: AppTextStyles.displayMedium.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _isLogin
                ? 'Sign in to continue learning'
                : 'Join thousands of learners',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            style: AppTextStyles.titleMedium,
            decoration: InputDecoration(
              hintText: 'Email address',
              prefixIcon: Icon(Icons.email_outlined, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passCtrl,
            obscureText: _obscurePass,
            style: AppTextStyles.titleMedium,
            decoration: InputDecoration(
              hintText: 'Password',
              prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.textMuted),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppColors.textMuted,
                ),
                onPressed: () => setState(() => _obscurePass = !_obscurePass),
              ),
            ),
          ),
          const SizedBox(height: 16),
          GradientButton(
            label: _isLogin ? 'Sign In' : 'Create Account',
            isLoading: _isLoading,
            width: double.infinity,
            onPressed: _handleAuth,
          ),
          const SizedBox(height: 14),
          Center(
            child: GestureDetector(
              onTap: () => setState(() => _isLogin = !_isLogin),
              child: RichText(
                text: TextSpan(
                  text: _isLogin ? "Don't have an account? " : 'Already have an account? ',
                  style: AppTextStyles.bodySmall,
                  children: [
                    TextSpan(
                      text: _isLogin ? 'Sign Up' : 'Sign In',
                      style: AppTextStyles.accent,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAuth() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        final uri = Uri.parse('https://hnfbtgyaefkagwnlzphu.supabase.co/functions/v1/login');
        final response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': pass}),
        );
        if (response.statusCode != 200) {
          throw Exception('Failed to login (HTTP ${response.statusCode})');
        }
        final data = jsonDecode(response.body);
        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Login failed');
        }
        final refreshToken = data['refresh_token'];
        if (refreshToken == null) {
          throw Exception('No refresh token returned');
        }
        await Supabase.instance.client.auth.setSession(refreshToken);
      } else {
        await Supabase.instance.client.auth.signUp(
          email: email,
          password: pass,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
