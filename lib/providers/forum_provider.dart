import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../services/preferences_service.dart';
import '../services/notification_service.dart';

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
    _isLoading = true;
    _error = null;
    notifyListeners();
    
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
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      _error = error.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Refreshes posts from Firestore
  void refresh() {
    _loadPosts();
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
        'likedBy': [], // Array to track users who liked the post
        'comments': 0,
        'createdAt': DateTime.now().toIso8601String(),
      });

      // Send notification to followers if post notifications are enabled
      final postNotificationsEnabled = await PreferencesService.getPostNotifications();
      if (postNotificationsEnabled) {
        await NotificationService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch,
          title: 'New post by $author',
          body: title,
        );
      }
      
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Likes or unlikes a post
  /// Tracks which users have liked the post to prevent duplicate likes
  Future<void> toggleLikePost(String postId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated to like a post');
      }

      final post = _posts.firstWhere((p) => p['id'] == postId);
      final likedBy = (post['likedBy'] as List<dynamic>?) ?? [];
      final isLiked = likedBy.contains(user.uid);
      final currentLikes = (post['likes'] ?? 0) as int;

      if (isLiked) {
        // Unlike: remove user from likedBy and decrement count
        await _firestoreService.updatePost(postId, {
          'likes': currentLikes - 1,
          'likedBy': FieldValue.arrayRemove([user.uid]),
        });
      } else {
        // Like: add user to likedBy and increment count
        await _firestoreService.updatePost(postId, {
          'likes': currentLikes + 1,
          'likedBy': FieldValue.arrayUnion([user.uid]),
        });
        
        // Send notification to post author if not the current user
        final postAuthorId = post['userId'] as String?;
        if (postAuthorId != null && postAuthorId != user.uid) {
          await _firestoreService.createNotification(postAuthorId, {
            'type': 'like',
            'postId': postId,
            'postTitle': post['title'] ?? 'Post',
            'fromUserId': user.uid,
            'fromUserName': user.displayName ?? user.email?.split('@')[0] ?? 'Someone',
            'timestamp': FieldValue.serverTimestamp(),
            'read': false,
            'createdAt': DateTime.now().toIso8601String(),
          });
        }
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Checks if the current user has liked a post
  bool isPostLiked(String postId) {
    final user = _auth.currentUser;
    if (user == null) return false;
    
    try {
      final post = _posts.firstWhere((p) => p['id'] == postId);
      final likedBy = (post['likedBy'] as List<dynamic>?) ?? [];
      return likedBy.contains(user.uid);
    } catch (e) {
      return false;
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

      // Update comment count using service - use FieldValue.increment for atomic update
      await _firestoreService.updatePost(postId, {
        'comments': FieldValue.increment(1),
      });
      
      // Send notification to post author if not the current user
      final postAuthorId = post['userId'] as String?;
      if (postAuthorId != null && postAuthorId != user.uid) {
        await _firestoreService.createNotification(postAuthorId, {
          'type': 'comment',
          'postId': postId,
          'postTitle': post['title'] ?? 'Post',
          'fromUserId': user.uid,
          'fromUserName': user.displayName ?? user.email?.split('@')[0] ?? 'Someone',
          'commentText': comment,
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
          'createdAt': DateTime.now().toIso8601String(),
        });
      }
      
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