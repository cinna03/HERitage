import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coursehub/utils/index.dart';
import 'package:coursehub/utils/theme_provider.dart';
import 'auth/signup_screen.dart';
import 'auth/login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  final List<WelcomeSlide> _slides = [
    WelcomeSlide(
      title: 'Learn Creative Arts',
      description: 'Access free courses in painting, design, music, and more from expert mentors',
      icon: Icons.school,
    ),
    WelcomeSlide(
      title: 'Connect & Grow',
      description: 'Join a community of creative women and build lasting professional relationships',
      icon: Icons.people,
    ),
    WelcomeSlide(
      title: 'Build Your Career',
      description: 'Get mentorship and opportunities to thrive in the global creative economy',
      icon: Icons.trending_up,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _slides.length,
                    itemBuilder: (context, index) {
                      return _buildSlide(_slides[index]);
                    },
                  ),
                ),
                _buildPageIndicator(),
                SizedBox(height: 30),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: 30),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignUpScreen()),
                            );
                          },
                          child: Text('Get Started', style: TextStyle(fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginScreen()),
                          );
                        },
                        child: Text(
                          'Already have an account? Sign In',
                          style: TextStyle(color: primaryPink, fontSize: 14),
                        ),
                      ),
                    ],
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
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(WelcomeSlide slide) {
    return Padding(
      padding: EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: primaryPink,
              shape: BoxShape.circle,
            ),
            child: Icon(
              slide.icon,
              size: 50,
              color: white,
            ),
          ),
          SizedBox(height: 40),
          Text(
            slide.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark ? white : darkGrey,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Text(
            slide.description,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).brightness == Brightness.dark ? white.withOpacity(0.8) : mediumGrey,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _slides.length,
        (index) => Container(
          margin: EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index ? primaryPink : lightPink,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

class WelcomeSlide {
  final String title;
  final String description;
  final IconData icon;

  WelcomeSlide({
    required this.title,
    required this.description,
    required this.icon,
  });
}