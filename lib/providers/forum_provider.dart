import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

/// Provider for managing forum posts and comments
/// Handles real-time updates, post creation, likes, and comments
class ForumProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<QuerySnapshot>? _postsSubscription;

  List<Map<String, dynamic>> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ForumProvider() {
    _loadPosts();
  }

  /// Loads posts from Firestore with real-time updates
  void _loadPosts() {
    _postsSubscription?.cancel();
    _postsSubscription = _firestoreService.getPosts().listen((snapshot) {
      _posts = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
      _error = null;
      notifyListeners();
    }, onError: (error) {
      _error = error.toString();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _postsSubscription?.cancel();
    super.dispose();
  }

  /// Creates a new forum post
  /// Requires user authentication
  Future<void> createPost(String title, String content, String author) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated to create a post');
      }

      await _firestoreService.createPost({
        'title': title,
        'content': content,
        'author': author,
        'userId': user.uid, // Standardized field name for user ID
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 0,
        'comments': 0,
        'createdAt': DateTime.now().toIso8601String(),
      });
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Likes a post by incrementing the like count
  Future<void> likePost(String postId) async {
    try {
      final post = _posts.firstWhere((p) => p['id'] == postId);
      final currentLikes = (post['likes'] ?? 0) as int;
      await _firestoreService.updatePost(postId, {
        'likes': currentLikes + 1,
      });
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Deletes a post (only by the post creator)
  Future<void> deletePost(String postId) async {
    try {
      await _firestoreService.deletePost(postId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Adds a comment to a post
  /// Updates the comment count and creates the comment document
  Future<void> addComment(String postId, String comment) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated to add a comment');
      }

      final post = _posts.firstWhere((p) => p['id'] == postId);
      final currentComments = (post['comments'] ?? 0) as int;
      
      // Add comment to comments subcollection using service
      await _firestoreService.addComment(postId, {
        'text': comment,
        'userId': user.uid, // Standardized field name for user ID
        'author': user.displayName ?? user.email ?? 'Anonymous',
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': DateTime.now().toIso8601String(),
      });

      // Update comment count using service
      await _firestoreService.updatePostCommentCount(postId, currentComments + 1);
      
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}