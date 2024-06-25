import 'package:dsm_helper/themes/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ThemeData darkTheme = ThemeData.dark().copyWith(
    extensions: <ThemeExtension>[
      AppTheme(
        titleColor: Colors.black,
        placeholderColor: Colors.white54,
        primaryColor: Color(0xFF2A82E4),
        progressColor: Color(0xFFf4f4f4),
        successColor: Color(0xFF25B85F),
        warningColor: Color(0xFFFF8D1A),
        errorColor: Color(0xFFFF5733),
        cardColor: Colors.black,
      ),
    ],
    platform: TargetPlatform.iOS,
    primaryColor: Colors.white54,
    disabledColor: Colors.white12,
    scaffoldBackgroundColor: Color(0xff121212),
    textTheme: TextTheme(
      bodyLarge: TextStyle(fontSize: 18.0, color: Colors.white70),
      bodyMedium: TextStyle(fontSize: 15.0, color: Colors.white70),
      bodySmall: TextStyle(fontSize: 12.0, color: Colors.white70),
      // titleLarge: TextStyle(fontSize: 16, color: Colors.black),
      titleMedium: TextStyle(fontSize: 18.0, color: Colors.white70),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.white12,
      thickness: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(
        fontSize: 16.0,
        color: Color(0xff808080),
      ),
      helperStyle: TextStyle(
        fontSize: 16.0,
        color: Color(0xff808080),
      ),
      labelStyle: TextStyle(
        fontSize: 16.0,
        color: Color(0xff808080),
      ),
    ),
    iconTheme: IconThemeData(color: Color(0xffa6a6a6)),
    tabBarTheme: TabBarTheme(
      indicatorColor: Colors.white70,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: Colors.transparent,
      unselectedLabelColor: Colors.white24,
      labelColor: Colors.white70,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      unselectedItemColor: Colors.white24,
      selectedItemColor: Colors.white70,
      backgroundColor: Colors.black,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      enableFeedback: true,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontSize: 13),
      unselectedLabelStyle: TextStyle(fontSize: 13),
    ),
    cupertinoOverrideTheme: CupertinoThemeData(primaryColor: Color(0xff2A82E4), applyThemeToAll: true),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      color: Color(0xff121212),
      iconTheme: IconThemeData(color: Colors.white70),
      actionsIconTheme: IconThemeData(color: Colors.white70),
      titleTextStyle: TextStyle(fontSize: 20.0, color: Colors.white70),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    colorScheme: ColorScheme.dark(
      secondary: Color(0xff888888),
      surface: Color(0xff121212),
    ),
);
