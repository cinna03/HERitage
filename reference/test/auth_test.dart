import 'package:flutter_test/flutter_test.dart';
import 'package:coursehub/services/auth_service.dart';

void main() {
  group('AuthService Tests', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    test('AuthService should be initialized', () {
      expect(authService, isNotNull);
    });

    test('currentUser getter should not throw', () {
      expect(() => authService.currentUser, returnsNormally);
    });

    test('authStateChanges stream should not throw', () {
      expect(() => authService.authStateChanges, returnsNormally);
    });
  });
}