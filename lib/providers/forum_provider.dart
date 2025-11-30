import 'package:flutter/material.dart';
import '../services/mock_firestore_service.dart';

class ForumProvider extends ChangeNotifier {
  final MockFirestoreService _firestoreService = MockFirestoreService();
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get posts => _posts;
  bool get isLoading => _isLoading;

  ForumProvider() {
    _loadPosts();
  }

  void _loadPosts() {
    _firestoreService.getPosts().listen((posts) {
      _posts = posts;
      notifyListeners();
    });
  }

  Future<void> createPost(String title, String content, String author) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _firestoreService.createPost({
        'title': title,
        'content': content,
        'author': author,
        'timestamp': DateTime.now(),
        'likes': 0,
        'comments': 0,
      });
    } catch (e) {
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> likePost(String postId) async {
    final post = _posts.firstWhere((p) => p['id'] == postId);
    await _firestoreService.updatePost(postId, {
      'likes': (post['likes'] ?? 0) + 1,
    });
  }
}