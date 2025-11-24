// coursehub app themes defined here
import 'package:flutter/material.dart';

// ignore: unused_import
import 'index.dart';
const MaterialColor myPrimarySwatch = MaterialColor(
  0xFF1A72FF, // base color
  <int, Color>{
    50: Color(0xFFE6F0FF),
    100: Color(0xFFB3D1FF),
    200: Color(0xFF80B1FF),
    300: Color(0xFF4D92FF),
    400: Color(0xFF266FFF),
    500: Color(0xFF1A72FF), // same as base
    600: Color(0xFF0050E6),
    700: Color(0xFF0040B3),
    800: Color(0xFF003380),
    900: Color(0xFF001A40),
  },
);

final ThemeData mainTheme = ThemeData(
  primarySwatch: myPrimarySwatch,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  fontFamily: 'Lato',
);
