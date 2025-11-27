import 'package:flutter_test/flutter_test.dart';
import 'package:coursehub/services/preferences_service.dart';
import 'package:coursehub/services/firestore_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Integration Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('PreferencesService integration test', () async {
      await PreferencesService.setThemeMode('dark');
      await PreferencesService.setNotificationsEnabled(false);
      await PreferencesService.setLanguage('fr');

      final theme = await PreferencesService.getThemeMode();
      final notifications = await PreferencesService.getNotificationsEnabled();
      final language = await PreferencesService.getLanguage();

      expect(theme, 'dark');
      expect(notifications, false);
      expect(language, 'fr');
    });

    test('FirestoreService methods exist', () {
      final service = FirestoreService();
      expect(service, isNotNull);
      expect(service.createPost, isA<Function>());
      expect(service.getPosts, isA<Function>());
      expect(service.updatePost, isA<Function>());
      expect(service.deletePost, isA<Function>());
    });

    test('Multiple preferences can be set simultaneously', () async {
      await Future.wait([
        PreferencesService.setThemeMode('light'),
        PreferencesService.setNotificationsEnabled(true),
        PreferencesService.setLanguage('en'),
      ]);

      final results = await Future.wait([
        PreferencesService.getThemeMode(),
        PreferencesService.getNotificationsEnabled(),
        PreferencesService.getLanguage(),
      ]);

      expect(results[0], 'light');
      expect(results[1], true);
      expect(results[2], 'en');
    });
  });
}