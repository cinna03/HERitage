import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coursehub/utils/index.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_stats_provider.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

/// State class for HomeTab widget
/// Manages animated background bubbles and displays user dashboard content
class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _animations;

  @override
  void initState() {
    super.initState();
    // Initialize 5 animation controllers with varying durations for background bubbles
    // Each bubble animates independently to create a dynamic background effect
    _controllers = List.generate(5, (index) => 
      AnimationController(
        duration: Duration(seconds: 3 + index),
        vsync: this,
      )..repeat(reverse: true)
    );
    
    // Create offset animations for each bubble to move across the screen
    // Uses curved animation for smooth, natural movement
    _animations = _controllers.map((controller) => 
      Tween<Offset>(
        begin: Offset(-0.5, -0.5),
        end: Offset(1.5, 1.5),
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ))
    ).toList();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softPink,
      body: Stack(
        children: [
          // Animated bubbles
          ...List.generate(5, (index) => 
            AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                return Positioned(
                  left: MediaQuery.of(context).size.width * _animations[index].value.dx,
                  top: MediaQuery.of(context).size.height * _animations[index].value.dy,
                  child: Container(
                    width: 60 + (index * 20),
                    height: 60 + (index * 20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: lightPink.withValues(alpha: 0.3 - (index * 0.05)),
                    ),
                  ),
                );
              },
            )
          ),
          
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  SizedBox(height: 20),
                  _buildWelcomeCard(),
                  SizedBox(height: 25),
                  _buildQuickActions(),
                  SizedBox(height: 25),
                  _buildFeaturedCourses(),
                  SizedBox(height: 25),
                  _buildProgressSection(),
                  SizedBox(height: 25),
                  _buildCommunityHighlights(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the header section with user avatar and welcome message
  /// Displays user name from AuthProvider or defaults to 'Creative Sister'
  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: primaryPink,
            child: Icon(Icons.person, color: white, size: 30),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final userName = authProvider.user?.displayName ?? 
                                authProvider.userEmail?.split('@')[0] ?? 
                                'Creative Sister';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back!',
                      style: TextStyle(
                        fontSize: 16,
                        color: mediumGrey,
                      ),
                    ),
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: darkGrey,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications, color: primaryPink, size: 28),
          ),
        ],
      ),
    );
  }

  /// Builds the welcome card showing course progress
  /// Displays gradient card with progress indicator and continue button
  Widget _buildWelcomeCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryPink, rosePink],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Continue Your Journey',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: white,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'You\'re 60% through your current course',
            style: TextStyle(
              fontSize: 16,
              color: white.withValues(alpha: 0.9),
            ),
          ),
          SizedBox(height: 15),
          LinearProgressIndicator(
            value: 0.6,
            backgroundColor: white.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(white),
          ),
          SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {},
            child: Text('Continue Learning'),
            style: ElevatedButton.styleFrom(
              backgroundColor: white,
              foregroundColor: primaryPink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the quick actions section with 4 action cards
  /// Provides shortcuts to Courses, Mentors, Events, and Community
  Widget _buildQuickActions() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: darkGrey,
            ),
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _buildActionCard('Browse Courses', Icons.school, primaryPink)),
              SizedBox(width: 15),
              Expanded(child: _buildActionCard('Find Mentors', Icons.people, rosePink)),
            ],
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _buildActionCard('Join Events', Icons.event, accentPink)),
              SizedBox(width: 15),
              Expanded(child: _buildActionCard('Community', Icons.forum, darkPink)),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds an individual action card widget
  /// [title] - The action title to display
  /// [icon] - The icon to show for this action
  /// [color] - The primary color for the icon background
  Widget _buildActionCard(String title, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: lightPink.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 25),
          ),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: darkGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Builds the featured courses horizontal scrolling section
  /// Displays a list of recommended courses in a horizontal ListView
  Widget _buildFeaturedCourses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured Courses',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkGrey,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text('See All', style: TextStyle(color: primaryPink)),
              ),
            ],
          ),
        ),
        SizedBox(height: 15),
        Container(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                width: 280,
                margin: EdgeInsets.only(right: 15),
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: lightPink.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: primaryPink.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                      ),
                      child: Center(
                        child: Icon(Icons.palette, size: 40, color: primaryPink),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Digital Painting Basics',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: darkGrey,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Learn fundamental techniques',
                            style: TextStyle(
                              fontSize: 14,
                              color: mediumGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Builds the progress section showing user statistics
  /// Displays courses completed, hours learned, certificates earned, and community posts
  /// Uses UserStatsProvider for real-time data updates
  Widget _buildProgressSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: lightPink.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkGrey,
              ),
            ),
            SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildProgressItem(
                    'Courses\nCompleted', 
                    Consumer<UserStatsProvider>(
                      builder: (context, statsProvider, child) {
                        return Text(
                          statsProvider.isLoading ? '...' : '${statsProvider.coursesCompleted}',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryPink),
                        );
                      },
                    ), 
                    Icons.school
                  ),
                ),
                Expanded(
                  child: _buildProgressItem(
                    'Hours\nLearned', 
                    Consumer<UserStatsProvider>(
                      builder: (context, statsProvider, child) {
                        return Text(
                          statsProvider.isLoading ? '...' : '${statsProvider.totalHours}',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryPink),
                        );
                      },
                    ), 
                    Icons.access_time
                  ),
                ),
                Expanded(
                  child: _buildProgressItem(
                    'Certificates\nEarned', 
                    Consumer<UserStatsProvider>(
                      builder: (context, statsProvider, child) {
                        return Text(
                          statsProvider.isLoading ? '...' : '${statsProvider.certificatesEarned}',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryPink),
                        );
                      },
                    ), 
                    Icons.card_membership
                  ),
                ),
              ],
            ),
            Consumer<UserStatsProvider>(
              builder: (context, statsProvider, child) {
                if (statsProvider.isLoading) return SizedBox.shrink();
                return Column(
                  children: [
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: _buildProgressItem(
                            'Community\nPosts', 
                            Text(
                              '${statsProvider.postsCount}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: primaryPink,
                              ),
                            ), 
                            Icons.forum
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Builds an individual progress item widget
  /// [label] - The label text (e.g., "Courses Completed")
  /// [value] - The value widget to display (can be text or Consumer widget)
  /// [icon] - The icon to display for this metric
  Widget _buildProgressItem(String label, Widget value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: primaryPink, size: 30),
        SizedBox(height: 10),
        value,
        SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: mediumGrey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCommunityHighlights() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Community Highlights',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: darkGrey,
            ),
          ),
          SizedBox(height: 15),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: lightPink.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: primaryPink,
                    child: Icon(Icons.person, color: white),
                  ),
                  title: Text('Sarah M. shared her artwork'),
                  subtitle: Text('2 hours ago'),
                  contentPadding: EdgeInsets.zero,
                ),
                Divider(color: lightPink),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: rosePink,
                    child: Icon(Icons.event, color: white),
                  ),
                  title: Text('New workshop: "Color Theory"'),
                  subtitle: Text('Tomorrow at 3 PM'),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}