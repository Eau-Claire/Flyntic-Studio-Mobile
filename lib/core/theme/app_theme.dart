import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_manager.dart';

class AppColors {
  static ThemeType get currentTheme => ThemeManager.instance.themeType;
  static bool get isDark => ThemeManager.instance.isDark;

  static Color get bgPrimary {
    if (currentTheme == ThemeType.monochrome) {
      return isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
    }
    return isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF8FAFC);
  }

  static Color get bgSecondary {
    if (currentTheme == ThemeType.monochrome) {
      return isDark ? const Color(0xFF0C0C0C) : const Color(0xFFF3F4F6);
    }
    return isDark ? const Color(0xFF111827) : const Color(0xFFFFFFFF);
  }

  static Color get bgCard {
    if (currentTheme == ThemeType.monochrome) {
      return isDark ? const Color(0xFF161616) : const Color(0xFFF9FAFB);
    }
    return isDark ? const Color(0xFF1A2236) : const Color(0xFFFFFFFF);
  }

  static Color get bgCardHover {
    if (currentTheme == ThemeType.monochrome) {
      return isDark ? const Color(0xFF222222) : const Color(0xFFF3F4F6);
    }
    return isDark ? const Color(0xFF1E2A42) : const Color(0xFFF1F5F9);
  }

  static Color get accentOrange {
    if (currentTheme == ThemeType.monochrome) {
      return isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
    }
    return const Color(0xFFFF6B35);
  }

  static Color get accentAmber {
    if (currentTheme == ThemeType.monochrome) {
      return isDark ? const Color(0xFFE5E5E5) : const Color(0xFF262626);
    }
    return const Color(0xFFFFAB00);
  }

  static Color get accentGold {
    if (currentTheme == ThemeType.monochrome) {
      return isDark ? const Color(0xFFD4D4D4) : const Color(0xFF404040);
    }
    return const Color(0xFFF59E0B);
  }

  static Color get textPrimary {
    return isDark ? const Color(0xFFFFFFFF) : const Color(0xFF0F172A);
  }

  static Color get textSecondary {
    return isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
  }

  static Color get textMuted {
    return isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
  }

  static Color get border {
    if (currentTheme == ThemeType.monochrome) {
      return isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE5E7EB);
    }
    return isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
  }

  static Color get borderLight {
    if (currentTheme == ThemeType.monochrome) {
      return isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF3F4F6);
    }
    return isDark ? const Color(0xFF2D3A52) : const Color(0xFFF1F5F9);
  }

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  static LinearGradient get accentGradient => currentTheme == ThemeType.monochrome
      ? LinearGradient(
          colors: isDark 
              ? [const Color(0xFFFFFFFF), const Color(0xFFFFFFFF)]
              : [const Color(0xFF000000), const Color(0xFF000000)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        )
      : const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFFAB00)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );

  static LinearGradient get bgGradient => LinearGradient(
        colors: currentTheme == ThemeType.monochrome
            ? [bgPrimary, bgPrimary]
            : [bgPrimary, bgSecondary],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  static LinearGradient get cardGradient => LinearGradient(
        colors: currentTheme == ThemeType.monochrome
            ? [bgCard, bgCard]
            : [bgCard, isDark ? const Color(0xFF0F1729) : const Color(0xFFF8FAFC)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get heroGradient => LinearGradient(
        colors: currentTheme == ThemeType.monochrome
            ? [bgPrimary, bgPrimary]
            : [bgPrimary, isDark ? const Color(0xFF1A1040) : const Color(0xFFEEF2F6), bgPrimary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}

class AppTextStyles {
  static TextStyle get displayLarge => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      );

  static TextStyle get displayMedium => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
      );

  static TextStyle get headlineLarge => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineMedium => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleMedium => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
      );

  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.1,
      );

  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
      );

  static TextStyle get accent => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.accentOrange,
      );
}

class AppTheme {
  static ThemeData get currentThemeData {
    final isDark = ThemeManager.instance.isDark;
    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: AppColors.bgPrimary,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: AppColors.accentOrange,
        onPrimary: isDark ? Colors.black : Colors.white,
        secondary: AppColors.accentAmber,
        onSecondary: isDark ? Colors.black : Colors.white,
        surface: AppColors.bgCard,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTextStyles.headlineMedium,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgSecondary,
        selectedItemColor: AppColors.accentOrange,
        unselectedItemColor: AppColors.textMuted,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.border,
        space: 1,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.accentOrange, width: 2),
        ),
        hintStyle: AppTextStyles.bodyMedium,
        labelStyle: AppTextStyles.bodyMedium,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.bgCard,
        selectedColor: AppColors.accentOrange.withOpacity(0.2),
        labelStyle: AppTextStyles.bodySmall,
        side: BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }
}
