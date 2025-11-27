import 'package:flutter/material.dart';
import 'package:coursehub/utils/index.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5E6F0),
      body: Stack(
        children: [
          // Pink circles background
          Positioned(top: -100, left: -100, child: _buildCircle(300, lightPink.withOpacity(0.3))),
          Positioned(top: 50, right: -50, child: _buildCircle(200, palePink.withOpacity(0.4))),
          Positioned(bottom: -150, right: -100, child: _buildCircle(400, rosePink.withOpacity(0.2))),
          
          SafeArea(
            child: Row(
              children: [
                // Left sidebar
                Container(
                  width: 250,
                  padding: EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: darkGrey,
                        ),
                      ),
                      SizedBox(height: 40),
                      _buildSidebarItem('Account', true),
                      _buildSidebarItem('Notifications', false),
                      _buildSidebarItem('Privacy', false),
                      _buildSidebarItem('Languages', false),
                      _buildSidebarItem('Help', false),
                    ],
                  ),
                ),
                
                // Main content
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(20),
                    padding: EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with navigation
                        Row(
                          children: [
                            _buildNavItem('Home'),
                            _buildNavItem('Explore'),
                            _buildNavItem('Pricing'),
                            _buildNavItem('About'),
                            Spacer(),
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: primaryPink,
                              child: Icon(Icons.person, color: white, size: 20),
                            ),
                          ],
                        ),
                        SizedBox(height: 40),
                        
                        Text(
                          'Account Settings',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: darkGrey,
                          ),
                        ),
                        SizedBox(height: 30),
                        
                        // Basic Info section
                        Text(
                          'Basic info',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: darkGrey,
                          ),
                        ),
                        SizedBox(height: 20),
                        
                        // Profile Picture
                        Row(
                          children: [
                            Text('Profile Picture', style: TextStyle(color: mediumGrey)),
                            SizedBox(width: 100),
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: primaryPink,
                              child: Icon(Icons.person, color: white, size: 25),
                            ),
                            SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Upload new picture', style: TextStyle(color: primaryPink, fontSize: 12)),
                                Text('Remove', style: TextStyle(color: errorRed, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        
                        _buildInfoRow('Name', 'Wade Armstrong'),
                        _buildInfoRow('Date of Birth', 'December 24, 1991'),
                        _buildInfoRow('Gender', 'Male'),
                        _buildInfoRow('Email', 'wade.armstrong@email.com'),
                        
                        SizedBox(height: 40),
                        
                        // Account info section
                        Text(
                          'Account info',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: darkGrey,
                          ),
                        ),
                        SizedBox(height: 20),
                        
                        _buildInfoRow('Username', 'wadearmstrong08'),
                        _buildInfoRow('Password', '••••••••••'),
                        
                        Spacer(),
                        
                        // Guide text
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Guide to setup your account',
                            style: TextStyle(
                              color: primaryPink,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _buildSidebarItem(String title, bool isActive) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isActive ? primaryPink.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isActive ? Border(left: BorderSide(color: primaryPink, width: 3)) : null,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: isActive ? primaryPink : darkGrey,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildNavItem(String title) {
    return Padding(
      padding: EdgeInsets.only(right: 30),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: mediumGrey,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: mediumGrey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: darkGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(Icons.chevron_right, color: mediumGrey, size: 20),
        ],
      ),
    );
  }
}