import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = false;
  StreamSubscription<QuerySnapshot>? _notificationsSubscription;

  List<Map<String, dynamic>> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !(n['read'] ?? false)).length;

  NotificationProvider() {
    _loadNotifications();
  }

  void _loadNotifications() {
    final user = _auth.currentUser;
    if (user == null) return;

    _notificationsSubscription?.cancel();
    _notificationsSubscription = _firestoreService.getUserNotifications(user.uid).listen((snapshot) {
      _notifications = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
      notifyListeners();
    });
  }

  Future<void> createNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    final notificationData = {
      'title': title,
      'body': body,
      'type': type,
      'data': data ?? {},
      'read': false,
      'timestamp': FieldValue.serverTimestamp(),
      'createdAt': DateTime.now().toIso8601String(),
    };

    await _firestoreService.createNotification(userId, notificationData);
    
    // Show local notification
    await NotificationService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: body,
    );
  }

  Future<void> markAsRead(String notificationId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .doc(notificationId)
        .update({'read': true});
  }

  Future<void> markAllAsRead() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final batch = FirebaseFirestore.instance.batch();
    for (final notification in _notifications.where((n) => !(n['read'] ?? false))) {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .doc(notification['id']);
      batch.update(docRef, {'read': true});
    }
    await batch.commit();
  }

  void refresh() {
    _loadNotifications();
  }

  @override
  void dispose() {
    _notificationsSubscription?.cancel();
    super.dispose();
  }
}