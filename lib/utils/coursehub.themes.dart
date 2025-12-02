// HERmony app themes - light pink theme
import 'package:flutter/material.dart';
import 'index.dart';

const MaterialColor pinkSwatch = MaterialColor(
  0xFFFF69B4, // Hot Pink
  <int, Color>{
    50: Color(0xFFFFF0F5),
    100: Color(0xFFFFE4E1),
    200: Color(0xFFFFC0CB),
    300: Color(0xFFFFB6C1),
    400: Color(0xFFFF91A4),
    500: Color(0xFFFF69B4), // Hot Pink
    600: Color(0xFFFF1493), // Deep Pink
    700: Color(0xFFDB7093), // Pale Violet Red
    800: Color(0xFFC71585), // Medium Violet Red
    900: Color(0xFF8B008B), // Dark Magenta
  },
);

final ThemeData lightTheme = ThemeData(
  primarySwatch: pinkSwatch,
  primaryColor: primaryPink,
  scaffoldBackgroundColor: softPink,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  fontFamily: 'Lato',
  brightness: Brightness.light,
  useMaterial3: false,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: darkGrey,
    elevation: 0,
    iconTheme: IconThemeData(color: primaryPink),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryPink,
      foregroundColor: white,
      minimumSize: Size(88, 48), // Material Design tap target
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      minimumSize: Size(88, 48), // Material Design tap target
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(
      minimumSize: Size(48, 48), // Material Design tap target
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(color: lightPink),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(color: primaryPink, width: 2),
    ),
  ),
  textTheme: TextTheme(
    headlineLarge: TextStyle(
      color: darkGrey,
      fontFamily: 'Lato',
      fontWeight: FontWeight.w700,
    ),
    titleLarge: TextStyle(
      color: darkGrey,
      fontFamily: 'Lato',
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: TextStyle(
      color: darkGrey,
      fontFamily: 'Lato',
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: TextStyle(
      color: mediumGrey,
      fontFamily: 'Lato',
      fontWeight: FontWeight.w400,
    ),
  ),
  cardColor: white,
  canvasColor: softPink,
);

final ThemeData darkTheme = ThemeData(
  primarySwatch: pinkSwatch,
  primaryColor: primaryPink,
  scaffoldBackgroundColor: Color(0xFF1A1A1A),
  visualDensity: VisualDensity.adaptivePlatformDensity,
  fontFamily: 'Lato',
  brightness: Brightness.dark,
  useMaterial3: false,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: white,
    elevation: 0,
    iconTheme: IconThemeData(color: primaryPink),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryPink,
      foregroundColor: white,
      minimumSize: Size(88, 48), // Material Design tap target
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      minimumSize: Size(88, 48), // Material Design tap target
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(
      minimumSize: Size(48, 48), // Material Design tap target
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(color: Color(0xFF404040)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(color: primaryPink, width: 2),
    ),
  ),
  textTheme: TextTheme(
    headlineLarge: TextStyle(
      color: white,
      fontFamily: 'Lato',
      fontWeight: FontWeight.w700,
    ),
    titleLarge: TextStyle(
      color: white,
      fontFamily: 'Lato',
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: TextStyle(
      color: white,
      fontFamily: 'Lato',
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: TextStyle(
      color: white.withValues(alpha: 0.7),
      fontFamily: 'Lato',
      fontWeight: FontWeight.w400,
    ),
  ),
  cardColor: Color(0xFF2D2D2D),
  canvasColor: Color(0xFF1A1A1A),
  iconTheme: IconThemeData(color: white),
);

final ThemeData mainTheme = lightTheme;
