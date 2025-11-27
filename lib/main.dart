import 'package:flutter/material.dart';
import 'package:coursehub/utils/index.dart';
import 'package:coursehub/utils/theme_provider.dart';
import 'package:coursehub/ui/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(HermonyApp());
}

class HermonyApp extends StatefulWidget {
  @override
  _HermonyAppState createState() => _HermonyAppState();
}

class _HermonyAppState extends State<HermonyApp> {
  final ThemeProvider _themeProvider = ThemeProvider();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeProvider,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Hermony - Empowering African Women in Arts',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: _themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: SplashScreen(themeProvider: _themeProvider),
        );
      },
    );
  }
}
