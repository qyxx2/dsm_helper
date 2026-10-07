import 'package:flutter/material.dart';

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

@immutable
class NewUiSemanticColors extends ThemeExtension<NewUiSemanticColors> {
  const NewUiSemanticColors({
    required this.success,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.warningContainer,
    required this.onWarningContainer,
  });

  final Color success;
  final Color successContainer;
  final Color onSuccessContainer;
  final Color warning;
  final Color warningContainer;
  final Color onWarningContainer;

  static const light = NewUiSemanticColors(
    success: Color(0xFF247A4B),
    successContainer: Color(0xFFD1F6DE),
    onSuccessContainer: Color(0xFF0C3B22),
    warning: Color(0xFF8A5A00),
    warningContainer: Color(0xFFFFE0A3),
    onWarningContainer: Color(0xFF3D2A00),
  );

  static const dark = NewUiSemanticColors(
    success: Color(0xFF65D99A),
    successContainer: Color(0xFF154F31),
    onSuccessContainer: Color(0xFFB8F1CF),
    warning: Color(0xFFF2C15C),
    warningContainer: Color(0xFF624300),
    onWarningContainer: Color(0xFFFFE0A3),
  );

  @override
  NewUiSemanticColors copyWith({
    Color? success,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? warningContainer,
    Color? onWarningContainer,
  }) {
    return NewUiSemanticColors(
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
    );
  }

  @override
  NewUiSemanticColors lerp(
    covariant ThemeExtension<NewUiSemanticColors>? other,
    double t,
  ) {
    if (other is! NewUiSemanticColors) {
      return this;
    }
    return NewUiSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      onSuccessContainer: Color.lerp(onSuccessContainer, other.onSuccessContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
      onWarningContainer: Color.lerp(onWarningContainer, other.onWarningContainer, t)!,
    );
  }
}

class NewUiTheme {
  const NewUiTheme._();

  static ThemeData light() => _build(
        _lightScheme,
        NewUiSemanticColors.light,
      );

  static ThemeData dark() => _build(
        _darkScheme,
        NewUiSemanticColors.dark,
      );

  static ThemeData fromColorScheme(ColorScheme scheme) {
    final semantics = scheme.brightness == Brightness.dark
        ? NewUiSemanticColors.dark
        : NewUiSemanticColors.light;
    return _build(scheme, semantics);
  }

  static ThemeData _build(
    ColorScheme scheme,
    NewUiSemanticColors semanticColors,
  ) {
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
      bodyLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
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
      brightness: scheme.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: scheme.surfaceTint,
        titleTextStyle: textTheme.titleLarge,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w500
                : FontWeight.w400,
            color: states.contains(WidgetState.selected)
                ? scheme.onSurface
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
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
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
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
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
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogTheme(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        showDragHandle: true,
      ),
      extensions: <ThemeExtension<dynamic>>[semanticColors],
    );
  }

  static const _lightScheme = ColorScheme(
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
    surfaceTint: Color(0xFF00A6FF),
  );

  static const _darkScheme = ColorScheme(
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
    surfaceTint: Color(0xFF00A6FF),
  );
}
