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
  appBarTheme: AppBarTheme(
    backgroundColor: primaryPink,
    foregroundColor: white,
    elevation: 0,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryPink,
      foregroundColor: white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
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
);

final ThemeData darkTheme = ThemeData(
  primarySwatch: pinkSwatch,
  primaryColor: primaryPink,
  scaffoldBackgroundColor: Color(0xFF1A1A1A),
  visualDensity: VisualDensity.adaptivePlatformDensity,
  fontFamily: 'Lato',
  brightness: Brightness.dark,
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF2D2D2D),
    foregroundColor: white,
    elevation: 0,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryPink,
      foregroundColor: white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
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
  cardColor: Color(0xFF2D2D2D),
  canvasColor: Color(0xFF1A1A1A),
);

final ThemeData mainTheme = lightTheme;
