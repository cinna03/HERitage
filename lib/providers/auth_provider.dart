import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<User?>? _authStateSubscription;

  User? get user => _user;
  String? get userEmail => _user?.email;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _user = _authService.currentUser;
    _authStateSubscription = _authService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      final result = await _authService.signInWithEmail(email, password);
      _user = result?.user;
      _error = null;
      return true;
    } catch (e) {
      // Store the exception object, not just the string
      _error = e is FirebaseAuthException ? e.code : e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUpWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      final result = await _authService.signUpWithEmail(email, password);
      _user = result?.user;
      
      // Create user document in Firestore
      if (_user != null) {
        await _createUserDocument(_user!);
      }
      
      _error = null;
      return true;
    } catch (e) {
      // Store the exception object, not just the string
      _error = e is FirebaseAuthException ? e.code : e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    try {
      final result = await _authService.signInWithGoogle();
      _user = result?.user;
      
      // Create user document in Firestore if it doesn't exist
      if (_user != null) {
        await _createUserDocument(_user!);
      }
      
      _error = null;
      return true;
    } catch (e) {
      // Store the exception object, not just the string
      _error = e is FirebaseAuthException ? e.code : e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    try {
      await _authService.sendPasswordResetEmail(email);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Sends email verification to the current user
  Future<void> sendEmailVerification() async {
    _setLoading(true);
    try {
      await _authService.sendEmailVerification();
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Checks if the current user's email is verified
  bool get isEmailVerified => _authService.isEmailVerified;

  /// Reloads the current user to refresh email verification status
  Future<void> reloadUser() async {
    await _user?.reload();
    _user = _authService.currentUser;
    notifyListeners();
  }

  /// Verifies phone number and sends OTP code
  /// Implements phone authentication with SMS verification
  /// Uses Firebase PhoneAuthProvider for OTP delivery
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) codeSent,
    required void Function(FirebaseAuthException error) verificationFailed,
    required void Function(String verificationId) codeAutoRetrievalTimeout,
  }) async {
    _setLoading(true);
    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        codeSent: codeSent,
        verificationFailed: verificationFailed,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      if (e is FirebaseAuthException) {
        verificationFailed(e);
      } else {
        verificationFailed(FirebaseAuthException(code: 'unknown', message: e.toString()));
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Signs in with phone number using OTP code
  Future<bool> signInWithPhoneNumber({
    required String verificationId,
    required String smsCode,
  }) async {
    _setLoading(true);
    try {
      final result = await _authService.signInWithPhoneNumber(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      _user = result?.user;
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Creates or updates user document in Firestore
  Future<void> _createUserDocument(User user) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();
    
    // Only create if document doesn't exist
    if (!docSnapshot.exists) {
      final username = user.displayName ?? user.email?.split('@')[0] ?? 'User';
      
      await userDoc.set({
        'uid': user.uid,
        'email': user.email,
        'username': username,
        'displayName': user.displayName,
        'profilePictureUrl': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } else {
      // Update last seen
      await userDoc.update({
        'lastSeen': FieldValue.serverTimestamp(),
      });
    }
  }
}