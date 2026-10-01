import 'package:flutter/material.dart';

/// Shared Design System & Color Palette for St. Cecilia's College
/// Maps 1:1 to CSS Custom Properties defined in src/index.css
class AppColors {
  // CSS Custom Properties: Direct mappings to web index.css
  // --color-brand-red: #991B1B
  static const Color brandRed = Color(0xFF991B1B);
  // Institutional Signature Crimson: #8B181B
  static const Color brandRedDeep = Color(0xFF8B181B);
  // --color-dark-text: #111827
  static const Color darkText = Color(0xFF111827);
  // --color-muted-text: #6B7280
  static const Color mutedText = Color(0xFF6B7280);
  // --color-border-subtle: #E5E7EB
  static const Color borderSubtle = Color(0xFFE5E7EB);
  // --color-card-white: #FFFFFF
  static const Color cardWhite = Color(0xFFFFFFFF);
  // --color-soft-white: #F9FAFB (maps to --background in light mode)
  static const Color softWhite = Color(0xFFF9FAFB);

  // Secondary Accents
  static const Color accentGold = Color(0xFFD97706);
  static const Color verifiedEmerald = Color(0xFF059669);
  static const Color urgentRed = Color(0xFFE11D48);

  // ========================================================
  // DARK MODE TOKENS (Mapping directly to html.dark in index.css)
  // ========================================================
  // Canvas: #121316 (Rich Charcoal Canvas)
  static const Color backgroundDark = Color(0xFF121316);
  // Cards & Panels: #1C1917 (Stone-900 Card Surface)
  static const Color cardDark = Color(0xFF1C1917);
  // Sub-surfaces & Insets: #242220
  static const Color subsurfaceDark = Color(0xFF242220);
  // Elevated hover / dialog surfaces: #292524
  static const Color elevatedDark = Color(0xFF292524);
  // Subtle border in dark mode: rgba(255, 255, 255, 0.08)
  static const Color borderDark = Color(0x14FFFFFF);
  // Typography in dark mode: #F5F5F4 (High-contrast Stone-100)
  static const Color textPrimaryDark = Color(0xFFF5F5F4);
  // Muted text in dark mode: #A8A29E (Stone-400)
  static const Color textMutedDark = Color(0xFFA8A29E);

  // Accents in dark mode
  static const Color accentGoldDark = Color(0xFFFBBF24);
  static const Color verifiedEmeraldDark = Color(0xFF34D399);
}

/// Extension for convenient, context-aware color access
extension AppThemeContext on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get brandColor => AppColors.brandRedDeep;
  Color get canvasColor => isDarkMode ? AppColors.backgroundDark : AppColors.softWhite;
  Color get surfaceColor => isDarkMode ? AppColors.cardDark : AppColors.cardWhite;
  Color get subsurfaceColor => isDarkMode ? AppColors.subsurfaceDark : const Color(0xFFF3F4F6);
  Color get elevatedColor => isDarkMode ? AppColors.elevatedDark : const Color(0xFFF9FAFB);
  Color get textPrimaryColor => isDarkMode ? AppColors.textPrimaryDark : AppColors.darkText;
  Color get textMutedColor => isDarkMode ? AppColors.textMutedDark : AppColors.mutedText;
  Color get borderColor => isDarkMode ? AppColors.borderDark : AppColors.borderSubtle;
  Color get goldAccent => isDarkMode ? AppColors.accentGoldDark : AppColors.accentGold;
  Color get emeraldAccent => isDarkMode ? AppColors.verifiedEmeraldDark : AppColors.verifiedEmerald;
}

class AppTheme {
  /// Light Theme matching web light mode (--background: #F9FAFB, cards: #FFFFFF, borders: #E5E7EB)
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.brandRedDeep,
    scaffoldBackgroundColor: AppColors.softWhite,
    colorScheme: const ColorScheme.light(
      primary: AppColors.brandRedDeep,
      secondary: AppColors.accentGold,
      surface: AppColors.cardWhite,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.darkText,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.darkText,
      elevation: 0.5,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: AppColors.darkText,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardColor: AppColors.cardWhite,
    cardTheme: CardThemeData(
      color: AppColors.cardWhite,
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderSubtle),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.brandRedDeep,
      unselectedItemColor: AppColors.mutedText,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.borderSubtle,
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderSubtle),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderSubtle),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: AppColors.brandRedDeep, width: 1.5),
      ),
    ),
  );

  /// Dark Theme matching web dark mode (--background: #121316, cards: #1C1917, text: #F5F5F4)
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.brandRedDeep,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.brandRedDeep,
      secondary: AppColors.accentGoldDark,
      surface: AppColors.cardDark,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: AppColors.textPrimaryDark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.cardDark,
      foregroundColor: AppColors.textPrimaryDark,
      elevation: 0.5,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimaryDark,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardColor: AppColors.cardDark,
    cardTheme: CardThemeData(
      color: AppColors.cardDark,
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderDark),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.cardDark,
      selectedItemColor: Color(0xFFFB7185), // Soft high-contrast rose in dark mode
      unselectedItemColor: AppColors.textMutedDark,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.borderDark,
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.subsurfaceDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      hintStyle: const TextStyle(color: AppColors.textMutedDark, fontSize: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: AppColors.brandRedDeep, width: 1.5),
      ),
    ),
  );
}
