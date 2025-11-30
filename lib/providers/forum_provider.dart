import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class ForumProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ForumProvider() {
    _loadPosts();
  }

  void _loadPosts() {
    _firestoreService.getPosts().listen((snapshot) {
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
        'authorId': user.uid,
        'userId': user.uid,
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

  Future<void> deletePost(String postId) async {
    try {
      await _firestoreService.deletePost(postId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addComment(String postId, String comment) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated to add a comment');
      }

      final post = _posts.firstWhere((p) => p['id'] == postId);
      final currentComments = (post['comments'] ?? 0) as int;
      
      // Update comment count
      await _firestoreService.updatePost(postId, {
        'comments': currentComments + 1,
      });

      // Add comment to comments subcollection
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .add({
        'text': comment,
        'authorId': user.uid,
        'author': user.displayName ?? user.email ?? 'Anonymous',
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}