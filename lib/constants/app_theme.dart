import 'package:flutter/material.dart';

extension ThemeColors on BuildContext {
  Color get themeBackground => Theme.of(this).scaffoldBackgroundColor;
  Color get themeCard => Theme.of(this).colorScheme.surface;
  Color get themeTextDark => Theme.of(this).textTheme.bodyLarge!.color!;
  Color get themeTextLight => Theme.of(this).textTheme.bodyMedium!.color!;
  Color get themeBorder => Theme.of(this).dividerColor;
  Color get themePrimary => Theme.of(this).colorScheme.primary;
  Color get themeSecondary => Theme.of(this).colorScheme.secondary;
}

class AppColors {
  // Primary Colors (Defaults)
  static const Color primary = Color(0xFF10B981);
  static const Color secondary = Color(0xFF059669);
  static const Color accent = Color(0xFFF59E0B);

  // Light Theme
  static const Color background = Color(0xFFECFDF5);
  static const Color card = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textDark = Color(0xFF111827);
  static const Color textLight = Color(0xFF6B7280);

  // Borders
  static const Color border = Color(0xFFE2E8F0);

  // Category Colors
  static const Color food = Colors.orange;
  static const Color travel = Colors.blue;
  static const Color shopping = Colors.purple;
  static const Color bills = Colors.red;
  static const Color farming = Colors.green;
  static const Color salary = Color(0xFF10B981);

  // Dark Theme
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkCard = Color(0xFF1E293B);

  // Button Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);

  // bottomsheet
  static const Color bottomSheet = Color(0xFFF8FAFC);
  static const Color bottomSheetDark = Color(0xFF1E293B);

  static const Color income = Color(0xFF10B981);
}

class AppTheme {
  static ThemeData getLightTheme(Color primary) {
    final scaffoldBg = Color.alphaBlend(
      primary.withValues(alpha: 0.10),
      Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      brightness: Brightness.light,
      scaffoldBackgroundColor: scaffoldBg,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary:
            primary, // Using primary as secondary for simplicity, or slightly darken
        surface: AppColors.card,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: .w600,
          color: AppColors.textDark,
          fontFamily: 'Poppins',
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 1,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: .circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const .symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: .circular(16)),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: .w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: AppColors.textDark),
        bodyMedium: TextStyle(fontSize: 14, color: AppColors.textLight),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      dividerColor: AppColors.border,
    );
  }

  static ThemeData getDarkTheme(Color primary) {
    final scaffoldBg = Color.alphaBlend(
      primary.withValues(alpha: 0.10),
      AppColors.darkBackground,
    );
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      brightness: Brightness.dark,
      scaffoldBackgroundColor: scaffoldBg,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: primary,
        surface: AppColors.darkCard,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.bottomSheetDark,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.white70),
      ),
    );
  }
}
