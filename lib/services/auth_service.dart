import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Service for handling authentication operations with Firebase
/// Provides methods for email/password and Google Sign-In authentication
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Configure GoogleSignIn with web client ID when running on web
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // For web, use the client ID from Firebase Console
    // This should match the OAuth 2.0 Client ID for your web app
    clientId: kIsWeb ? '597720652794-21e0bfd77addcd2d042243.apps.googleusercontent.com' : null,
    scopes: ['email', 'profile'],
  );

  /// Gets the currently authenticated user
  User? get currentUser => _auth.currentUser;
  
  /// Stream of authentication state changes
  /// Listens for user sign-in/sign-out events
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Signs in a user with email and password
  /// Throws [FirebaseAuthException] if authentication fails
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw e;
    }
  }

  /// Creates a new user account with email and password
  /// Automatically sends email verification after signup
  /// Throws [FirebaseAuthException] if signup fails
  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await result.user?.sendEmailVerification();
      return result;
    } catch (e) {
      throw e;
    }
  }

  /// Sends email verification to the current user
  /// No-op if user is not authenticated
  Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  /// Checks if the current user's email is verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  /// Signs in a user with Google Sign-In
  /// Returns null if user cancels the sign-in process
  /// Throws [FirebaseAuthException] if authentication fails
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw e;
    }
  }

  /// Signs out the current user from both Firebase and Google Sign-In
  Future<void> signOut() async {
    // Try to sign out from Google Sign-In, but don't fail if it's not configured
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      // Ignore Google Sign-In errors (e.g., if not configured for web)
      // The important part is signing out from Firebase Auth
    }
    // Always sign out from Firebase Auth
    await _auth.signOut();
  }

  /// Sends a password reset email to the specified email address
  /// Throws [FirebaseAuthException] if email is invalid or user not found
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Sends a phone number verification code via SMS (OTP)
  /// Requires phone number in E.164 format (e.g., +1234567890)
  /// Throws [FirebaseAuthException] if phone number is invalid
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) codeSent,
    required void Function(FirebaseAuthException error) verificationFailed,
    required void Function(String verificationId) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-verification completed (Android only)
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      timeout: const Duration(seconds: 60),
    );
  }

  /// Signs in with phone number using the verification code (OTP)
  /// Requires verificationId from verifyPhoneNumber and the SMS code
  Future<UserCredential?> signInWithPhoneNumber({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw e;
    }
  }

  /// Re-authenticates the current user (for sensitive operations)
  /// Useful before password changes or account deletion
  Future<void> reauthenticateWithCredential(AuthCredential credential) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in');
    }
    await user.reauthenticateWithCredential(credential);
  }
}