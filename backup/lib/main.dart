import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coursehub/utils/index.dart';
import 'package:coursehub/utils/theme_provider.dart';
import 'package:coursehub/ui/splash_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/forum_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(HERmonyApp());
}

class HERmonyApp extends StatefulWidget {
  @override
  _HERmonyAppState createState() => _HERmonyAppState();
}

class _HERmonyAppState extends State<HERmonyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ForumProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'HERmony - Empowering African Women in Arts',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: SplashScreen(),
          );
        },
      ),
    );
  }
}
