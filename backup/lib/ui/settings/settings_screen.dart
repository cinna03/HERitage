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
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() async {
    final notifications = await PreferencesService.getNotificationsEnabled();
    final language = await PreferencesService.getLanguage();
    
    setState(() {
      _notificationsEnabled = notifications;
      _selectedLanguage = language;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softPink,
      appBar: AppBar(
        title: Text('Settings'),
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
            'Language',
            'Select app language',
            DropdownButton<String>(
              value: _selectedLanguage,
              items: [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'fr', child: Text('French')),
              ],
              onChanged: (value) async {
                if (value != null) {
                  setState(() => _selectedLanguage = value);
                  await PreferencesService.setLanguage(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard(String title, String subtitle, Widget trailing) {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(subtitle, style: TextStyle(fontSize: 14, color: mediumGrey)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}