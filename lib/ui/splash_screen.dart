import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coursehub/utils/index.dart';
import 'package:coursehub/utils/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_profile_provider.dart';
import '../providers/user_stats_provider.dart';
import '../providers/forum_provider.dart';
import '../providers/event_provider.dart';
import '../providers/course_provider.dart';
import 'welcome_screen.dart';
import 'dashboard/dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  _checkAuthAndNavigate() async {
    await Future.delayed(Duration(seconds: 3));
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.isAuthenticated) {
      // Refresh all providers when navigating to dashboard to ensure data persistence
      final profileProvider = Provider.of<UserProfileProvider>(context, listen: false);
      final statsProvider = Provider.of<UserStatsProvider>(context, listen: false);
      final forumProvider = Provider.of<ForumProvider>(context, listen: false);
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final courseProvider = Provider.of<CourseProvider>(context, listen: false);
      
      // Refresh all data providers to ensure data loads on app restart
      await Future.wait([
        profileProvider.refresh(),
        statsProvider.refresh(),
      ]);
      
      // Refresh stream-based providers (these will auto-update via streams)
      forumProvider.refresh();
      eventProvider.refresh();
      courseProvider.refresh();
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                  'HERmony',
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
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 16,
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
              child: Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return IconButton(
                    onPressed: themeProvider.toggleTheme,
                    icon: Icon(
                      themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      color: primaryPink,
                      size: 28,
                    ),
                    constraints: BoxConstraints(minWidth: 48, minHeight: 48),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}