import 'package:flutter/material.dart';
import 'package:coursehub/utils/index.dart';
import '../auth/login_screen.dart';
import '../settings/settings_screen.dart';
import '../../services/mock_auth_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softPink,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: primaryPink,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryPink, rosePink],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 40),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: white,
                      child: Icon(Icons.person, size: 50, color: primaryPink),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Creative Sister',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: white,
                      ),
                    ),
                    Text(
                      '@creativesister',
                      style: TextStyle(
                        fontSize: 14,
                        color: white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => _showSettingsMenu(),
                icon: Icon(Icons.settings, color: white),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: softPink,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Padding(
                padding: EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileStats(),
                    SizedBox(height: 25),
                    _buildBio(),
                    SizedBox(height: 25),
                    _buildInterests(),
                    SizedBox(height: 25),
                    _buildAchievements(),
                    SizedBox(height: 25),
                    _buildRecentActivity(),
                    SizedBox(height: 25),
                    _buildPortfolio(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStats() {
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
      child: Row(
        children: [
          Expanded(child: _buildStatItem('Courses\nCompleted', '8')),
          Expanded(child: _buildStatItem('Hours\nLearned', '45')),
          Expanded(child: _buildStatItem('Certificates\nEarned', '5')),
          Expanded(child: _buildStatItem('Community\nPosts', '23')),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
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

  Widget _buildBio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'About Me',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkGrey,
              ),
            ),
            TextButton(
              onPressed: () => _editProfile(),
              child: Text('Edit', style: TextStyle(color: primaryPink)),
            ),
          ],
        ),
        SizedBox(height: 15),
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            'Passionate digital artist from Lagos, Nigeria. I love exploring new techniques and sharing my creative journey with the Hermony community. Currently focusing on character design and illustration.',
            style: TextStyle(
              fontSize: 14,
              color: darkGrey,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInterests() {
    final interests = ['Digital Art', 'Character Design', 'Color Theory', 'Illustration', 'Animation'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Interests',
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
          ),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: interests.map((interest) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryPink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  interest,
                  style: TextStyle(
                    fontSize: 12,
                    color: primaryPink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Achievements',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: darkGrey,
          ),
        ),
        SizedBox(height: 15),
        Container(
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              _buildAchievementItem(
                Icons.school,
                'Course Completion Master',
                'Completed 5+ courses',
                primaryPink,
              ),
              _buildAchievementItem(
                Icons.people,
                'Community Contributor',
                'Made 20+ helpful posts',
                rosePink,
              ),
              _buildAchievementItem(
                Icons.star,
                'Rising Artist',
                'Received 50+ likes on artwork',
                accentPink,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementItem(IconData icon, String title, String description, Color color) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: lightPink.withOpacity(0.3)),
        ),
      ),
      child: Row(
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
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: darkGrey,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: mediumGrey,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.emoji_events, color: Colors.amber, size: 20),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkGrey,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text('View All', style: TextStyle(color: primaryPink)),
            ),
          ],
        ),
        SizedBox(height: 15),
        Container(
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              _buildActivityItem(
                Icons.school,
                'Completed "Digital Painting Basics"',
                '2 days ago',
              ),
              _buildActivityItem(
                Icons.forum,
                'Posted in "Beginner Tips" discussion',
                '5 days ago',
              ),
              _buildActivityItem(
                Icons.favorite,
                'Liked Sarah\'s artwork',
                '1 week ago',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(IconData icon, String activity, String time) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: lightPink.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primaryPink.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primaryPink, size: 20),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity,
                  style: TextStyle(
                    fontSize: 14,
                    color: darkGrey,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: mediumGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Portfolio',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkGrey,
              ),
            ),
            TextButton(
              onPressed: () => _managePortfolio(),
              child: Text('Manage', style: TextStyle(color: primaryPink)),
            ),
          ],
        ),
        SizedBox(height: 15),
        Container(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            itemBuilder: (context, index) {
              return Container(
                width: 120,
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, size: 40, color: primaryPink),
                    SizedBox(height: 10),
                    Text(
                      'Artwork ${index + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        color: darkGrey,
                        fontWeight: FontWeight.w600,
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

  void _showSettingsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 15),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: lightGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            _buildSettingsItem(Icons.edit, 'Edit Profile', () {}),
            _buildSettingsItem(Icons.settings, 'Settings', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()));
            }),
            _buildSettingsItem(Icons.privacy_tip, 'Privacy Settings', () {}),
            _buildSettingsItem(Icons.help, 'Help & Support', () {}),
            _buildSettingsItem(Icons.info, 'About Hermony', () {}),
            _buildSettingsItem(Icons.logout, 'Sign Out', _signOut, isDestructive: true),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? errorRed : primaryPink),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? errorRed : darkGrey,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: mediumGrey),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _editProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Display Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Profile updated successfully!')),
              );
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _managePortfolio() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Manage Portfolio'),
        content: Text('Portfolio management features coming soon! You\'ll be able to upload, organize, and showcase your creative work.'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _signOut() async {
    try {
      await MockAuthService().signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign out failed')),
      );
    }
  }
}