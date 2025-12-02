import 'dart:async';
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
  StreamSubscription<QuerySnapshot>? _eventsSubscription;

  List<Map<String, dynamic>> get events => _events;
  Map<String, dynamic>? get currentEvent => _currentEvent;
  bool get isLoading => _isLoading;
  String? get error => _error;

  EventProvider() {
    _loadEvents();
  }

  /// Loads events from Firestore with real-time updates
  void _loadEvents() {
    _eventsSubscription?.cancel();
    _eventsSubscription = _firestoreService.getEvents().listen((snapshot) {
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

  /// Refreshes events from Firestore
  /// Call this method to ensure data is loaded after app restart
  void refresh() {
    _loadEvents();
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    super.dispose();
  }

  /// Loads a specific event by ID
  Future<void> loadEvent(String eventId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final eventDoc = await _firestoreService.getEvent(eventId);
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

  /// RSVPs the current user to an event
  /// Adds user to attendees list
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

  /// Cancels the current user's RSVP for an event
  /// Removes user from attendees list
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

  /// Checks if the current user has RSVPed to an event
  Future<bool> isUserRSVPed(String eventId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;
      return await _firestoreService.isUserRSVPed(eventId, user.uid);
    } catch (e) {
      return false;
    }
  }

  /// Creates a new event
  /// Requires user authentication
  /// Automatically sets userId and initializes attendees list
  Future<void> createEvent(Map<String, dynamic> eventData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated to create events');
      }

      eventData['userId'] = user.uid; // Standardized field name for user ID
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

