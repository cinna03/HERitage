import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coursehub/utils/index.dart';
import 'package:coursehub/utils/theme_provider.dart';
import '../../services/preferences_service.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _postNotifications = true;
  bool _chatNotifications = true;
  bool _eventReminders = true;
  String _selectedLanguage = 'en';
  bool _autoPlayVideos = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() async {
    final notifications = await PreferencesService.getNotificationsEnabled();
    final postNotifications = await PreferencesService.getPostNotifications();
    final chatNotifications = await PreferencesService.getChatNotifications();
    final eventReminders = await PreferencesService.getEventReminders();
    final language = await PreferencesService.getLanguage();
    final autoPlay = await PreferencesService.getAutoPlayVideos();
    
    setState(() {
      _notificationsEnabled = notifications;
      _postNotifications = postNotifications;
      _chatNotifications = chatNotifications;
      _eventReminders = eventReminders;
      _selectedLanguage = language;
      _autoPlayVideos = autoPlay;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(fontFamily: 'Lato'),
        ),
        backgroundColor: primaryPink,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          _buildSettingCard(
            'Notifications',
            'Receive push notifications',
            Switch(
              value: _notificationsEnabled,
              onChanged: (value) async {
                setState(() => _notificationsEnabled = value);
                await PreferencesService.setNotificationsEnabled(value);
              },
              activeTrackColor: primaryPink,
            ),
          ),
          SizedBox(height: 15),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return _buildSettingCard(
                'Dark Mode',
                'Toggle dark/light theme',
                Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) => themeProvider.toggleTheme(),
                  activeTrackColor: primaryPink,
                ),
              );
            },
          ),
          SizedBox(height: 15),
          _buildSettingCard(
            'Post Notifications',
            'Get notified about new posts',
            Switch(
              value: _postNotifications,
              onChanged: (value) async {
                setState(() => _postNotifications = value);
                await PreferencesService.setPostNotifications(value);
              },
              activeTrackColor: primaryPink,
            ),
          ),
          SizedBox(height: 15),
          _buildSettingCard(
            'Chat Notifications',
            'Get notified about new messages',
            Switch(
              value: _chatNotifications,
              onChanged: (value) async {
                setState(() => _chatNotifications = value);
                await PreferencesService.setChatNotifications(value);
              },
              activeTrackColor: primaryPink,
            ),
          ),
          SizedBox(height: 15),
          _buildSettingCard(
            'Event Reminders',
            'Get reminded about upcoming events',
            Switch(
              value: _eventReminders,
              onChanged: (value) async {
                setState(() => _eventReminders = value);
                await PreferencesService.setEventReminders(value);
              },
              activeTrackColor: primaryPink,
            ),
          ),
          SizedBox(height: 15),
          _buildSettingCard(
            'Language',
            'Select app language',
            DropdownButton<String>(
              value: _selectedLanguage,
              items: [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'fr', child: Text('French')),
                DropdownMenuItem(value: 'es', child: Text('Spanish')),
                DropdownMenuItem(value: 'pt', child: Text('Portuguese')),
                DropdownMenuItem(value: 'sw', child: Text('Swahili')),
              ],
              onChanged: (value) async {
                if (value != null) {
                  setState(() => _selectedLanguage = value);
                  await PreferencesService.setLanguage(value);
                }
              },
            ),
          ),
          SizedBox(height: 15),
          _buildSettingCard(
            'Auto-play Videos',
            'Automatically play course videos',
            Switch(
              value: _autoPlayVideos,
              onChanged: (value) async {
                setState(() => _autoPlayVideos = value);
                await PreferencesService.setAutoPlayVideos(value);
              },
              activeTrackColor: primaryPink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard(String title, String subtitle, Widget trailing) {
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 16, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle, 
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14, 
                    color: mediumGrey,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}