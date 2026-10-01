import 'package:flutter/material.dart';

/// ThemeProvider for St. Cecilia's College Global Alumni Association
/// Listens to real-time platform brightness changes and applies the CSS variables
/// (--color-brand-red and charcoal background #121316) defined in src/index.css.
class ThemeProvider extends ChangeNotifier with WidgetsBindingObserver {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider({ThemeMode initialMode = ThemeMode.system}) : _themeMode = initialMode {
    WidgetsBinding.instance.addObserver(this);
  }

  // =========================================================================
  // CSS VARIABLE DEFINITIONS DIRECT FROM src/index.css
  // =========================================================================
  // --color-brand-red: #991B1B (Signature Institutional Crimson: #8B181B)
  static const Color colorBrandRed = Color(0xFF991B1B);
  static const Color colorBrandRedDeep = Color(0xFF8B181B);

  // --color-soft-white / --background in light mode: #F9FAFB
  static const Color colorSoftWhite = Color(0xFFF9FAFB);

  // --color-card-white: #FFFFFF
  static const Color colorCardWhite = Color(0xFFFFFFFF);

  // --color-dark-text: #111827
  static const Color colorDarkText = Color(0xFF111827);

  // --color-muted-text: #6B7280
  static const Color colorMutedText = Color(0xFF6B7280);

  // --color-border-subtle: #E5E7EB
  static const Color colorBorderSubtle = Color(0xFFE5E7EB);

  // =========================================================================
  // DARK MODE MAPPINGS DIRECT FROM html.dark IN src/index.css
  // =========================================================================
  // Charcoal background (html.dark canvas): #121316
  static const Color charcoalBackground = Color(0xFF121316);

  // Stone-900 card surface (html.dark .bg-white): #1C1917
  static const Color cardDark = Color(0xFF1C1917);

  // Subsurfaces, Chips, Insets (html.dark .bg-stone-50): #242220
  static const Color subsurfaceDark = Color(0xFF242220);

  // Elevated insets & hover states: #292524
  static const Color elevatedDark = Color(0xFF292524);

  // Subtle dark border: rgba(255, 255, 255, 0.08)
  static const Color borderDark = Color(0x14FFFFFF);

  // High-contrast primary text (html.dark .text-stone-900): #F5F5F4
  static const Color textPrimaryDark = Color(0xFFF5F5F4);

  // Muted secondary text (html.dark .text-stone-500): #A8A29E
  static const Color textMutedDark = Color(0xFFA8A29E);

  // Institutional Accents
  static const Color accentGold = Color(0xFFD97706);
  static const Color accentGoldDark = Color(0xFFFBBF24);
  static const Color verifiedEmerald = Color(0xFF059669);
  static const Color verifiedEmeraldDark = Color(0xFF34D399);

  // =========================================================================
  // PLATFORM BRIGHTNESS OBSERVATION & STATE
  // =========================================================================
  ThemeMode get themeMode => _themeMode;

  /// Resolves active dark mode state dynamically, taking into account
  /// platform system brightness when mode is ThemeMode.system.
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  @override
  void didChangePlatformBrightness() {
    // Notify listeners if system theme changes while on ThemeMode.system
    if (_themeMode == ThemeMode.system) {
      notifyListeners();
    }
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.system) {
      _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    } else if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  // =========================================================================
  // DYNAMIC CONTEXTUAL COLOR ACCESSORS
  // =========================================================================
  Color get brandColor => colorBrandRedDeep;
  Color get canvasColor => isDarkMode ? charcoalBackground : colorSoftWhite;
  Color get cardColor => isDarkMode ? cardDark : colorCardWhite;
  Color get subsurfaceColor => isDarkMode ? subsurfaceDark : const Color(0xFFF3F4F6);
  Color get elevatedColor => isDarkMode ? elevatedDark : const Color(0xFFF9FAFB);
  Color get textPrimaryColor => isDarkMode ? textPrimaryDark : colorDarkText;
  Color get textMutedColor => isDarkMode ? textMutedDark : colorMutedText;
  Color get borderColor => isDarkMode ? borderDark : colorBorderSubtle;
  Color get goldAccent => isDarkMode ? accentGoldDark : accentGold;
  Color get emeraldAccent => isDarkMode ? verifiedEmeraldDark : verifiedEmerald;

  // =========================================================================
  // MATERIAL 3 LIGHT THEME DATA
  // =========================================================================
  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: colorBrandRedDeep,
      scaffoldBackgroundColor: colorSoftWhite,
      colorScheme: const ColorScheme.light(
        primary: colorBrandRedDeep,
        secondary: accentGold,
        surface: colorCardWhite,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: colorDarkText,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: colorDarkText,
        elevation: 0.5,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: colorDarkText,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardColor: colorCardWhite,
      cardTheme: CardThemeData(
        color: colorCardWhite,
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: colorBorderSubtle),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: colorBrandRedDeep,
        unselectedItemColor: colorMutedText,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: const DividerThemeData(
        color: colorBorderSubtle,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: colorBorderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: colorBorderSubtle),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: colorBrandRedDeep, width: 1.5),
        ),
      ),
    );
  }

  // =========================================================================
  // MATERIAL 3 DARK THEME DATA (Applying Charcoal & Stone-900 mappings)
  // =========================================================================
  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: colorBrandRedDeep,
      scaffoldBackgroundColor: charcoalBackground,
      colorScheme: const ColorScheme.dark(
        primary: colorBrandRedDeep,
        secondary: accentGoldDark,
        surface: cardDark,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: textPrimaryDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: cardDark,
        foregroundColor: textPrimaryDark,
        elevation: 0.5,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: textPrimaryDark,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardColor: cardDark,
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderDark),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardDark,
        selectedItemColor: Color(0xFFFB7185), // Soft high-contrast rose accent
        unselectedItemColor: textMutedDark,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: const DividerThemeData(
        color: borderDark,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: subsurfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        hintStyle: const TextStyle(color: textMutedDark, fontSize: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderDark),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: colorBrandRedDeep, width: 1.5),
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

/// Backwards-compatibility alias for ThemeManager
typedef ThemeManager = ThemeProvider;
