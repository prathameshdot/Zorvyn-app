import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zorvyn/services/local_storage_service.dart';

// Dark mode state notifier
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier()
      : super(LocalStorageService.getDarkMode() ? ThemeMode.dark : ThemeMode.light);

  bool get isDark => state == ThemeMode.dark;

  Future<void> toggle() async {
    final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
    state = newMode;
    await LocalStorageService.setDarkMode(newMode == ThemeMode.dark);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class AppTheme {
  AppTheme._();

  // Brand colors — shared across light/dark
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFFB8B5FF);
  static const Color secondary = Color(0xFF00D2FF);
  static const Color accent = Color(0xFFFF6B6B);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFB74D);
  static const Color error = Color(0xFFEF5350);

  // Light palette
  static const Color bg = Color(0xFFF2F0F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF8F7FC);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFFA0AEC0);
  static const Color divider = Color(0xFFE8E6F0);
  static const Color cardShadowLight = Color(0xFFE8E6F0);
  static const Color cardShadowDark = Color(0xFFD1CFE2);

  // Dark palette
  static const Color bgDark = Color(0xFF121218);
  static const Color surfaceDark = Color(0xFF1E1E2C);
  static const Color surfaceAltDark = Color(0xFF262636);
  static const Color textPrimaryDark = Color(0xFFF0F0F5);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color textHintDark = Color(0xFF6B7280);
  static const Color dividerDark = Color(0xFF2D2D3F);
  static const Color cardShadowLightDark = Color(0xFF0A0A10);
  static const Color cardShadowDarkDark = Color(0xFF000000);

  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  // Legacy accessor kept for backward compatibility
  static ThemeData get theme => lightTheme;

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final bgColor = isDark ? bgDark : bg;
    final surfaceColor = isDark ? surfaceDark : surface;
    final textPrimaryColor = isDark ? textPrimaryDark : textPrimary;
    final textSecondaryColor = isDark ? textSecondaryDark : textSecondary;
    final hintColor = isDark ? textHintDark : textHint;
    final dividerColor = isDark ? dividerDark : divider;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bgColor,
      primaryColor: primary,
      colorScheme: isDark
          ? const ColorScheme.dark(
              primary: primary,
              secondary: secondary,
              error: error,
              surface: surfaceDark,
            )
          : const ColorScheme.light(
              primary: primary,
              secondary: secondary,
              error: error,
              surface: surface,
            ),
      textTheme: GoogleFonts.interTextTheme(
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ).copyWith(
        headlineLarge: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: textPrimaryColor),
        headlineMedium: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600, color: textPrimaryColor),
        headlineSmall: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimaryColor),
        bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: textPrimaryColor),
        bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: textSecondaryColor),
        bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: hintColor),
        labelLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: bgColor,
        foregroundColor: textPrimaryColor,
        titleTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimaryColor),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: error, width: 1),
        ),
        hintStyle: GoogleFonts.inter(color: hintColor, fontSize: 14),
      ),
      dividerColor: dividerColor,
    );
  }

  // Claymorphism helpers — theme-aware
  static BoxDecoration clayCard({Color? color, double radius = 20, bool isDark = false}) {
    final c = color ?? (isDark ? surfaceDark : surface);
    final shadowDk = isDark ? cardShadowDarkDark : cardShadowDark;
    final shadowLt = isDark ? const Color(0xFF2A2A3A) : Colors.white;
    return BoxDecoration(
      color: c,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(color: shadowDk.withValues(alpha: isDark ? 0.5 : 0.3), offset: const Offset(4, 4), blurRadius: 12),
        BoxShadow(color: shadowLt, offset: const Offset(-4, -4), blurRadius: 12),
      ],
    );
  }

  static BoxDecoration clayInset({double radius = 16, bool isDark = false}) {
    final c = isDark ? bgDark : bg;
    final shadowDk = isDark ? cardShadowDarkDark : cardShadowDark;
    final shadowLt = isDark ? const Color(0xFF2A2A3A) : Colors.white;
    return BoxDecoration(
      color: c,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(color: shadowDk.withValues(alpha: isDark ? 0.4 : 0.25), offset: const Offset(2, 2), blurRadius: 6, spreadRadius: -1),
        BoxShadow(color: shadowLt, offset: const Offset(-2, -2), blurRadius: 6, spreadRadius: -1),
      ],
    );
  }
}
