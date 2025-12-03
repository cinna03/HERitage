import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class UserSearchProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  String _searchQuery = '';
  Timer? _debounceTimer;

  List<Map<String, dynamic>> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  void searchUsers(String query, String currentUserId) {
    _searchQuery = query;
    
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: 300), () {
      _performSearch(query, currentUserId);
    });
  }

  void _performSearch(String query, String currentUserId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestoreService.getAllUsers().first;
      final queryLower = query.toLowerCase();
      
      _searchResults = snapshot.docs
          .where((doc) {
            final userId = doc.id;
            if (userId == currentUserId) return false;
            
            final userData = doc.data() as Map<String, dynamic>;
            final username = (userData['username'] ?? '').toString().toLowerCase();
            final email = (userData['email'] ?? '').toString().toLowerCase();
            
            return username.contains(queryLower) || email.contains(queryLower);
          })
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      _searchResults = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    _debounceTimer?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

