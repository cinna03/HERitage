import 'dart:async';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

/// Provider for managing user profile data
/// Handles loading and caching of user profile information
class UserProfileProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Gets the username from the profile
  String? get username => _userProfile?['username'] as String?;

  /// Gets the full name from the profile
  String? get fullName => _userProfile?['fullName'] as String?;

  /// Gets the bio from the profile
  String? get bio => _userProfile?['bio'] as String?;

  /// Gets the profile picture URL
  String? get profilePictureUrl => _userProfile?['profilePictureUrl'] as String?;

  /// Gets the interests list
  List<String> get interests {
    final interestsList = _userProfile?['interests'] as List<dynamic>?;
    return interestsList?.map((e) => e.toString()).toList() ?? [];
  }

  StreamSubscription? _authStateSubscription;

  UserProfileProvider() {
    _loadUserProfile();
    // Listen to auth state changes to reload profile when user changes
    _authStateSubscription = _authService.authStateChanges.listen((user) {
      if (user != null) {
        _loadUserProfile();
      } else {
        _userProfile = null;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  /// Loads user profile from Firestore
  Future<void> _loadUserProfile() async {
    final user = _authService.currentUser;
    if (user == null) {
      _userProfile = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final profileDoc = await _firestoreService.getUserProfile(user.uid);
      if (profileDoc.exists) {
        _userProfile = profileDoc.data() as Map<String, dynamic>?;
      } else {
        _userProfile = null;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
      _userProfile = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refreshes user profile
  Future<void> refresh() async {
    await _loadUserProfile();
  }

  /// Gets display name with fallback logic
  String getDisplayName() {
    final user = _authService.currentUser;
    if (username != null && username!.isNotEmpty) {
      return username!;
    } else if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user.displayName!;
    } else {
      return user?.email?.split('@')[0] ?? 'Creative Sister';
    }
  }

  /// Gets username with @ prefix for display
  String getUsernameDisplay() {
    if (username != null && username!.isNotEmpty) {
      return '@$username';
    }
    return '';
  }
}

