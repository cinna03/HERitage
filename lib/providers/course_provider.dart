import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class CourseProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _courses = [];
  Map<String, dynamic>? _currentCourse;
  Map<String, dynamic>? _userProgress;
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get courses => _courses;
  Map<String, dynamic>? get currentCourse => _currentCourse;
  Map<String, dynamic>? get userProgress => _userProgress;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CourseProvider() {
    _loadCourses();
  }

  void _loadCourses() {
    _firestoreService.getCourses().listen((snapshot) {
      _courses = snapshot.docs.map((doc) {
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

  Future<void> loadCourse(String courseId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final courseDoc = await _firestoreService.getCourse(courseId);
      if (courseDoc.exists) {
        _currentCourse = {
          'id': courseDoc.id,
          ...courseDoc.data() as Map<String, dynamic>,
        };
      }

      // Load user progress if authenticated
      final user = _auth.currentUser;
      if (user != null) {
        final progressDoc = await _firestoreService.getCourseProgress(user.uid, courseId);
        if (progressDoc.exists) {
          _userProgress = {
            'id': progressDoc.id,
            ...progressDoc.data() as Map<String, dynamic>,
          };
        } else {
          _userProgress = null;
        }
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProgress(String courseId, int progress, {int? hoursSpent}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated to update progress');
      }

      final progressData = {
        'courseId': courseId,
        'progress': progress,
        'lastUpdated': FieldValue.serverTimestamp(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (hoursSpent != null) {
        progressData['hoursSpent'] = hoursSpent;
      }

      await _firestoreService.updateCourseProgress(user.uid, courseId, progressData);
      
      // Reload progress
      await loadCourse(courseId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markComplete(String courseId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated to complete a course');
      }

      await _firestoreService.markCourseComplete(user.uid, courseId);
      
      // Create certificate
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('certificates')
          .add({
        'courseId': courseId,
        'courseTitle': _currentCourse?['title'] ?? 'Course',
        'earnedAt': FieldValue.serverTimestamp(),
        'createdAt': DateTime.now().toIso8601String(),
      });

      // Reload progress
      await loadCourse(courseId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Stream<QuerySnapshot> getUserProgress() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    return _firestoreService.getUserCourseProgress(user.uid);
  }
}

