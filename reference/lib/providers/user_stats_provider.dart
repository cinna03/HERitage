import 'dart:async';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

/// Provider for managing user statistics
/// Handles loading and caching of user statistics data
class UserStatsProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  
  Map<String, dynamic>? _userStats;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get userStats => _userStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Gets the number of courses completed
  int get coursesCompleted => _userStats?['coursesCompleted'] ?? 0;
  
  /// Gets the total hours learned
  int get totalHours => _userStats?['totalHours'] ?? 0;
  
  /// Gets the number of certificates earned
  int get certificatesEarned => _userStats?['certificatesEarned'] ?? 0;
  
  /// Gets the number of community posts
  int get postsCount => _userStats?['postsCount'] ?? 0;

  StreamSubscription? _authStateSubscription;

  UserStatsProvider() {
    _loadUserStatistics();
    // Listen to auth state changes to reload stats when user changes
    _authStateSubscription = _authService.authStateChanges.listen((user) {
      if (user != null) {
        _loadUserStatistics();
      } else {
        _userStats = null;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  /// Loads user statistics from Firestore
  Future<void> _loadUserStatistics() async {
    final user = _authService.currentUser;
    if (user == null) {
      _userStats = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final stats = await _firestoreService.getUserStatistics(user.uid);
      _userStats = stats;
      _error = null;
    } catch (e) {
      _error = e.toString();
      // Set default values on error
      _userStats = {
        'coursesCompleted': 0,
        'postsCount': 0,
        'totalHours': 0,
        'certificatesEarned': 0,
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refreshes user statistics
  Future<void> refresh() async {
    await _loadUserStatistics();
  }
}

