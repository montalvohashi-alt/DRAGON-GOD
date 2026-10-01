import 'package:flutter/material.dart';

/// ThemeManager consumes CSS custom properties from `src/index.css` as its authoritative base
/// and implements dynamic light/dark mode switching for the Flutter application.
///
/// CSS Variable Reference from `src/index.css`:
/// --color-brand-red: #991B1B (Institutional signature: #8B181B)
/// --color-dark-text: #111827 (Dark text on light canvas)
/// --color-muted-text: #6B7280 (Secondary text)
/// --color-border-subtle: #E5E7EB (Subtle borders)
/// --color-card-white: #FFFFFF (Card background light)
/// --color-soft-white: #F9FAFB (App canvas light)
///
/// Dark Mode Mappings from `html.dark`:
/// Canvas background: #121316 (Rich Charcoal)
/// Card surfaces: #1C1917 (Stone-900 surface)
/// Sub-surfaces & Insets: #242220 (Elevated inputs & chips)
/// Hover & Active insets: #292524
/// Dark text primary: #F5F5F4 (Stone-100 high contrast)
/// Dark text muted: #A8A29E (Stone-400)
/// Dark borders: rgba(255, 255, 255, 0.08)
class ThemeManager extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // ==========================================
  // AUTHORITATIVE CSS VARIABLES (Mapped to Dart)
  // ==========================================
  static const Color cssBrandRed = Color(0xFF991B1B);
  static const Color cssBrandRedDeep = Color(0xFF8B181B);
  static const Color cssDarkText = Color(0xFF111827);
  static const Color cssMutedText = Color(0xFF6B7280);
  static const Color cssBorderSubtle = Color(0xFFE5E7EB);
  static const Color cssCardWhite = Color(0xFFFFFFFF);
  static const Color cssSoftWhite = Color(0xFFF9FAFB);

  // Dark Mode Overrides
  static const Color cssCanvasDark = Color(0xFF121316);
  static const Color cssCardDark = Color(0xFF1C1917);
  static const Color cssSubsurfaceDark = Color(0xFF242220);
  static const Color cssElevatedDark = Color(0xFF292524);
  static const Color cssBorderDark = Color(0x14FFFFFF);
  static const Color cssTextPrimaryDark = Color(0xFFF5F5F4);
  static const Color cssTextMutedDark = Color(0xFFA8A29E);

  // Accents
  static const Color cssAccentGold = Color(0xFFD97706);
  static const Color cssAccentGoldDark = Color(0xFFFBBF24);
  static const Color cssVerifiedEmerald = Color(0xFF059669);
  static const Color cssVerifiedEmeraldDark = Color(0xFF34D399);

  // Dynamic getters based on current mode
  Color get brandColor => cssBrandRedDeep;
  Color get canvasColor => isDarkMode ? cssCanvasDark : cssSoftWhite;
  Color get cardColor => isDarkMode ? cssCardDark : cssCardWhite;
  Color get subsurfaceColor => isDarkMode ? cssSubsurfaceDark : const Color(0xFFF3F4F6);
  Color get elevatedColor => isDarkMode ? cssElevatedDark : const Color(0xFFF9FAFB);
  Color get textPrimaryColor => isDarkMode ? cssTextPrimaryDark : cssDarkText;
  Color get textMutedColor => isDarkMode ? cssTextMutedDark : cssMutedText;
  Color get borderColor => isDarkMode ? cssBorderDark : cssBorderSubtle;
  Color get goldAccent => isDarkMode ? cssAccentGoldDark : cssAccentGold;
  Color get emeraldAccent => isDarkMode ? cssVerifiedEmeraldDark : cssVerifiedEmerald;

  // Toggle or switch theme mode
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  // ==========================================
  // MATERIAL 3 LIGHT THEME DATA
  // ==========================================
  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: cssBrandRedDeep,
      scaffoldBackgroundColor: cssSoftWhite,
      colorScheme: const ColorScheme.light(
        primary: cssBrandRedDeep,
        secondary: cssAccentGold,
        surface: cssCardWhite,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: cssDarkText,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: cssDarkText,
        elevation: 0.5,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: cssDarkText,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardColor: cssCardWhite,
      cardTheme: CardThemeData(
        color: cssCardWhite,
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: cssBorderSubtle),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: cssBrandRedDeep,
        unselectedItemColor: cssMutedText,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: const DividerThemeData(
        color: cssBorderSubtle,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: cssBorderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: cssBorderSubtle),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: cssBrandRedDeep, width: 1.5),
        ),
      ),
    );
  }

  // ==========================================
  // MATERIAL 3 DARK THEME DATA
  // ==========================================
  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: cssBrandRedDeep,
      scaffoldBackgroundColor: cssCanvasDark,
      colorScheme: const ColorScheme.dark(
        primary: cssBrandRedDeep,
        secondary: cssAccentGoldDark,
        surface: cssCardDark,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: cssTextPrimaryDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: cssCardDark,
        foregroundColor: cssTextPrimaryDark,
        elevation: 0.5,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: cssTextPrimaryDark,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardColor: cssCardDark,
      cardTheme: CardThemeData(
        color: cssCardDark,
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: cssBorderDark),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cssCardDark,
        selectedItemColor: Color(0xFFFB7185),
        unselectedItemColor: cssTextMutedDark,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: const DividerThemeData(
        color: cssBorderDark,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cssSubsurfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        hintStyle: const TextStyle(color: cssTextMutedDark, fontSize: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: cssBorderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: cssBorderDark),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: cssBrandRedDeep, width: 1.5),
        ),
      ),
    );
  }
}
