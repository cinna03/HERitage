import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coursehub/utils/index.dart';
import '../../services/firestore_service.dart';
import '../../providers/auth_provider.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _animations;
  final FirestoreService _firestoreService = FirestoreService();
  Map<String, dynamic>? _userStats;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadUserStatistics();
    _controllers = List.generate(5, (index) => 
      AnimationController(
        duration: Duration(seconds: 3 + index),
        vsync: this,
      )..repeat(reverse: true)
    );
    
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

  Future<void> _loadUserStatistics() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user != null) {
      try {
        final stats = await _firestoreService.getUserStatistics(user.uid);
        setState(() {
          _userStats = stats;
          _isLoadingStats = false;
        });
      } catch (e) {
        setState(() {
          _userStats = {
            'coursesCompleted': 0,
            'postsCount': 0,
            'totalHours': 0,
            'certificatesEarned': 0,
          };
          _isLoadingStats = false;
        });
      }
    } else {
      setState(() {
        _isLoadingStats = false;
      });
    }
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
                      color: lightPink.withOpacity(0.3 - (index * 0.05)),
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
              color: white.withOpacity(0.9),
            ),
          ),
          SizedBox(height: 15),
          LinearProgressIndicator(
            value: 0.6,
            backgroundColor: white.withOpacity(0.3),
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

  Widget _buildActionCard(String title, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: lightPink.withOpacity(0.3),
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
              color: color.withOpacity(0.1),
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
                      color: lightPink.withOpacity(0.3),
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
                        color: primaryPink.withOpacity(0.1),
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
              color: lightPink.withOpacity(0.3),
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
                    _isLoadingStats ? '...' : '${_userStats?['coursesCompleted'] ?? 0}', 
                    Icons.school
                  ),
                ),
                Expanded(
                  child: _buildProgressItem(
                    'Hours\nLearned', 
                    _isLoadingStats ? '...' : '${_userStats?['totalHours'] ?? 0}', 
                    Icons.access_time
                  ),
                ),
                Expanded(
                  child: _buildProgressItem(
                    'Certificates\nEarned', 
                    _isLoadingStats ? '...' : '${_userStats?['certificatesEarned'] ?? 0}', 
                    Icons.card_membership
                  ),
                ),
              ],
            ),
            if (_userStats != null) ...[
              SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _buildProgressItem(
                      'Community\nPosts', 
                      '${_userStats?['postsCount'] ?? 0}', 
                      Icons.forum
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: primaryPink, size: 30),
        SizedBox(height: 10),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: primaryPink,
          ),
        ),
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
                  color: lightPink.withOpacity(0.3),
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