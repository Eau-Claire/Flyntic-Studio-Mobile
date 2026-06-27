import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_manager.dart';
import '../../main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? get _user => Supabase.instance.client.auth.currentUser;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isUpdatingEmail = false;
  bool _isUpdatingPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _getInitials(String? name, String email) {
    if (name != null && name.trim().isNotEmpty) {
      final parts = name.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
      }
      return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
    }
    if (email.isNotEmpty) {
      final prefix = email.split('@').first;
      return prefix.substring(0, prefix.length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'US';
  }

  String _getMemberSince(User? user) {
    if (user == null) return '';
    try {
      final createdAtStr = user.createdAt;
      final dt = DateTime.parse(createdAtStr);
      final months = [
        '1', '2', '3', '4', '5', '6',
        '7', '8', '9', '10', '11', '12'
      ];
      return 'Thành viên từ tháng ${months[dt.month - 1]} năm ${dt.year}';
    } catch (e) {
      return 'Thành viên từ năm 2026';
    }
  }

  Future<void> _updateEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showSnackBar('Vui lòng nhập email mới!', isError: true);
      return;
    }
    setState(() => _isUpdatingEmail = true);
    try {
      await Supabase.instance.client.auth.updateUser(UserAttributes(email: email));
      _showSnackBar('Email xác nhận đã được gửi đến $email!');
      _emailController.clear();
    } catch (e) {
      _showSnackBar('Lỗi: $e', isError: true);
    } finally {
      setState(() => _isUpdatingEmail = false);
    }
  }

  Future<void> _updatePassword() async {
    final password = _passwordController.text.trim();
    if (password.length < 8) {
      _showSnackBar('Mật khẩu phải tối thiểu 8 ký tự!', isError: true);
      return;
    }
    setState(() => _isUpdatingPassword = true);
    try {
      await Supabase.instance.client.auth.updateUser(UserAttributes(password: password));
      _showSnackBar('Cập nhật mật khẩu thành công!');
      _passwordController.clear();
    } catch (e) {
      _showSnackBar('Lỗi: $e', isError: true);
    } finally {
      setState(() => _isUpdatingPassword = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.accentOrange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          children: [
            // Page Title Header
            _buildPageHeader(),
            const SizedBox(height: 24),
            
            // Hồ sơ Card
            _buildProfileCard(),
            const SizedBox(height: 20),
            
            // Gói Đăng Ký Card
            _buildSubscriptionCard(),
            const SizedBox(height: 20),
            
            // Học Tập - Khóa học đã hoàn thành Card
            _buildCompletedCoursesCard(),
            const SizedBox(height: 20),
            
            // Cài đặt tài khoản Card
            _buildAccountSettingsCard(),
            const SizedBox(height: 20),
            
            // Cài đặt ứng dụng Card
            _buildAppSettingsCard(),
            const SizedBox(height: 28),
            
            // Đăng xuất Button
            _buildSignOutButton(),
            const SizedBox(height: 100), // padding for floating navigation bar
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'KHÔNG GIAN TÀI KHOẢN',
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.accentOrange,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Hồ sơ của tôi',
          style: AppTextStyles.headlineLarge.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 26,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Quản lý tài khoản, gói đăng ký và tiến độ học tập tại một nơi.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textMuted,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    final user = _user;
    final email = user?.email ?? '';
    final name = user?.userMetadata?['full_name'] as String?;
    final displayName = (name != null && name.isNotEmpty) ? name : (email.split('@').first);
    final initials = _getInitials(name, email);
    final memberSince = _getMemberSince(user);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HỒ SƠ',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Avatar circle
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Color(0xFF0F121F),
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            displayName,
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'MC',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      memberSince,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ĐĂNG KÝ',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSubDetail('Gói', 'Free'),
              ),
              Expanded(
                child: _buildSubDetail('Trạng thái', 'profile'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildSubDetail('Bắt đầu', '1 thg 1, 1970'),
              ),
              Expanded(
                child: _buildSubDetail('Gia hạn', '1 thg 1, 1970'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: AppColors.border),
          const SizedBox(height: 12),
          Text(
            'Tính năng đã bao gồm:',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          _buildFeatureItem('Browse full build catalog'),
          const SizedBox(height: 8),
          _buildFeatureItem('Access documentation'),
          const SizedBox(height: 8),
          _buildFeatureItem('View course previews'),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () async {
              final url = Uri.parse('https://flyntic.site');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            child: Row(
              children: [
                Text(
                  'Quản lý đăng ký',
                  style: TextStyle(
                    color: AppColors.accentOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, color: AppColors.accentOrange, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(String text) {
    return Row(
      children: [
        const Icon(Icons.check_rounded, color: Colors.green, size: 16),
        const SizedBox(width: 8),
        Text(
          text,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildCompletedCoursesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'HỌC TẬP / Khóa học đã hoàn thành',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 0.8,
                ),
              ),
              Icon(Icons.bookmark_added_outlined, color: AppColors.textMuted, size: 18),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: AppColors.border),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Icon(Icons.bookmark_outline_rounded, color: AppColors.textMuted, size: 36),
                const SizedBox(height: 12),
                Text(
                  'Chưa hoàn thành khóa học nào',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                     'Khi bạn hoàn thành toàn bộ bài học trong một khóa, khóa học sẽ xuất hiện tại đây.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    context.findAncestorStateOfType<MainShellState>()?.setSelectedIndex(0);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textPrimary,
                    foregroundColor: AppColors.bgPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text(
                    'Xem khóa học',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CÀI ĐẶT TÀI KHOẢN',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 16),
          
          // Đổi email
          Text(
            'Đổi email',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _emailController,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Địa chỉ email mới',
                    hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    filled: true,
                    fillColor: AppColors.bgPrimary,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.accentOrange),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isUpdatingEmail ? null : _updateEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.border,
                  foregroundColor: AppColors.textPrimary,
                  disabledBackgroundColor: AppColors.border.withValues(alpha: 0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                child: _isUpdatingEmail
                    ? SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textPrimary))
                    : const Text('Cập nhật email', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Đổi mật khẩu
          Text(
            'Đổi mật khẩu',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Mật khẩu mới',
                    hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    filled: true,
                    fillColor: AppColors.bgPrimary,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.accentOrange),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isUpdatingPassword ? null : _updatePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.border,
                  foregroundColor: AppColors.textPrimary,
                  disabledBackgroundColor: AppColors.border.withValues(alpha: 0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                child: _isUpdatingPassword
                    ? SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textPrimary))
                    : const Text('Cập nhật mật khẩu', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Min. 8 characters',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettingsCard() {
    return ListenableBuilder(
      listenable: ThemeManager.instance,
      builder: (context, _) {
        final currentType = ThemeManager.instance.themeType;
        final currentMode = ThemeManager.instance.themeMode;

        String typeStr = currentType == ThemeType.monochrome ? 'Monochrome' : 'Flyntic Classic';
        String modeStr = 'Dark';
        if (currentMode == ThemeMode.system) modeStr = 'System';
        if (currentMode == ThemeMode.light) modeStr = 'Light';

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CÀI ĐẶT ỨNG DỤNG',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 16),
              _buildSettingsTile(
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
              const SizedBox(height: 8),
              _buildSettingsTile(
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
              const SizedBox(height: 8),
              _buildSettingsTile(
                'Language',
                'English',
                Icons.language_rounded,
                onTap: () {},
              ),
              const SizedBox(height: 8),
              _buildSettingsTile(
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

  Widget _buildSettingsTile(String label, String value, IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bgPrimary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accentOrange, size: 18),
            const SizedBox(width: 12),
            Text(label, style: AppTextStyles.titleMedium.copyWith(fontSize: 13, fontWeight: FontWeight.bold)),
            const Spacer(),
            Text(value, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSignOutButton() {
    return GestureDetector(
      onTap: () => _confirmSignOut(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
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
