import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract final class NewUiTheme {
  static const Color _brandPrimary = Color(0xFF00A6FF);

  static ThemeMode resolveMode(int legacyMode) {
    return switch (legacyMode) {
      0 => ThemeMode.light,
      1 => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  static ThemeData light() => _build(
        brightness: Brightness.light,
        scheme: const ColorScheme(
          brightness: Brightness.light,
          primary: _brandPrimary,
          onPrimary: Color(0xFF001E2B),
          primaryContainer: Color(0xFFCDEBFF),
          onPrimaryContainer: Color(0xFF00344F),
          secondary: Color(0xFF526A78),
          onSecondary: Color(0xFFFFFFFF),
          secondaryContainer: Color(0xFFD6E6EE),
          onSecondaryContainer: Color(0xFF273741),
          tertiary: Color(0xFF5E6670),
          onTertiary: Color(0xFFFFFFFF),
          tertiaryContainer: Color(0xFFE0E5EA),
          onTertiaryContainer: Color(0xFF30363C),
          error: Color(0xFFB3261E),
          onError: Color(0xFFFFFFFF),
          errorContainer: Color(0xFFF9DEDC),
          onErrorContainer: Color(0xFF410E0B),
          surface: Color(0xFFF6F9FB),
          onSurface: Color(0xFF172126),
          surfaceContainerLowest: Color(0xFFFFFFFF),
          surfaceContainerLow: Color(0xFFF0F5F8),
          surfaceContainer: Color(0xFFEAF1F5),
          surfaceContainerHigh: Color(0xFFE4ECF1),
          surfaceContainerHighest: Color(0xFFDDE6EC),
          onSurfaceVariant: Color(0xFF44515A),
          outline: Color(0xFF73818A),
          outlineVariant: Color(0xFFC3CED5),
          inverseSurface: Color(0xFF2C3134),
          onInverseSurface: Color(0xFFF0F3F5),
          inversePrimary: Color(0xFF6CC5FF),
          scrim: Color(0xFF000000),
          surfaceTint: _brandPrimary,
        ),
      );

  static ThemeData dark() => _build(
        brightness: Brightness.dark,
        scheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: _brandPrimary,
          onPrimary: Color(0xFF001E2B),
          primaryContainer: Color(0xFF004D73),
          onPrimaryContainer: Color(0xFFCDEBFF),
          secondary: Color(0xFFB7CBD7),
          onSecondary: Color(0xFF22333C),
          secondaryContainer: Color(0xFF394D58),
          onSecondaryContainer: Color(0xFFD6E6EE),
          tertiary: Color(0xFFC2C9D0),
          onTertiary: Color(0xFF2B3136),
          tertiaryContainer: Color(0xFF42494F),
          onTertiaryContainer: Color(0xFFE0E5EA),
          error: Color(0xFFFFB4AB),
          onError: Color(0xFF690005),
          errorContainer: Color(0xFF8C1D18),
          onErrorContainer: Color(0xFFF9DEDC),
          surface: Color(0xFF0F1418),
          onSurface: Color(0xFFE5EBEF),
          surfaceContainerLowest: Color(0xFF0A0F12),
          surfaceContainerLow: Color(0xFF151B20),
          surfaceContainer: Color(0xFF1A2228),
          surfaceContainerHigh: Color(0xFF202A31),
          surfaceContainerHighest: Color(0xFF28343C),
          onSurfaceVariant: Color(0xFFBCC8CF),
          outline: Color(0xFF89979F),
          outlineVariant: Color(0xFF3D4A52),
          inverseSurface: Color(0xFFE5EBEF),
          onInverseSurface: Color(0xFF263036),
          inversePrimary: Color(0xFF006A9F),
          scrim: Color(0xFF000000),
          surfaceTint: _brandPrimary,
        ),
      );

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
  }) {
    final isDark = brightness == Brightness.dark;
    final textTheme = TextTheme(
      headlineSmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: scheme.onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      titleSmall: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: scheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: scheme.onSurface,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: scheme.onSurfaceVariant,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: scheme.onSurfaceVariant,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        toolbarHeight: 56,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: Colors.transparent,
        surfaceTintColor: scheme.surfaceTint,
        foregroundColor: scheme.onSurface,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: scheme.onSurface, size: 24),
        actionsIconTheme: IconThemeData(color: scheme.onSurface, size: 24),
        systemOverlayStyle: (isDark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark)
            .copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          statusBarIconBrightness:
              isDark ? Brightness.light : Brightness.dark,
          systemNavigationBarIconBrightness:
              isDark ? Brightness.light : Brightness.dark,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: MaterialStatePropertyAll(
          TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: scheme.onSurface,
          ),
        ),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          final selected = states.contains(MaterialState.selected);
          return IconThemeData(
            size: 24,
            color:
                selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
          );
        }),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
    );
  }
}
