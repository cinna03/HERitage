import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class EventProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _events = [];
  Map<String, dynamic>? _currentEvent;
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get events => _events;
  Map<String, dynamic>? get currentEvent => _currentEvent;
  bool get isLoading => _isLoading;
  String? get error => _error;

  EventProvider() {
    _loadEvents();
  }

  void _loadEvents() {
    _firestoreService.getEvents().listen((snapshot) {
      _events = snapshot.docs.map((doc) {
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

  Future<void> loadEvent(String eventId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final eventDoc = await FirebaseFirestore.instance.collection('events').doc(eventId).get();
      if (eventDoc.exists) {
        _currentEvent = {
          'id': eventDoc.id,
          ...eventDoc.data() as Map<String, dynamic>,
        };
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> rsvpEvent(String eventId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated to RSVP to events');
      }

      await _firestoreService.rsvpEvent(eventId, user.uid);
      await loadEvent(eventId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelRSVP(String eventId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated to cancel RSVP');
      }

      await _firestoreService.cancelRSVP(eventId, user.uid);
      await loadEvent(eventId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> isUserRSVPed(String eventId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;
      return await _firestoreService.isUserRSVPed(eventId, user.uid);
    } catch (e) {
      return false;
    }
  }

  Future<void> createEvent(Map<String, dynamic> eventData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated to create events');
      }

      eventData['creatorId'] = user.uid;
      eventData['createdAt'] = FieldValue.serverTimestamp();
      eventData['attendees'] = [];
      
      await _firestoreService.createEvent(eventData);
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

