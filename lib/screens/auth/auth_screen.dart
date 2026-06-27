import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_manager.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePass = true;
  bool _obscureConfirmPass = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    final confirmPass = _confirmPassCtrl.text.trim();

    if (email.isEmpty) {
      _showError('Vui lòng nhập địa chỉ email');
      return;
    }
    if (pass.isEmpty) {
      _showError('Vui lòng nhập mật khẩu');
      return;
    }
    if (!_isLogin) {
      if (confirmPass.isEmpty) {
        _showError('Vui lòng xác nhận mật khẩu');
        return;
      }
      if (pass != confirmPass) {
        _showError('Mật khẩu xác nhận không trùng khớp!');
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: pass,
        );
      } else {
        await Supabase.instance.client.auth.signUp(
          email: email,
          password: pass,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Đăng ký thành công! Vui lòng đăng nhập.'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          setState(() {
            _isLogin = true;
            _passCtrl.clear();
            _confirmPassCtrl.clear();
          });
        }
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    bool isPassword = false,
    bool isDark = false,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onToggleVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.textPrimary,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.textMuted.withValues(alpha: 0.8),
            fontSize: 13,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark ? AppColors.border : Colors.grey.shade200,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.accentOrange,
              width: 1.5,
            ),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    final isMonochrome = ThemeManager.instance.themeType == ThemeType.monochrome;

    final decoration = isMonochrome
        ? BoxDecoration(
            color: AppColors.accentOrange,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentOrange.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          )
        : BoxDecoration(
            gradient: AppColors.accentGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentOrange.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          );

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Container(
        decoration: decoration,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleAuth,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: AppColors.accentOrangeText,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: _isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.accentOrangeText,
                  ),
                )
              : Text(
                  _isLogin ? 'Sign In' : 'Sign up',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.instance.isDark;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Stack(
          children: [
            // Back button at top-left for Sign Up screen
            if (!_isLogin)
              Positioned(
                top: 10,
                left: 10,
                child: IconButton(
                  icon: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                  onPressed: () {
                    setState(() {
                      _isLogin = true;
                    });
                  },
                ),
              ),
            
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Flyntic Logo
                    Container(
                      height: 80,
                      width: 280,
                      alignment: Alignment.center,
                      child: OverflowBox(
                        minWidth: 340,
                        maxWidth: 340,
                        minHeight: 340,
                        maxHeight: 340,
                        child: Image.asset(
                          'assets/flyntic.png',
                          fit: BoxFit.contain,
                          color: isDark ? Colors.white : null,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: AppColors.accentGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.flight_takeoff_rounded,
                              color: ThemeManager.instance.themeType == ThemeType.monochrome
                                  ? AppColors.bgPrimary
                                  : Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      _isLogin ? 'Login to your Account' : 'Create your Account',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Input Form Fields Container
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Email Field
                        _buildInputField(
                          controller: _emailCtrl,
                          hintText: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        _buildInputField(
                          controller: _passCtrl,
                          hintText: 'Password',
                          obscureText: _obscurePass,
                          isPassword: true,
                          isDark: isDark,
                          onToggleVisibility: () {
                            setState(() => _obscurePass = !_obscurePass);
                          },
                        ),

                        // Confirm Password Field (Only for Sign Up)
                        if (!_isLogin) ...[
                          const SizedBox(height: 16),
                          _buildInputField(
                            controller: _confirmPassCtrl,
                            hintText: 'Confirm Password',
                            obscureText: _obscureConfirmPass,
                            isPassword: true,
                            isDark: isDark,
                            onToggleVisibility: () {
                              setState(() => _obscureConfirmPass = !_obscureConfirmPass);
                            },
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Primary Action Button
                    _buildActionButton(),
                    const SizedBox(height: 40),

                    // Footer Link
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                      child: RichText(
                        text: TextSpan(
                          text: _isLogin
                              ? "Don't have an account? "
                              : 'Already have an account? ',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                          children: [
                            TextSpan(
                              text: _isLogin ? 'Sign up' : 'Sign In',
                              style: TextStyle(
                                color: ThemeManager.instance.themeType == ThemeType.monochrome
                                    ? AppColors.textPrimary
                                    : AppColors.accentOrange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
