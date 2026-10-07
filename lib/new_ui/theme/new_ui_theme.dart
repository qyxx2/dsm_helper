import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NewUiThemeMode {
  const NewUiThemeMode._();

  static ThemeMode fromLegacyValue(int value) {
    switch (value) {
      case 0:
        return ThemeMode.light;
      case 1:
        return ThemeMode.dark;
      case 2:
      default:
        return ThemeMode.system;
    }
  }
}

class NewUiTheme {
  const NewUiTheme._();

  static ThemeData light() => _build(_lightScheme);
  static ThemeData dark() => _build(_darkScheme);

  static ThemeData _build(ColorScheme scheme) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      visualDensity: VisualDensity.standard,
    );

    final textTheme = base.textTheme.copyWith(
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
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: scheme.onSurface,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: scheme.onSurfaceVariant,
      ),
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        toolbarHeight: 56,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: scheme.surfaceTint,
        titleTextStyle: textTheme.titleLarge,
        systemOverlayStyle: scheme.brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.secondaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          return textTheme.labelMedium?.copyWith(
            color: states.contains(MaterialState.selected)
                ? scheme.onSecondaryContainer
                : scheme.onSurfaceVariant,
          );
        }),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          return IconThemeData(
            size: 24,
            color: states.contains(MaterialState.selected)
                ? scheme.onSecondaryContainer
                : scheme.onSurfaceVariant,
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
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.primary),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      dialogTheme: DialogTheme(
        elevation: 3,
        backgroundColor: scheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 3,
        backgroundColor: scheme.surfaceContainerHigh,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
      ),
    );
  }

  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF00A6FF),
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
    onSurfaceVariant: Color(0xFF44515A),
    outline: Color(0xFF73818A),
    outlineVariant: Color(0xFFC3CED5),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF2C3134),
    onInverseSurface: Color(0xFFF0F3F5),
    inversePrimary: Color(0xFF6CC5FF),
    surfaceTint: Color(0xFF00A6FF),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF0F5F8),
    surfaceContainer: Color(0xFFEAF1F5),
    surfaceContainerHigh: Color(0xFFE4ECF1),
    surfaceContainerHighest: Color(0xFFDDE6EC),
  );

  static const ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF00A6FF),
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
    onSurfaceVariant: Color(0xFFBCC8CF),
    outline: Color(0xFF89979F),
    outlineVariant: Color(0xFF3D4A52),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFE5EBEF),
    onInverseSurface: Color(0xFF263036),
    inversePrimary: Color(0xFF006A9F),
    surfaceTint: Color(0xFF00A6FF),
    surfaceContainerLowest: Color(0xFF0A0F12),
    surfaceContainerLow: Color(0xFF151B20),
    surfaceContainer: Color(0xFF1A2228),
    surfaceContainerHigh: Color(0xFF202A31),
    surfaceContainerHighest: Color(0xFF28343C),
  );
}
