import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class ChatProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _chatRooms = [];
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  String? _error;
  String? _currentChatRoomId;

  List<Map<String, dynamic>> get chatRooms => _chatRooms;
  List<Map<String, dynamic>> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentChatRoomId => _currentChatRoomId;

  ChatProvider() {
    _loadChatRooms();
  }

  void _loadChatRooms() {
    _firestoreService.getChatRooms().listen((snapshot) {
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

  void loadMessages(String chatRoomId) {
    _currentChatRoomId = chatRoomId;
    _firestoreService.getChatMessages(chatRoomId).listen((snapshot) {
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
        'senderId': user.uid,
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
        'createdBy': user.uid,
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

