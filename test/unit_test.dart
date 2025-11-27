import 'package:flutter_test/flutter_test.dart';
import 'package:coursehub/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PreferencesService Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('should save and retrieve theme mode', () async {
      await PreferencesService.setThemeMode('dark');
      final theme = await PreferencesService.getThemeMode();
      expect(theme, 'dark');
    });

    test('should save and retrieve notifications setting', () async {
      await PreferencesService.setNotificationsEnabled(false);
      final notifications = await PreferencesService.getNotificationsEnabled();
      expect(notifications, false);
    });

    test('should save and retrieve language setting', () async {
      await PreferencesService.setLanguage('fr');
      final language = await PreferencesService.getLanguage();
      expect(language, 'fr');
    });

    test('should return default values when no preferences set', () async {
      final theme = await PreferencesService.getThemeMode();
      final notifications = await PreferencesService.getNotificationsEnabled();
      final language = await PreferencesService.getLanguage();
      
      expect(theme, 'light');
      expect(notifications, true);
      expect(language, 'en');
    });
  });
}