import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coursehub/utils/index.dart';
import 'package:coursehub/utils/theme_provider.dart';
import '../auth/login_screen.dart';
import '../settings/settings_screen.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_stats_provider.dart';
import '../../providers/user_profile_provider.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                child: Consumer<UserProfileProvider>(
                  builder: (context, profileProvider, child) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 40),
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: white,
                          backgroundImage: profileProvider.profilePictureUrl != null
                              ? NetworkImage(profileProvider.profilePictureUrl!)
                              : null,
                          child: profileProvider.profilePictureUrl == null
                              ? Icon(Icons.person, size: 50, color: primaryPink)
                              : null,
                        ),
                        SizedBox(height: 15),
                        Text(
                          profileProvider.getDisplayName(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: white,
                            fontFamily: 'Lato',
                          ),
                        ),
                        if (profileProvider.username != null)
                          Text(
                            profileProvider.getUsernameDisplay(),
                            style: TextStyle(
                              fontSize: 14,
                              color: white.withValues(alpha: 0.8),
                              fontFamily: 'Lato',
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
            actions: [
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return IconButton(
                    onPressed: themeProvider.toggleTheme,
                    icon: Icon(
                      themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      color: white,
                    ),
                    tooltip: 'Toggle theme',
                  );
                },
              ),
              IconButton(
                onPressed: () => _showSettingsMenu(),
                icon: Icon(Icons.settings, color: white),
                constraints: BoxConstraints(minWidth: 48, minHeight: 48),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: 25,
                  right: 25,
                  top: 25,
                  bottom: MediaQuery.of(context).padding.bottom + 25,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Consumer<UserStatsProvider>(
        builder: (context, statsProvider, child) {
          return Row(
            children: [
              Expanded(child: _buildStatItem(
                'Courses\nCompleted',
                statsProvider.isLoading ? '...' : '${statsProvider.coursesCompleted}',
              )),
              Expanded(child: _buildStatItem(
                'Hours\nLearned',
                statsProvider.isLoading ? '...' : '${statsProvider.totalHours}',
              )),
              Expanded(child: _buildStatItem(
                'Certificates\nEarned',
                statsProvider.isLoading ? '...' : '${statsProvider.certificatesEarned}',
              )),
              Expanded(child: _buildStatItem(
                'Community\nPosts',
                statsProvider.isLoading ? '...' : '${statsProvider.postsCount}',
              )),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: primaryPink,
            fontFamily: 'Lato',
          ),
        ),
        SizedBox(height: 5),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBio() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'About Me',
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => _editProfile(),
              style: TextButton.styleFrom(
                minimumSize: Size(88, 48),
              ),
              child: Text(
                'Edit',
                style: TextStyle(
                  color: primaryPink,
                  fontFamily: 'Lato',
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 15),
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Consumer<UserProfileProvider>(
            builder: (context, profileProvider, child) {
              return Text(
                profileProvider.bio ?? 
                'No bio yet. Tell us about yourself!',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  height: 1.5,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInterests() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Interests',
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 15),
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Consumer<UserProfileProvider>(
            builder: (context, profileProvider, child) {
              final interests = profileProvider.interests;
              return interests.isEmpty
                  ? Text(
                      'No interests added yet',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  : Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: interests.map((interest) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryPink.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  interest,
                  style: TextStyle(
                    fontSize: 12,
                    color: primaryPink,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Lato',
                  ),
                ),
              );
                      }).toList(),
                    );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAchievements() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Achievements',
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 15),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Color(0xFF404040) : lightPink.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.2 : 0.1),
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
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
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
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                minimumSize: Size(88, 48),
              ),
              child: Text(
                'View All',
                style: TextStyle(
                  color: primaryPink,
                  fontFamily: 'Lato',
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 15),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Color(0xFF404040) : lightPink.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primaryPink.withValues(alpha: isDark ? 0.2 : 0.1),
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
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  time,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Portfolio',
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => _managePortfolio(),
              style: TextButton.styleFrom(
                minimumSize: Size(88, 48),
              ),
              child: Text(
                'Manage',
                style: TextStyle(
                  color: primaryPink,
                  fontFamily: 'Lato',
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 15),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemCount: 4,
            itemBuilder: (context, index) {
              return Container(
                width: 120,
                margin: EdgeInsets.only(right: 15),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
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
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontSize: 12,
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
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: SafeArea(
          top: false,
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
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()));
              }),
              _buildSettingsItem(Icons.privacy_tip, 'Privacy Settings', () {}),
              _buildSettingsItem(Icons.help, 'Help & Support', () {}),
              _buildSettingsItem(Icons.info, 'About Hermony', () {}),
              _buildSettingsItem(Icons.logout, 'Sign Out', _signOut, isDestructive: true),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return ListTile(
      leading: Icon(icon, color: isDestructive ? errorRed : primaryPink),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive 
              ? errorRed 
              : isDark 
                  ? theme.textTheme.bodyLarge?.color ?? Colors.white
                  : theme.textTheme.bodyLarge?.color ?? darkGrey,
          fontWeight: FontWeight.w500,
          fontFamily: 'Lato',
        ),
      ),
      trailing: Icon(
        Icons.chevron_right, 
        color: isDark 
            ? theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6) 
            : mediumGrey,
      ),
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
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign out failed: ${e.toString()}')),
        );
      }
    }
  }
}