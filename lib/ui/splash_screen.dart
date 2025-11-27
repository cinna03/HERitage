import 'package:flutter/material.dart';
import 'package:coursehub/utils/index.dart';
import 'package:coursehub/utils/theme_provider.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  final ThemeProvider themeProvider;
  
  SplashScreen({required this.themeProvider});
  
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToWelcome();
  }

  _navigateToWelcome() async {
    await Future.delayed(Duration(seconds: 3));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => WelcomeScreen(themeProvider: widget.themeProvider)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: primaryPink,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.palette,
                    size: 60,
                    color: white,
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  'Hermony',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: primaryPink,
                    fontFamily: 'Lato',
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Empowering African Women in Arts',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).brightness == Brightness.dark ? white : darkGrey,
                    fontFamily: 'Lato',
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 50,
            right: 20,
            child: SafeArea(
              child: IconButton(
                onPressed: widget.themeProvider.toggleTheme,
                icon: Icon(
                  widget.themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: primaryPink,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}