import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

/// Provider for managing chat rooms and messages
/// Handles real-time chat updates, message sending, and chat room creation
class ChatProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _chatRooms = [];
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  String? _error;
  String? _currentChatRoomId;
  StreamSubscription<QuerySnapshot>? _chatRoomsSubscription;
  StreamSubscription<QuerySnapshot>? _messagesSubscription;

  List<Map<String, dynamic>> get chatRooms => _chatRooms;
  List<Map<String, dynamic>> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentChatRoomId => _currentChatRoomId;

  ChatProvider() {
    _loadChatRooms();
  }

  /// Loads chat rooms from Firestore with real-time updates
  void _loadChatRooms() {
    _chatRoomsSubscription?.cancel();
    _chatRoomsSubscription = _firestoreService.getChatRooms().listen((snapshot) {
      _chatRooms = snapshot.docs.map((doc) {
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

  /// Refreshes chat rooms from Firestore
  /// Call this method to ensure data is loaded after app restart
  void refresh() {
    _loadChatRooms();
  }

  /// Loads messages for a specific chat room with real-time updates
  void loadMessages(String chatRoomId) {
    _currentChatRoomId = chatRoomId;
    _messagesSubscription?.cancel();
    _messagesSubscription = _firestoreService.getChatMessages(chatRoomId).listen((snapshot) {
      _messages = snapshot.docs.map((doc) {
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
    _chatRoomsSubscription?.cancel();
    _messagesSubscription?.cancel();
    super.dispose();
  }

  /// Sends a message to a chat room
  /// Requires user authentication
  Future<void> sendMessage(String chatRoomId, String text) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated to send messages');
      }

      await _firestoreService.sendChatMessage(chatRoomId, {
        'text': text,
        'userId': user.uid, // Standardized field name for user ID
        'senderName': user.displayName ?? user.email ?? 'Anonymous',
        'timestamp': FieldValue.serverTimestamp(),
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

  /// Creates a new chat room
  /// Requires user authentication
  /// Automatically adds creator as a member
  Future<void> createChatRoom(String name, String description) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated to create a chat room');
      }

      await _firestoreService.createChatRoom({
        'name': name,
        'description': description,
        'userId': user.uid, // Standardized field name for user ID
        'createdAt': FieldValue.serverTimestamp(),
        'memberCount': 1,
        'members': [user.uid],
        'isActive': true,
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

  void clearMessages() {
    _messages = [];
    _currentChatRoomId = null;
    notifyListeners();
  }
}

