import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _themeKey = 'theme_mode';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _languageKey = 'language';
  static const String _autoPlayVideosKey = 'auto_play_videos';
  static const String _postNotificationsKey = 'post_notifications';
  static const String _chatNotificationsKey = 'chat_notifications';
  static const String _eventRemindersKey = 'event_reminders';

  static Future<void> setThemeMode(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme);
  }

  static Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? 'light';
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
  }

  static Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsKey) ?? true;
  }

  static Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }

  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'en';
  }

  static Future<void> setAutoPlayVideos(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoPlayVideosKey, enabled);
  }

  static Future<bool> getAutoPlayVideos() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoPlayVideosKey) ?? true;
  }

  static Future<void> setPostNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_postNotificationsKey, enabled);
  }

  static Future<bool> getPostNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_postNotificationsKey) ?? true;
  }

  static Future<void> setChatNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chatNotificationsKey, enabled);
  }

  static Future<bool> getChatNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_chatNotificationsKey) ?? true;
  }

  static Future<void> setEventReminders(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_eventRemindersKey, enabled);
  }

  static Future<bool> getEventReminders() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_eventRemindersKey) ?? true;
  }
}