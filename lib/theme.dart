import 'package:flutter/material.dart';

class AppTheme {
  // Primary and secondary colors
  static const Color primaryColor = Color(0xfff48b23);
  static const Color secondaryColor = Color(0xfff4f4f4);

  static final Color primaryColorLight = Color.alphaBlend(
    Colors.white.withOpacity(0.5), // 50% white blend
    primaryColor,
  );


  // Common colors for both themes
  static const Color iconColor = Colors.black;
  static const Color overlayColor = Colors.black;
  static const Color textPrimaryColor = Colors.black;
  static const Color textSecondaryColor = Colors.grey;
  static const Color containerColor = Colors.white;
  static const Color containerShadowColor = Colors.black12;

  // Define Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: secondaryColor,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: iconColor),
      surfaceTintColor: Colors.transparent,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: containerColor,
    ),
    iconTheme: IconThemeData(color: iconColor),
    textTheme: TextTheme(
      bodySmall: TextStyle(color: textSecondaryColor),
      bodyMedium: TextStyle(color: textPrimaryColor),
      labelSmall: TextStyle(color: Colors.grey[700]),
      labelMedium: TextStyle(color: Colors.white),
    ),
    cardColor: containerColor,
    shadowColor: containerShadowColor,
    fontFamily: 'customFont',
    useMaterial3: true,
    primaryColorDark: Colors.black,
    inputDecorationTheme: InputDecorationTheme(
        fillColor: Colors.grey[200],
    ),
  );

  // Define Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColorLight,
    scaffoldBackgroundColor: Colors.black, // Dark background for scaffold
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
    iconTheme: IconThemeData(color: Colors.white),
    textTheme: TextTheme(
      bodySmall: TextStyle(color: Colors.white.withOpacity(0.8)),
      bodyMedium: TextStyle(color: Colors.white.withOpacity(0.8)),
      labelSmall: TextStyle(color: secondaryColor.withOpacity(0.8)),
      labelMedium: TextStyle(color: Colors.black),
    ),
    cardColor: Colors.grey[850],
    shadowColor: Colors.black.withOpacity(0.3),
    fontFamily: 'customFont',
    useMaterial3: true,
    primaryColorDark: Colors.white,
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Colors.grey[500],
    ),
  );
}


