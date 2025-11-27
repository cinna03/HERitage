import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:coursehub/services/auth_service.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}
class MockUserCredential extends Mock implements UserCredential {}

void main() {
  group('AuthService Tests', () {
    late AuthService authService;
    late MockFirebaseAuth mockAuth;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      authService = AuthService();
    });

    test('should return current user when signed in', () {
      final mockUser = MockUser();
      when(mockAuth.currentUser).thenReturn(mockUser);
      
      expect(authService.currentUser, isNotNull);
    });

    test('should sign out successfully', () async {
      when(mockAuth.signOut()).thenAnswer((_) async {});
      
      await authService.signOut();
      
      verify(mockAuth.signOut()).called(1);
    });
  });
}