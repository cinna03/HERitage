import 'package:flutter/material.dart';
import '../services/mock_auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final MockAuthService _authService = MockAuthService();
  String? _userEmail;
  bool _isLoading = false;
  String? _error;

  String? get userEmail => _userEmail;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _userEmail != null;

  AuthProvider() {
    _userEmail = _authService.currentUserEmail;
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.signInWithEmail(email, password);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUpWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.signUpWithEmail(email, password);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    try {
      await _authService.signInWithGoogle();
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }

  void _updateUser() {
    _userEmail = _authService.currentUserEmail;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}